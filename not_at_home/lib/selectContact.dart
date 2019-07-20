import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/helper.dart';
import 'package:not_at_home/permission.dart';
import 'package:not_at_home/request.dart';
import 'package:not_at_home/selectContactUX.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'contactTile.dart';
import 'main.dart';

/*
the onSelect function is set depending on whether or not we are on the first page
we know its the first page because we aren't passed a contact to update
IF first page -> we are passed a contact we want to update it (we can do so with a value notifier)
ELSE -> we want to open a new page
*/

/*
IF we force selection
  IF -> select contact came up on start up -> we dont want to stop the user from closing the app
  ELSE -> we dont want to allow the user to back up
ELSE -> user should be able to back away at any step
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
      onSelect = (BuildContext context, Contact contact){
        //1. update our passed contact
        widget.contactToUpdate.value = contact;
        //2. remove all other pages from the stack
        //   until we arrive at the page where we selected our contact from
        Navigator.popUntil(
          context, 
          ModalRoute.withName(ContactDisplayHelper.routeName),
        );

        //NOTE: #2 is made possible by using the guide below
        //https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments
      };
    }
    //try to get contacts
    confirmPermission();
  }

  //async init
  confirmPermission() async{
    if(await getContacts() != PermissionStatus.authorized){
      permissionRequired(
        context, 
        widget.forceSelection, 
        true,
        (){
          onSelect(context, new Contact());
        }
      );
    }
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

  //this is set TRUE right before we open up "NewContact"
  //that way if we pop we know that we had pushed it
  //when we use this to determine what to do on resume, we reset it back to false
  //we use a value notifier so we can pass by reference
  ValueNotifier<bool> backFromNewContactPage = new ValueNotifier<bool>(false);

  reactToResume() async{
    //IF -> we came back from the permissions page
    //  IF we now have permission -> refill the contacts list with our contacts
    //  ELSE -> EITHER manual input OR (back because not forced) [CAN ASSUME back because not forced]
    //    IF back because not forced -> we cant be here without the permissions so go back again to the previous page
    //    ELSE manual input -> this shouldn't even happen since it we will be popped instantly in this scenario
    //ELSE -> we came back from the create contact page
    //  nothing should really happen here

    //if we came back from the permissions page
    bool backFromPermissionPage = (backFromNewContactPage.value == false);
    if(backFromPermissionPage){
      print("back from permission page");
      if(await getContacts() != PermissionStatus.authorized){
        //Even after making it clear that the user needs to accept permission in order to use this feature
        //they didn't select manual input
        //and they didn't give us permssion so simply go back to the previous page
        //If this contact was REQUIRED then we would be here
        //so we know we can back up
        if(firstPage == false){
          Navigator.pop(context);
        }
      }
    }
    else{
      print("back from new contact");
      //NOTE: we might come back from it because our user decided to manually input their data
      //but in that case the manual input modal will pop up in the page requesting the contact
      //and everything else relating to select contact will be poped
      //so this being set to false isn't going to break anything either
      backFromNewContactPage.value = false;
    }
  }

  //NOTE: If rebuild fails then we are no longer mounted
  //hence all the if(rebuild(bool)) snippets
  Future<PermissionStatus> getContacts() async{
    PermissionStatus permissionStatus = await SimplePermissions.getPermissionStatus(Permission.ReadContacts);
    if(permissionStatus == PermissionStatus.authorized){
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
        backFromNewContact: backFromNewContactPage,
        onSelect: onSelect,
      ),
    );
  }
}