// import 'dart:developer';
// import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sociotopia/api/apis.dart';
// import 'package:sociotopia/helper/dialog.dart';
import 'package:sociotopia/helper/my_date_util.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/models/chat_user.dart';
// import 'package:sociotopia/screens/auth/login_screen.dart';
// import 'package:sociotopia/screens/auth/login_screen.dart';
// import 'package:sociotopia/widgets/chat_user_card.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text(widget.user.name)),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Joined On ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              Text(
                MyDateUtil.getlastMessagetime(context: context, time: widget.user.createdAt, showYear: true),
                style: TextStyle(),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade100,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  Text(widget.user.email,
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                  SizedBox(height: mq.height * .02),
                  
                  Row(                    
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      
                      SizedBox(
                        width: mq.width * .7,
                        child: Text(
                          widget.user.about,
                          style: TextStyle(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
