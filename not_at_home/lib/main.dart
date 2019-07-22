/*
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';

//-----Start App
void main() => runApp(MyApp());

//-----Entry Point
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Link();
  }
}

//-----Statless Link so we can use Media Query
class Link extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StatelessLink(),
      ),
    );
  }
}

//-----Statless Link Required Between Entry Point And App
class StatelessLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        askPermission();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Text(
          "tap to run requet permission",
          style: TextStyle(
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  final ValueNotifier<bool> firstTime = new ValueNotifier<bool>(true);

  bool isAllowed(PermissionStatus status){
    if(status == PermissionStatus.allow) return true; 
    else if(status == PermissionStatus.always) return true; 
    else if(status == PermissionStatus.whenInUse) return true;
    else return false;
  }

  askPermission()async{
    print("asking for permission");
    PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    print("start status: " + startStatus.toString());
    if(firstTime.value || isAllowed(startStatus) == false){
      print("----------------------does not yet have permission");
      List<Permissions> permissions = await Permission.requestPermissions([PermissionName.Contacts]);
    }
    else print("----------------------already has permission");
  }
}
*/

import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:not_at_home/request.dart';
import 'package:not_at_home/selectContact.dart';
import 'package:not_at_home/theme.dart';
import 'package:permission/permission.dart';
import 'package:provider/provider.dart';

import 'helper.dart';

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
class StatelessLink extends StatelessWidget {
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
      home: Test(),
      
      /*
      SelectContact(
        forceSelection: true,
      ),
      */
    );
  }
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        permissionRequired(
            context, 
            true, 
            true,
            (){
              print("selected");
            }
          );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Text(
          "test",
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}