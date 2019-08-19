import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/selectContactLogic.dart';
import 'package:not_at_home/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

//this Class is required in order to be able to pass parameters to named routes
class ContactDisplayArgs {
  final Contact contact;
  ContactDisplayArgs(this.contact);
}

class ContactDisplayHelper extends StatelessWidget {
  static const routeName = '/contactDisplay';

  @override
  Widget build(BuildContext context) {
    final ContactDisplayArgs args = ModalRoute.of(context).settings.arguments;
    return ContactDisplay(
      contact: args.contact,
    );
  }
}

//this class actually displays the contact
class ContactDisplay extends StatefulWidget {
  ContactDisplay({
    this.contact,
  });

  final Contact contact;

  @override
  _ContactDisplayState createState() => _ContactDisplayState();
}

class _ContactDisplayState extends State<ContactDisplay> {
  //these are actually defaults
  bool darkMode = true;
  bool forceContactUpdate = false;

  //NOTE: whatever is in here are ONLY placeholders
  ValueNotifier<Contact> contact = new ValueNotifier<Contact>(new Contact());

  //init state
  @override
  void initState() {
    super.initState();
    //grab our initial contact
    contact.value = widget.contact;

    //whenever you change the contact also updates the UI
    contact.addListener((){
      print("--------------------------------------NAME CHANGED");
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //theme changer
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    
    //button text
    String buttonText = contact.value?.givenName ?? "Select Contact";

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
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SelectContact(
                          userPrompt: ["Prompt The User", "For A Contact"],
                          selectContactBackUp: SelectContactBackUp.systemContactPicker,
                          routeName: ContactDisplayHelper.routeName,
                          forceSelection: forceContactUpdate,
                          contactToUpdate: contact,
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
                    value: darkMode,
                    onChanged: (value) {
                      setState(() {
                        if(value){
                            _themeChanger.setTheme(ourDark);
                          }
                          else{
                            _themeChanger.setTheme(ourLight);
                          }
                          darkMode = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      (darkMode) ?
                      "Dark Mode"
                      : "Light Mode",
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Switch(
                    value: forceContactUpdate,
                    onChanged: (value) {
                      setState(() {
                        forceContactUpdate = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      (forceContactUpdate) ?
                      "Force Change"
                      : "Don't Force Change",
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