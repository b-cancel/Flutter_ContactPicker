import 'dart:io';

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
      home: SelectContact(
        forceSelection: true,
      ),
    );
  }

  //PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
  //List<Permissions> permissions = await Permission.requestPermissions([PermissionName.Contacts]);
}