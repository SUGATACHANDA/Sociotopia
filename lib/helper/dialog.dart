import 'package:flutter/material.dart';

class Dialogs {
  static void errorShowSnackbar(BuildContext context, String msg) {
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: StadiumBorder(),
      
    ));
  }

  static void successShowSnackbar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: StadiumBorder(),
      
    ));
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
