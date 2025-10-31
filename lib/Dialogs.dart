import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifshare/brian.dart';
import '../main.dart';
import 'Helpers.dart';

class Dialogs{

  static showAlertDialog(BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      title: Text(title,textAlign: TextAlign.center,),
      content: Text(message,textAlign: TextAlign.center,),
      actions: [
        okButton,
      ],

    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showDeleteRuleDialog(BuildContext context, String ruleName) {
    Rule rule = GetRuleByName(ruleName);
    // set up the button
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      title: Text("Are you sure?",textAlign: TextAlign.center,),
      content: Text(rule.toJson(),textAlign: TextAlign.center,),
      actions: [
        TextButton(
          child: Text("Yes"),
          onPressed: () {
            DeleteRule(rule);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("No"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],

    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static bool showing = false;
  static BuildContext? context;
  static waiting(){
    showing=true;
    // context=navigatorKey.currentContext;
    if(context!=null) {
      return showDialog(
          context: context!,
          barrierDismissible: false,
          routeSettings: const RouteSettings(name: "Progress"),
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: Color(0xaa101010),
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SpinKitChasingDots(color: Colors.green),
                  Expanded(child: Text("Loading",textAlign: TextAlign.center,)),
                ],
              ),
            );
          }
      );
    }
  }

}