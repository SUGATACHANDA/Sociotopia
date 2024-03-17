import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:sociotopia/api/apis.dart';
import 'package:sociotopia/helper/dialog.dart';
// import 'package:sociotopia/helper/dialog.dart';
import 'package:sociotopia/helper/my_date_util.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMyself = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBootomSheet(isMyself);
      },
      child: isMyself ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        )
      ],
    );
  }

  void _showBootomSheet(bool isMyself) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.orange.shade300,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _optionItem(
                      icon: Icon(
                        Icons.copy_outlined,
                        color: Colors.blueAccent.shade100,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);

                          // Dialogs.successShowSnackbar(context, 'Text copied to clipboard');
                        });
                      })
                  : _optionItem(
                      icon: Icon(
                        Icons.download_rounded,
                        color: Colors.blueAccent.shade100,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('Image URL: ${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'Sociotopia Images')
                              .then((success) {
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.successShowSnackbar(
                                  context, 'Image saved Successfully!');
                            }
                          });
                        } catch (e) {
                          log('ErrorWhileSavingImage: $e');
                        }
                      }),
              if (isMyself)
                Divider(
                  color: Colors.orange.shade100,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              if (widget.message.type == Type.text && isMyself)
                _optionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.green.shade200,
                      size: 26,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      Navigator.pop(context);
                      _showMesageUpdateDailog();
                    }),
              if (isMyself)
                _optionItem(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),
              if (isMyself)
                Divider(
                  color: Colors.orange.shade100,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              _optionItem(
                  icon: Icon(
                    Icons.done_all_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  name:
                      'Sent at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
              if (isMyself)
                _optionItem(
                    icon: Icon(
                      Icons.done_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: widget.message.read.isEmpty
                        ? 'Read at: Not Seen Yet'
                        : 'Read at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                    onTap: () {}),
            ],
          );
        });
  }

  void _showMesageUpdateDailog() {
    String updatedMsg = widget.message.msg;

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
                    Icons.message_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  Text(
                    ' Update Message',
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
              content: TextFormField(
                  maxLines: null,
                  onChanged: (value) => updatedMsg = value,
                  initialValue: updatedMsg,
                  decoration: InputDecoration(
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
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updatedMsg);
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class _optionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _optionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .025),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
