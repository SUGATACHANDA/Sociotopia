import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sociotopia/api/apis.dart';
import 'package:sociotopia/helper/dialog.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/screens/home_screen.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nuserAdditonalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const homeScreen()));          
        }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const homeScreen()));
          });
        }

        
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.errorShowSnackbar(context, 'Something Went Wrong !');
      return null;
    }
  }

// _signOut() async{
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Sociotopia'),
      ),
      backgroundColor: Colors.orange.shade100,
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .24,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .50,
              duration: const Duration(seconds: 1),
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                    shape: const StadiumBorder(),
                    elevation: 5,
                  ),
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon:
                      Image.asset('images/google.png', height: mq.height * .04),
                  label: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500))
                      ])))),
        ],
      ),
    );
  }
}
