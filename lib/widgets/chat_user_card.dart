import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sociotopia/api/apis.dart';
import 'package:sociotopia/helper/my_date_util.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/models/chat_user.dart';
import 'package:sociotopia/models/message.dart';
import 'package:sociotopia/screens/chat_screen.dart';
import 'package:sociotopia/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onLongPress: (){
      //   APIs.deleteMyUsersId();
      // },
      child: Card(        
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.orange.shade100,
        elevation: .8,
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }
      
                return ListTile(
                    leading: InkWell(
                      onTap: () {
                        showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: CachedNetworkImage(
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(child: Icon(Icons.person)),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null ? 
      
                      _message!.type == Type.image ? 'Photo' : 
                      _message!.msg 
                      : widget.user.about,
                      maxLines: 1,
                    ),
                    // trailing: Text('10:30 AM', style: TextStyle(color: Colors.black54),)
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(
                                MyDateUtil.getlastMessagetime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(color: Colors.black54),
                              ));
              }),
        ),
      ),
    );
  }
}
