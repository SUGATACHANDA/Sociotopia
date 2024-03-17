import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sociotopia/api/apis.dart';
import 'package:sociotopia/helper/dialog.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/models/chat_user.dart';
import 'package:sociotopia/screens/auth/login_screen.dart';
// import 'package:sociotopia/screens/auth/login_screen.dart';
// import 'package:sociotopia/widgets/chat_user_card.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: const Text('Profile Screen')),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              onPressed: () async {
                Dialogs.showProgressbar(context);

                await APIs.updateActiveStatus(false);

                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);

                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => loginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: Text('\tLogout'),
            ),
          ),
          backgroundColor: Colors.orange.shade100,
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: mq.width,
                      height: mq.height * .03,
                    ),
                    Stack(
                      children: [
                        _image != null ? 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: Image.file(
                            File(_image!),
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                            
                          ),
                        ):
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            color: Colors.orange,
                            shape: CircleBorder(),
                            onPressed: () {
                              _showBootomSheet();
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: mq.height * .02,
                    ),
                    Text(widget.user.email,
                        style: TextStyle(color: Colors.black54, fontSize: 16)),
                    SizedBox(height: mq.height * .03),
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.myself.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.orange.shade400,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          label: Text('Name')),
                    ),
                    SizedBox(height: mq.height * .02),
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.myself.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.info_outline,
                              color: Colors.orange.shade400),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          label: Text('About')),
                    ),
                    SizedBox(height: mq.height * .05),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange,
                          minimumSize: Size(mq.width * .5, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.successShowSnackbar(
                                context, 'Profile Updated Successfully');
                          });
                          log('inside validator');
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 28,
                      ),
                      label: Text('Update', style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _showBootomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.orange.shade300,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .08),
            children: [
              Text('Select Profile Photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                        elevation: 0,
                        shape: CircleBorder(),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.orange.shade900,
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                        elevation: 0,
                        shape: CircleBorder(),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/image_camera.png')),
                ],
              )
            ],
          );
        });
  }
}
