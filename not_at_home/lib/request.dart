import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact.dart';
import 'package:not_at_home/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

/*
If arrive at this page and
  - its the first time we arrive at it
    - and we do so with an empty contact -> pop up manual input (forced)
  - its not the first time we arrive at it
    - and we update our contact wtih an empty contact -> pop up manual input (non-forced should return our previous contact)
*/

enum ContactInput {no, suggest, force}

class ContactDisplayArgs {
  final Contact contact;
  final ContactInput contactInput;
  ContactDisplayArgs(this.contact, this.contactInput);
}

class ContactDisplayHelper extends StatelessWidget {
  static const routeName = '/contactDisplay';

  @override
  Widget build(BuildContext context) {
    final ContactDisplayArgs args = ModalRoute.of(context).settings.arguments;
    return ContactDisplay(
      contact: args.contact,
      contactInput: args.contactInput,
    );
  }
}

class ContactDisplay extends StatefulWidget {
  ContactDisplay({
    this.contact,
    this.contactInput,
  });

  final Contact contact;
  final ContactInput contactInput;

  @override
  _ContactDisplayState createState() => _ContactDisplayState();
}

class _ContactDisplayState extends State<ContactDisplay> with WidgetsBindingObserver {
  //these are actually defaults
  bool darkMode = true;
  bool forceContactUpdate = false;

  //NOTE: whatever is in here are ONLY placeholders
  ValueNotifier<ContactInput> contactInput = new ValueNotifier<ContactInput>(ContactInput.no);
  ValueNotifier<Contact> contact = new ValueNotifier<Contact>(new Contact());

  //init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //grab our initial contact
    contactInput.value = widget.contactInput;
    contact.value = widget.contact;

    //pop up the manual input IF no new contact
    //pop it up with the force passed to this

    //TODO...

    //whenever you change the contact also updates the UI
    contact.addListener((){
      print("--------------------------------------NAME CHAGNED");
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
      //we forced the user to get a contact
      //but they are back
      //which can only happen IF then were allowed back
      //but IF they were allowed back we still don't have our contact
      //so we can confidently imply that they chosse the manualy input option
      //TODO.a.sd.fkajsd.fjalsj
    }
  }

  @override
  Widget build(BuildContext context) {
    //theme changer
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    
    //button text
    String buttonText = contact.value.givenName;
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
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SelectContact(
                          contactInput: contactInput,
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
                            _themeChanger.setTheme(ThemeData.dark());
                          }
                          else{
                            _themeChanger.setTheme(ThemeData.light());
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