import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:not_at_home/request.dart';
import 'package:not_at_home/selectContactUX.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contactTile.dart';
import 'main.dart';

//---NEW NOTES

//onSelect -> if we are passed a contact we want to update it
//         -> else we want to open a new page

//the only way we can update that new contact from either the select or new contact page
//is if we are passed the value notifier

//IF we are not passed a contact to update we know its the first page

//---NEW NOTES

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
    this.forceSelection: false,
    //if this is set then we know we are not in the first page
    this.contactToUpdate,
  });

  final bool forceSelection;
  final ValueNotifier<Contact> contactToUpdate;

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> with WidgetsBindingObserver {
  //contact list then gets passed UX
  bool retreivingContacts = false;
  List<Contact> contacts = new List<Contact>();
  List<Color> colorsForContacts = new List<Color>();

  //set based on whether or not a contact to update was passed
  bool firstPage;
  Function onSelect;

  //init
  @override
  void initState(){ 
    //super init
    super.initState(); 
    //observer for onResume
    WidgetsBinding.instance.addObserver(this); 
    //if no contact is passed then we know this is the first page
    firstPage = (widget.contactToUpdate == null);
    //create the onSelect Function
    if(firstPage){
      print("-------------CREATING");
      onSelect = (BuildContext context, Contact contact){
        //1. push our new page with our new contact
        //2. remove all other pages from the stack in the background
        Navigator.pushNamedAndRemoveUntil(
          context, 
          ContactDisplayHelper.routeName,
          (r) => false,
          arguments: ContactDisplayArgs(contact),
        );
      };
    }
    else{
      print("-------------UPDATING");
      onSelect = (BuildContext context, Contact contact){
        //1. update our passed contact
        widget.contactToUpdate.value = contact;
        //2. remove all other pages from the stack
        //   until we arrive at the page where we selected our contact from
        Navigator.popUntil(context, ModalRoute.withName(ContactDisplayHelper.routeName));

        //NOTE: #2 is made possible by using the guide below
        //https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments
      };
    }
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

  //-------------------------Everything above is airtight-------------------------

  //this is set TRUE right before we open up "NewContact"
  //that way if we pop we know that we had pushed it
  //when we use this to determine what to do on resume, we reset it back to false
  //we use a value notifier so we can pass by reference
  ValueNotifier<bool> backFromNewContact = new ValueNotifier<bool>(false);

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
      print("not back from new contact");
      PermissionStatus permissionStatus = await getContacts();
      if(permissionStatus != PermissionStatus.granted){
        //-------------------------
        //TODO... complete edge cases
        //-------------------------
      }
    }
    else{
      print("back from new contact");
      backFromNewContact.value = false;
    }
  }

  //NOTE: If rebuild fails then we are no longer mounted
  //hence all the if(rebuild()) snippets
  Future<PermissionStatus> getContacts() async{
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    if(permissionStatus == PermissionStatus.granted){
      contacts.clear();

      //inform the user we are getting the contacts
      if(rebuild(true)){

        //get the contacts (WITHOUT THUMBNAILS)
        Iterable<Contact> temp = await ContactsService.getContacts(
          withThumbnails: false,
        ); 
        contacts = temp.toList();

        //assign a color to each contact
        for(int i = 0; i < contacts.length; i++){
          colorsForContacts.add(theColors[rnd.nextInt(theColors.length)]);
        }

        //inform the user we have the contacts
        if(rebuild(false)){

          //get the contacts (WITH THUMBNAILS)
          temp = await ContactsService.getContacts(
            photoHighResolution: false,
          ); 
          contacts = temp.toList();

          //inform the user we have the contacts
          if(rebuild(false)){
            
            //get the contacts (WITH HIGH RESOLUTION THUMBNAILS)
            temp = await ContactsService.getContacts(); 
            contacts = temp.toList();
            //inform the user we have the contacts
            rebuild(false);
          }
        }
      }
    }
    return permissionStatus;
  }

  bool rebuild(bool isRetreiving){
    if(mounted){
      setState(() {
        retreivingContacts = isRetreiving;
      });
      return true;
    }
    else return false;    
  }

  //build
  @override
  Widget build(BuildContext context) {
    //convert the retreived contacts into widgets
    List<Widget> contactWidgets = new List<Widget>();

    //for each contact that we do have create the appropriate widget
    for(int i = 0; i < contacts.length; i++){
      contactWidgets.add(
        ContactListTile(
          thisContact: contacts[i],
          thisColor: colorsForContacts[i],
          onSelect: onSelect,
        ),
      );
    }

    //pass the widgets
    return WillPopScope(
      //IF first page I should be able to close the app
      //ELSE -> I block the user from going back IF forceSelection is enabled
      onWillPop: () async => !(widget.forceSelection && !firstPage),
      child: SelectContactUX(
        retreivingContacts: (contacts == null),
        contactWidgets: contactWidgets,
        backFromNewContact: backFromNewContact,
      ),
    );
  }
}