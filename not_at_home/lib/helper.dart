import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:permission_handler/permission_handler.dart';

/*
bool isAuthorized(PermissionStatus status){
  if(status == PermissionStatus.allow) return true;
  else if(status == PermissionStatus.always) return true;
  else if(status == PermissionStatus.whenInUse) return true;
  else return false;
}
*/

bool isAuthorized(PermissionStatus status){
  return (status == PermissionStatus.granted);
}

//-----Prefixes
Set<String> prefixes = new Set<String>();
getPrefixes(){
  prefixes = new Set<String>();
  prefixes.add("master");
  prefixes.add("mr");
  prefixes.add("mister");
  prefixes.add("miss");
  prefixes.add("mrs");
  prefixes.add("mx");
  prefixes.add("m");
  prefixes.add("sir");
  prefixes.add("gentleman");
  prefixes.add("sire");
  prefixes.add("mistress");
  prefixes.add("madam");
  prefixes.add("maam");
  prefixes.add("dame");
  prefixes.add("lord");
  prefixes.add("lady");
  prefixes.add("esq");
  prefixes.add("esquire");
  prefixes.add("excellency");
  prefixes.add("doctor");
  prefixes.add("dr");
  prefixes.add("prof");
  prefixes.add("prof");
  prefixes.add("professor");
}

String onlyCharacters(String string){
  String output = "";
  for(int i = 0; i < string.length; i++){
    int code = string[i].codeUnitAt(0);
    if(97 <= code && code <= 122){
      output += string[i];
    }
  }
  return output;
}

bool firstWordIsPrefix(String string){
  string = string.split(" ")[0]; //get first word
  string = onlyCharacters(string); //get only characters
  string = string.toLowerCase(); //to lower case
  return prefixes.contains(string); //return
}

//-----Colors of Theme
List<Color> theColors;

getThemeColors(ThemeData themeData){
  theColors = new List<Color>();
  theColors.add(themeData.accentColor);
  theColors.add(themeData.backgroundColor);
  theColors.add(themeData.canvasColor);
  theColors.add(themeData.cardColor);
  theColors.add(themeData.cursorColor);
  theColors.add(themeData.bottomAppBarColor);
  theColors.add(themeData.buttonColor);
  theColors.add(themeData.dialogBackgroundColor);
  theColors.add(themeData.disabledColor);
  theColors.add(themeData.dividerColor);
  theColors.add(themeData.errorColor);
  theColors.add(themeData.focusColor);
  theColors.add(themeData.highlightColor);
  theColors.add(themeData.hintColor);
  theColors.add(themeData.hoverColor);
  theColors.add(themeData.indicatorColor);
  theColors.add(themeData.primaryColor);
  theColors.add(themeData.primaryColorDark);
  theColors.add(themeData.primaryColorLight);
  theColors.add(themeData.scaffoldBackgroundColor);
  theColors.add(themeData.secondaryHeaderColor);
  theColors.add(themeData.selectedRowColor);
  theColors.add(themeData.splashColor);
  theColors.add(themeData.textSelectionColor);
  theColors.add(themeData.textSelectionHandleColor);
  theColors.add(themeData.toggleableActiveColor);
  theColors.add(themeData.unselectedWidgetColor);
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