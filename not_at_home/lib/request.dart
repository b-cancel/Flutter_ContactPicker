import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact.dart';
import 'package:not_at_home/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PageRequestingContact extends StatefulWidget {
  @override
  _PageRequestingContactState createState() => _PageRequestingContactState();
}

class _PageRequestingContactState extends State<PageRequestingContact> with WidgetsBindingObserver {
  bool isSwitched = true;
  bool forceContactChange = true;

  ValueNotifier<bool> manualInput = new ValueNotifier<bool>(false);
  ValueNotifier<String> name = new ValueNotifier<String>("");
  ValueNotifier<String> number = new ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //name always changes with number
    name.addListener((){
      //set state so that the new selected name is on the button
      setState(() {
        
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      if(forceContactChange && manualInput.value){
        //we forced the user to get a contact
        //but they are back
        //which can only happen IF then were allowed back
        //but IF they were allowed back we still don't have our contact
        //so we can confidently imply that they chosse the manualy input option
        //TODO.a.sd.fkajsd.fjalsj
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //theme changer
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    
    //button text
    String buttonText = name.value + " | " + number.value;
    if(buttonText == " | ") buttonText = "Select Contact";

    //build
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Requesting Contact"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Click Below To \n\"Select\" or \"Change\" \nthe Contact",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 16),
                child: FlatButton(
                  color: Theme.of(context).highlightColor,
                  onPressed: (){
                    //set so that if we come back here without new name and value we are forced
                    manualInput.value = true;
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SelectContact(
                          contact: new ValueNotifier<Contact>(new Contact()),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        if(value){
                            _themeChanger.setTheme(ThemeData.dark());
                          }
                          else{
                            _themeChanger.setTheme(ThemeData.light());
                          }
                          isSwitched = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      (isSwitched) ?
                      "Dark Mode"
                      : "Light Mode",
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Switch(
                    value: forceContactChange,
                    onChanged: (value) {
                      setState(() {
                        forceContactChange = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      (forceContactChange) ?
                      "Force Change"
                      : "Don't Force Chance",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}