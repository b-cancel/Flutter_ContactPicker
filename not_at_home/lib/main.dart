import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/request.dart';
import 'package:not_at_home/selectContact.dart';
import 'package:not_at_home/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;

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
    theColors = getThemeColors(Theme.of(context));
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
}

//-----Colors of Theme
List<Color> theColors;

List<Color> getThemeColors(ThemeData themeData){
  List<Color> colors = new List<Color>();
  colors.add(themeData.accentColor);
  colors.add(themeData.backgroundColor);
  colors.add(themeData.canvasColor);
  colors.add(themeData.cardColor);
  colors.add(themeData.cursorColor);
  colors.add(themeData.bottomAppBarColor);
  colors.add(themeData.buttonColor);
  colors.add(themeData.dialogBackgroundColor);
  colors.add(themeData.disabledColor);
  colors.add(themeData.dividerColor);
  colors.add(themeData.errorColor);
  colors.add(themeData.focusColor);
  colors.add(themeData.highlightColor);
  colors.add(themeData.hintColor);
  colors.add(themeData.hoverColor);
  colors.add(themeData.indicatorColor);
  colors.add(themeData.primaryColor);
  colors.add(themeData.primaryColorDark);
  colors.add(themeData.primaryColorLight);
  colors.add(themeData.scaffoldBackgroundColor);
  colors.add(themeData.secondaryHeaderColor);
  colors.add(themeData.selectedRowColor);
  colors.add(themeData.splashColor);
  colors.add(themeData.textSelectionColor);
  colors.add(themeData.textSelectionHandleColor);
  colors.add(themeData.toggleableActiveColor);
  colors.add(themeData.unselectedWidgetColor);
  return colors;
}

//-----Random Number
math.Random rnd = math.Random();

//-----Dummy Test Contact
Contact dummyContact = Contact(
  givenName: "givenName",
  middleName: "middleName",
  familyName: "familyName",
  prefix: "prefix",
  suffix: "suffix",
  company: "company",
  jobTitle: "job title",
  //emails
  //phones
  //addresses
  note: "note",
);

Contact getDummyContact(){
  List<Item> phones = new List<Item>();

  phones.add(Item(label: "mobile", value: "956 777 2692"));
  dummyContact.phones = phones;

  List<Item> emails = new List<Item>();
  emails.add(Item(label: "email", value: "some@s.com"));
  dummyContact.emails = emails;

  List<PostalAddress> addresses = new List<PostalAddress>();
  addresses.add(
    PostalAddress(
      label: "label", 
      street: "street", 
      city: "city", 
      postcode: "78912", 
      region: "region", 
      country: 'US',
    ),
  );

  return dummyContact;
}