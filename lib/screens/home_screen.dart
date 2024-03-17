import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:sociotopia/api/apis.dart';
import 'package:sociotopia/helper/dialog.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/models/chat_user.dart';
import 'package:sociotopia/screens/profile_screen.dart';
import 'package:sociotopia/widgets/chat_user_card.dart';
// import 'package:sociotopia/screens/auth/login_screen.dart';
// import 'package:sociotopia/widgets/chat_user_card.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    APIs.updateActiveStatus(true);

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search User...',
                        hintStyle: TextStyle(color: Colors.white)),
                    autofocus: true,
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, letterSpacing: 1),
                    onChanged: (val) {
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }

                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text('Sociotopia'),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon:
                      Icon(_isSearching ? Icons.clear_rounded : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.myself,
                                )));
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              onPressed: () {
                _addChatUserDialog();
              },
              child: const Icon(Icons.add_comment),
            ),
          ),
          backgroundColor: Colors.orange.shade100,
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ConnectionState.active:
                        case ConnectionState.done:
                return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          // return const Center(
                          //     child: CircularProgressIndicator());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;

                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(
                                    top: mq.height * .01,
                                    bottom: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                  // return Text('Name: ${list[index]}');
                                });
                          } else {
                            return const Center(
                                child: Text(
                              'No User Found!',
                              style: TextStyle(fontSize: 20),
                            ));
                          }
                      }
                    });
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.orange.shade200,
              title: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.orange,
                    size: 28,
                  ),
                  Text(
                    '  Add User',
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
              content: TextFormField(
                  maxLines: null,
                  onChanged: (value) => email = value,
                  decoration: InputDecoration(
                      hintText: 'Email Id',
                      hintStyle: TextStyle(color: Colors.black54),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)))),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.errorShowSnackbar(
                              context, "User doesn't EXISTS! Try Again");
                        }
                      });
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
