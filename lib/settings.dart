
import 'package:notifications/notifications.dart';

import 'package:flutter/material.dart';
import 'package:notifshare/Helpers.dart';
import 'package:notifshare/brian.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
TextEditingController apiTextController = TextEditingController();
class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  Refresh();
  }

  void Refresh()async{
    apiTextController.text= await GetApiAddress();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children: [
          ListTile(
            title: Text("Action on Forward"),
            subtitle: Text("What to do on new notifications"),
            trailing: Text("Web API"),
          ),
          ListTile(
            title: Text("API Address"),
            subtitle:  TextField(controller: apiTextController,onChanged: (val){
              SetApiAddress(apiTextController.text);
            },),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Text(NotificationEvent(packageName: "com.example.app", timeStamp: DateTime.now(), title: "Test sample", message: "Sample message").toJson())
                // child: Text(Rule("value", "value","value","value").toJson()),
              ),
            ),
          ),
          Text("POST format")
        ],
      ),
    );
  }
}
