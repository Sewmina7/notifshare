import 'dart:convert';
import 'package:notifications/notifications.dart';

class Rule{
  String ruleName;
  String packageName;
  String title;
  String message;

  Rule(this.ruleName,this.packageName, this.title,this.message);

  @override
  String toString() {
    return jsonEncode(this);
  }


  static Rule parseFromJson(String json){

    Map<String, dynamic> jsonObj = jsonDecode(json);
    return Rule(jsonObj['ruleName'], jsonObj['packageName'], jsonObj['title'], jsonObj['message']);
  }
}

extension RuleExtensions on Rule{
  String toJson(){
    return '{"ruleName":"$ruleName", "packageName":"$packageName", "title":"$title", "message":"$message"}';
  }
}
extension NotificationExtensions on NotificationEvent{
  String toJson(){
    return '{"timestamp":"$timeStamp", "packageName":"$packageName", "title":"$title", "message":"$message"}';
  }

  Map<String,String> toMap(){
    return <String,String>{
      "timestamp": timeStamp.toString(),
      "packageName": packageName.toString(),
      "title": title.toString(),
      "message":message.toString()
    };

  }
}
