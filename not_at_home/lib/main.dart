import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: Container(
        child: FlatButton(
          onPressed: (){
            askPermission();
          },
          child: Text("test"),
        ),
      )
    );
  }

  static const MethodChannel channel = const MethodChannel('plugins.ly.com/permission');
  static const MethodChannel methodChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  askPermission()async{
    print("asking for permission");
    PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    print("start status: " + startStatus.toString());
    if(startStatus != PermissionStatus.allow || startStatus != PermissionStatus.always || startStatus != PermissionStatus.whenInUse){
      print("not granted");
      //-----
      DateTime start = DateTime.now();
      print("before request");
      List<Permissions> permissions = await Permission.requestPermissions([PermissionName.Contacts]);
      print("after request");
      DateTime end = DateTime.now();
      Duration timeforPopUpClose = end.difference(start);

      print("between: " + timeforPopUpClose.toString());

      //open app setting from other plugin      
      //methodChannel.invokeMethod('openAppSettings');
      Permission.openSettings(); 

      //open app settings froms this plugin


      /*
      bool showOtherUI = await PermissionHandler().shouldShowRequestPermissionRationale(PermissionGroup.contacts);
      print("show other UI: " + showOtherUI.toString());
      if(showOtherUI == false){
        PermissionStatus status = permissions[PermissionGroup.contacts];
        print("status: " + status.toString());
        if(status != PermissionStatus.granted){
          //---top
          print("------------------------ask for permission again");
          askPermission();
        }
      }
      else{
        print("--------------------will have to force permission");
      }
      */
      //-----
    }
    else print("----------------------already has permission");
  }
}

/*
SelectContact(
        forceSelection: true,
      ),
*/