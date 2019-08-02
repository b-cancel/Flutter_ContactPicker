import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/request.dart';
import 'selectContact/selectContactLogic.dart';
import 'package:not_at_home/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'helper.dart';

//IF true -> first forces you to select a contact and then lets you change it
//ELSE -> takes you directly into testing the toolkit in all other cases
bool testFirstPage = true;

//-----Start App
void main() => runApp(MyApp());

//-----Entry Point
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      //by default start off in dark mode
      builder: (_) => ThemeChanger(ThemeData.dark()),
      child: StatelessLink(),
    );
  }
}

//-----Statless Link Required Between Entry Point And App
class StatelessLink extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    getThemeColors(Theme.of(context));
    return MaterialApp(
      routes: {
        ContactDisplayHelper.routeName: (context) => ContactDisplayHelper(),
      },   
      title: 'Contact Picker',
      theme: theme.getTheme(),
      home: InitRouter(),
    );
  }
}

//-----Router to select contact or the page that will select them for testing purposes
//NOTE: if anyone reading this can find a cleaner way to do this that would be great
//I did it this way because I need to be able to push the ContactDisplay page with its name
//otherwise when I select a contact ill pop everything since the onSelect function in SelectContact
//is also expecting the route name of the page requesting the contact
class InitRouter extends StatefulWidget {
  InitRouter({Key key}) : super(key: key);

  _InitRouterState createState() => _InitRouterState();
}

class _InitRouterState extends State<InitRouter> {
  @override
  void initState() {
    //after build completes
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(testFirstPage){
        //we start the app by making the user select a contact
        Navigator.pushReplacement(
          context, 
          PageTransition(
            type: PageTransitionType.fade,
            duration: Duration(seconds: 0),
            //since this is how the app starts the user MUST select a contact
            child: SelectContact(
              selectContactBackUp: SelectContactBackUp.systemContactPicker,
              routeName: ContactDisplayHelper.routeName,
              forceSelection: true,
            ),
          ),
        );
      }
      else{
        Navigator.pushNamedAndRemoveUntil(
          context, 
          ContactDisplayHelper.routeName,
          (r) => false,
          arguments: ContactDisplayArgs(
            new Contact(),
          ),
        );
      }
    });
    
    //super init state
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}