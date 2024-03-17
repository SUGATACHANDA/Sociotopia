import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociotopia/api/apis.dart';
import 'package:sociotopia/main.dart';
import 'package:sociotopia/screens/auth/login_screen.dart';
import 'package:sociotopia/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');  
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const homeScreen()));
      } 

      else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const loginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text('Welcome to Sociotopia'),
      // ),
      backgroundColor: Colors.black, 
      body: Stack(
        
        children: [
          Positioned(
              top: mq.height * .35,
              right: mq.width * .25,
              width: mq.width * .50,
              
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('images/icon.png')),
              ),                 
          Positioned(
              bottom: mq.height * 0.1,
              width: mq.width,
              child: const Text('Developed By Sugata Chanda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, color: Colors.white, letterSpacing: .5))),
        ],
      ),
    );
  }
}
