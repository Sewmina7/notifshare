import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Helpers.dart';
import 'package:http/http.dart' as http;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
      initialNotificationTitle: 'NOTIFICATION SHARING SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ), iosConfiguration: IosConfiguration(),);
}



void SubForNotifications(){
  _notifications = new Notifications();

  try{
    _subscription = _notifications.notificationStream!.listen(onData);
  } on NotificationException catch(e){

  }
}

List<NotificationEvent> events = [];
late Notifications _notifications;
late StreamSubscription<NotificationEvent> _subscription;

void onData(NotificationEvent m_event){
  if(m_event.packageName == "com.Xperience.notifshare"){return;}

  NotificationEvent event = NotificationEvent(packageName: m_event.packageName, title: m_event.title, message: m_event.message, timeStamp: m_event.timeStamp?.subtract(Duration(milliseconds: m_event.timeStamp?.millisecond ?? 0)));

  if(events.length >0){
    if(compareNotifications(event, events[events.length-1])){print("same");return;}
  }
  events.add(event);

  ValidateAndForward(event);

  print(event);
}
int count =0;
void ValidateAndForward(NotificationEvent event) async{
  List<Rule> loadedRules =await LoadRules();
  bool shouldSend = false;
  for(int i=0; i < loadedRules.length; i++){
    Rule rule = loadedRules[i];
    if(rule.title == "" && rule.packageName == "" && rule.message == ""){shouldSend=true; print("All: " +rule.ruleName);break;}

    if(rule.packageName.isNotEmpty && event.packageName!.toLowerCase().contains(rule.packageName)){
      shouldSend=true;
      print("${rule.ruleName} by package name");
      break;
    }
    if(rule.title.isNotEmpty && event.title!.toLowerCase().contains(rule.title)){
      shouldSend=true;
      print("${rule.ruleName} by title");
      break;
    }
    if(rule.message.isNotEmpty && event.message!.toLowerCase().contains(rule.message)){
      shouldSend=true;
      print("${rule.ruleName} by message");
      break;
    }
  }
  if(shouldSend){
    ForwardThruAPI(event);
    count++;
  }else{
    print("Not in rules");
  }
}

void ForwardThruAPI(NotificationEvent event) async{
  String apiAddress = await GetApiAddress();
  print("requesting\n$apiAddress\n\n${event.toJson()}");
  var response = await http.post(Uri.parse(apiAddress), body: event.toMap());
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
}

bool compareNotifications(NotificationEvent event1, NotificationEvent event2){
  int diffInSecs = event1.timeStamp!.difference(event2.timeStamp!).inSeconds;
  if(diffInSecs > 1 || diffInSecs < -1){
    return false;
  }

  return event1.packageName == event2.packageName && event1.message == event2.message && event1.title == event2.title;
}

Future<File> get settingsFile async {
  final path = await getApplicationDocumentsDirectory();
  return File('$path/rules.txt').create(recursive: true);;
}
List<Rule> rules = [];

void AddRule(Rule newRule){
  rules.add(newRule);
  rulesStreamController.add(rules);
  SaveRules();
}

void DeleteRule(Rule ruleToDel){
  rules.remove(ruleToDel);
  rulesStreamController.add(rules);
  SaveRules();
}

StreamController<List<Rule>> rulesStreamController = StreamController<List<Rule>>();


Future<void> SaveRules() async{
  String json=jsonEncode(rules.map((e) => e.toJson()).toList());
  print(json);
  List<String> rulesString = [];
  for(int i=0; i < rules.length; i++){
    rulesString.add(rules[i].toJson());
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList("settings", rulesString);
}

Future<List<Rule>> LoadRules() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Rule> rules = [];
  List<String> rulesString = prefs.getStringList("settings") ?? [];

  for(int i=0; i < rulesString.length; i++){
    rules.add(Rule.parseFromJson(rulesString[i]));
  }

  rulesStreamController.add(rules);
  return rules;
}

Future<String> GetApiAddress() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString("api") ?? "http://vps.playpoolstudios.com/notifshare/api/on_notification.php";
}

void SetApiAddress(String newAddress) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString("api", newAddress);
}

Rule GetRuleByName(String rulename){
  for(int i=0; i < rules.length; i++){
    if(rules[i].ruleName == rulename){
      return rules[i];
    }
  }

  return Rule("na", "na", "na", "na");
}

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  //DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  SubForNotifications();
  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is ServiceInstance) {
      // if (await service.) {
      //print(events.length);
      flutterLocalNotificationsPlugin.show(
        notificationId,
        'Sharing notifications',
        '${count} forwarded',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );
      // }
    }
  });
}