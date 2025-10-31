import 'package:flutter/material.dart';
import 'package:notifshare/Dialogs.dart';
import 'package:notifshare/Helpers.dart';
import 'package:notifshare/brian.dart';

class EditRulePage extends StatefulWidget {
  EditRulePage({super.key, required this.ruleName});

  String ruleName;
  @override
  State<EditRulePage> createState() => _EditRulePageState();
}
TextEditingController ruleNameController = TextEditingController();
TextEditingController packageNameController = TextEditingController();
TextEditingController titleController = TextEditingController();
TextEditingController messageController = TextEditingController();


class _EditRulePageState extends State<EditRulePage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String rulename = widget.ruleName;
    Rule rule = GetRuleByName(rulename);
    bool isEdit = rulename != "";

    if(!isEdit){
      ruleNameController.text = "New Rule ${rules.length+1}" ;
      packageNameController.clear();
      titleController.clear();
      messageController.clear();
    }else{
      ruleNameController.text=  rulename;
      packageNameController.text = rule.packageName;
      titleController.text = rule.title;
      messageController.text = rule.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    String rulename = widget.ruleName;
    Rule rule = GetRuleByName(rulename);
    bool isEdit = rulename != "";

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? "Edit Rule" : "New Rule"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rule Name (ex: Messages)"),
                  TextField(controller: ruleNameController,),
                  SizedBox(height: 40,),
                  Text("Package Name (ex: com.example.appname)"),
                  TextField(controller: packageNameController,),
                  SizedBox(height: 40,),
                  Text("Title (ex: John Doe)"),
                  TextField(controller: titleController,),
                  SizedBox(height: 40,),

                  Text("Message (ex: Hey there)"),
                  TextField(controller: messageController,)
                ],
              ),
              
              Row(children: [
                Expanded(flex:2,child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(onPressed: (){
                    Navigator.of(context).pop();
                  },child: Text("Cancel"),color: Colors.red,),
                ),),
                Expanded(flex:3,child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(onPressed: (){
                    if(ruleNameController.text.isEmpty){
                      Dialogs.showAlertDialog(context, "Rule name is empty", "Please enter a rule name");
                      return;
                    }
                    if(isEdit){
                      Rule existingRule = GetRuleByName(ruleNameController.text);
                      DeleteRule(existingRule);
                    }else{
                    if(ruleNameController.text.isNotEmpty){
                    Rule existingRule = GetRuleByName(ruleNameController.text);
                    if(existingRule.ruleName != "na"){
                    Dialogs.showAlertDialog(context, "Rule name exists", "Please enter a different rule name");
                    return;
                    }
                    }
                    }
                    AddRule(Rule(ruleNameController.text, packageNameController.text, titleController.text, messageController.text));


                    Navigator.of(context).pop();
                  },child: Text("Save"),color: Colors.green,),
                ),),


              ],)
            ],
          ),
        ),
      ),
    );
  }
}
