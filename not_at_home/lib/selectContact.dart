import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:not_at_home/selectContactUX.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contactTile.dart';
import 'main.dart';

/*
  NOTE: this app is designed specifically for 2 cases
  case 1: select a contact on start up, once its selected we cant access the contact selection items
  case 2: select a contact from a page, and go back to that page (by poping)

  So case 3 below is NOT covered
  case 3: select a contact from a page, and go to another page 

  So...
  Case 1 is identified with a the firstPage boolean
  Case 2 is the inverse
*/

/*
IF we force selection
  IF -> select contact came up on start up -> we dont want to stop the user from closing the app
  ELSE -> we dont want to allow the user to back up
-----TODO Below (once we implement on start up)
ELSE -> the user should be able to back away from the selection process at any stage
  IF we already have permission -> they should be able to easily back away from the page
  ELSE -> they should be able to easily back away from the
    1. page with the permissions pop up
    2. and the page that comes up IF you block the pop up
-----TODO Above
*/

class SelectContact extends StatefulWidget {
  SelectContact({
    this.firstPage: false,
    this.forceSelection: false,
    @required this.contact,
  });

  final firstPage;
  final bool forceSelection;
  final ValueNotifier<Contact> contact;

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> with WidgetsBindingObserver {
  //this is set TRUE right before we open up "NewContact"
  //that way if we pop we know that we had pushed it
  //when we use this to determine what to do on resume, we reset it back to false
  //we use a value notifier so we can pass by reference
  ValueNotifier<bool> backFromNewContact = new ValueNotifier<bool>(false);

  //contact list then gets passed UX
  bool retreivingContacts = false;
  List<Contact> contacts = new List<Contact>();

  //init
  @override
  void initState(){ 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  //async init
  init() async{
    await getContacts();
    permissionRequired(context, widget.forceSelection);
  }

  //dispose
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) reactToResume();
  }

  reactToResume() async{
    //IF -> we came back from the permissions page
    //  IF we now have permission -> refill the contacts list with our contacts
    //-------------------------TODO below
    //  ELSE -> EITHER manual input OR (back because not forced)
    //    IF back because not forced -> we cant be here without the permissions so go back again to the previous page
    //    ELSE manual input
    //      IF first page -> go to the next page and bring up the manual input pop up (which should be in any page that is requesting a contact)
    //      ELSE -> go to the previous page and bring pu the manual input pop up (which should be in any page that is requesting a contact)
    //-------------------------TODO above
    //ELSE -> we came back from the create contact page
    //  nothing should really happen here

    //if we came back from the permissions page
    if(backFromNewContact.value == false){
      PermissionStatus permissionStatus = await getContacts();
      if(permissionStatus != PermissionStatus.granted){
        //-------------------------
        //TODO... complete edge cases
        //-------------------------
      }
    }
    else backFromNewContact.value = false;
  }

  Future<PermissionStatus> getContacts() async{
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    if(permissionStatus == PermissionStatus.granted){
      contacts.clear();

      //inform the user we are getting the contacts
      rebuild(true);

      //get the contacts (WITHOUT THUMBNAILS)
      Iterable<Contact> temp = await ContactsService.getContacts(
        withThumbnails: false,
      ); 
      contacts = temp.toList();
      //inform the user we have the contacts
      rebuild(false);

      //get the contacts (WITH THUMBNAILS)
      temp = await ContactsService.getContacts(
        photoHighResolution: false,
      ); 
      contacts = temp.toList();
      //inform the user we have the contacts
      rebuild(false);

      //get the contacts (WITH HIGH RESOLUTION THUMBNAILS)
      temp = await ContactsService.getContacts(); 
      contacts = temp.toList();
      //inform the user we have the contacts
      rebuild(false);
    }
    return permissionStatus;
  }

  rebuild(bool isRetreiving){
    setState(() {
      retreivingContacts = isRetreiving;
    });
  }

  //build
  @override
  Widget build(BuildContext context) {
    //convert the retreived contacts into widgets
    List<Widget> contactWidgets = new List<Widget>();
    if(contacts == null || contacts.length == 0){
      contactWidgets.add(
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            (retreivingContacts) ? "Retreiving Contacts" : "No Contacts Found",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        )
      );
    }
    else{
      //for each contact that we do have create the appropriate widget
      for(int i = 0; i < contacts.length; i++){
        contactWidgets.add(
          ContactListTile(
            context: context, 
            contact: contacts[i],
          ),
        );
      }
    }

    //pass the widgets
    return WillPopScope(
      //IF first page I should be able to close the app
      //ELSE -> I block the user from going back IF forceSelection is enabled
      onWillPop: () async => !(widget.forceSelection && !widget.firstPage),
      child: SelectContactUX(
        contactWidgets: contactWidgets,
        backFromNewContact: backFromNewContact,
      ),
    );
  }
}