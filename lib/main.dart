import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifications/notifications.dart';
import 'package:notifshare/Dialogs.dart';
import 'package:notifshare/Helpers.dart';
import 'package:notifshare/editRule.dart';
import 'package:notifshare/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'brian.dart';

Future<void> main() async {
 // WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: TextTheme(
          bodySmall: GoogleFonts.lato()
        )
      ),
      home: MyHomePage(stream: rulesStreamController.stream,),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({required this.stream});

  final Stream<List<Rule>> stream;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    InitNotificationBG();

    Refresh();
  }

  void InitNotificationBG() async{
    var notificationPermission = await Permission.notification.status;
    if(notificationPermission.isDenied){
      await Permission.notification.request();
    }
    initializeService();
  }

  void Refresh() async{
    rules = await LoadRules();

    widget.stream.listen((event) {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rules"),
            InkWell(child: Icon(Icons.settings),onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingsPage()));},)
          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add) ,onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditRulePage(ruleName: '',)));
      },),
      body: SafeArea(
        child: rules.length <=0 ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,size: 100,color: Colors.white12,),
            SizedBox(height: 20,),
            Text("Press on + button to make rules", style: TextStyle(color: Colors.grey),),
          ],
        ),) : ListView.builder(itemCount: rules.length ,itemBuilder: (context, index){
          Rule rule = rules[index];
          return Card(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rules[index].ruleName, style: TextStyle(fontSize: 20),),
                      Row(
                        children: [
                          InkWell(child: Icon(Icons.edit), onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditRulePage(ruleName:rule.ruleName))).then((value) => ()async{ await Future.delayed(const Duration(seconds: 1)); setState(() {

                            });});
                          },),
                          SizedBox(width: 20,),
                          InkWell(child: Icon(Icons.delete), onTap: (){Dialogs.showDeleteRuleDialog(context, rules[index].ruleName);},)

                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text("Package Name :",),
                      Text(rules[index].packageName)
                    ],
                  ),
                  Row(
                    children: [
                      Text("Title :"),
                      Text(rules[index].title)

                    ],
                  ),
                  Row(
                    children: [
                      Text("Message :"),
                      Text(rules[index].message)

                    ],
                  ),
                ],
              ),
            ),
          );
        })
      ),
    );
  }
}
