import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:not_at_home/helper.dart';
import 'package:not_at_home/newContact/categorySelect.dart';
import 'package:not_at_home/contactPermission.dart';
import 'package:not_at_home/request.dart';
import 'package:not_at_home/selectContact/selectContactUX.dart';
import 'package:permission/permission.dart';

/*
the onSelect function is set depending on whether or not we are on the first page
we know FIRST PAGE -> IF -> contactToUpdate == null

IF FIRST PAGE -> FORCE select a contact and pass our initial contact value to the receiving named route
ELSE -> (force or suggest) selection of a contact -> once the contact is updated we pop everything until the page that requested it
*/

/*
IF FORCE SELECTION
  IF FIRST PAGE -> we dont want to stop the user from closing the app
  ELSE -> we dont want to allow the user to back up (we know that are not trying to close the app)
ELSE -> user should be able to back away at any step
*/

enum SelectContactBackUp {manualInput, systemContactPicker}

class SelectContact extends StatefulWidget {
  SelectContact({
    @required this.userPrompt,
    @required this.routeName,
    @required this.forceSelection, 
    this.selectContactBackUp: SelectContactBackUp.manualInput,
    //if set -> then we know we are NOT IN THE FIRST PAGE
    this.contactToUpdate,
  });

  //required
  final List<String> userPrompt;
  final String routeName;
  final bool forceSelection;
  //IF the user does not want to give us permission
  //the can either, type the contact in manually
  //or use the system contact picker
  final SelectContactBackUp selectContactBackUp;
  //only if not first time
  final ValueNotifier<Contact> contactToUpdate;

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> with WidgetsBindingObserver {
  //contact list then gets passed UX
  ValueNotifier<bool> retreivingContacts = ValueNotifier(false);
  ValueNotifier<List<Contact>> contacts = ValueNotifier<List<Contact>>(new List<Contact>());

  //set based on whether or not a contact to update was passed
  bool firstPage;
  Function onSelect;

  //init
  @override
  void initState(){
    CategoryData.init(); //read all category data

    //super init
    super.initState(); 
    
    //observer for onResume
    WidgetsBinding.instance.addObserver(this); 
    //if no contact is passed then we know this is the first page
    firstPage = (widget.contactToUpdate == null);

    //NOTE... the onSelect function below is called when...
    //1. when the user decides they want to instead manually input the name
    //  - from the select contact page -> we can still pass in a contact that the user manually inputted
    //  - from the add contact page -> we can still pass in a contact the user is just choosing not to save it
    //2. when we select a contact from the contact list
    //3. when we add a contact

    //create the onSelect Function
    if(firstPage){ //we are selecting one for the first time
      onSelect = (BuildContext context, Contact contact){
        //NOTE: we have nothing to update

        //1. push our new page with our new contact
        //2. remove all other pages from the stack in the background
        Navigator.pushNamedAndRemoveUntil(
          context, 
          widget.routeName,
          (r) => false,
          arguments: ContactDisplayArgs(
            contact,
          ),
        );
      };
    }
    else{ //we may or may not be updating or selecting it for the first time
      onSelect = (BuildContext context, Contact contact){
        //1. update our passed info from the page requesting this
        widget.contactToUpdate.value = contact;
        
        //2. remove all other pages from the stack
        //   until we arrive at the page where we selected our contact from
        Navigator.popUntil(
          context, 
          ModalRoute.withName(
            widget.routeName,
          ),
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
    PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    if(isAuthorized(permissionStatus) == false){
      checkContactPermission(
        context, 
        widget.forceSelection, //we force selection
        true, //we are selecting
        onSelect, //we will pass a context and contact to the this function after manual input
        selectContactBackUp: widget.selectContactBackUp,
      );
    }
    else getContacts();
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
  ValueNotifier<bool> backFromPageNOTpermissionPage = new ValueNotifier<bool>(false);

  reactToResume() async{
    //IF -> we came back from the permissions page
    //  IF we now have permission -> refill the contacts list with our contacts
    //  ELSE -> EITHER manual input OR (back because not forced) [CAN ASSUME back because not forced]
    //    IF back because not forced -> we cant be here without the permissions so go back again to the previous page
    //    ELSE manual input -> this shouldn't even happen since it we will be popped instantly in this scenario
    //ELSE -> we came back from the create contact page
    //  nothing should really happen here

    //if we came back from the permissions page
    bool backFromPermissionPage = (backFromPageNOTpermissionPage.value == false);
    if(backFromPermissionPage){
      PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
      if(isAuthorized(permissionStatus) == false){
        //the permission page did not get the users permission
        //the user either backed up from the page OR selected manual input
        //we already handle the manual input case with the onSelect we pass the permssions page
        //so the only case we could be handling here is the use backing up case
        //since backing up is not allowed if the contact is required
        //we know the contact isnt required

        //Even after making it clear that the user needs to accept permission in order to use this feature
        //they didn't select manual input and they didn't give us permssion 
        //so simply go back to the previous page

        //If this contact was REQUIRED then we would NOT be here
        //so we know we can back up
        if(firstPage == false){
          Navigator.pop(context);
        }
      } //got the users permission
      else getContacts();
    }
    else{
      //NOTE: we might come back from it because our user decided to manually input their data
      //but in that case the manual input modal will pop up in the page requesting the contact
      //and everything else relating to select contact will be poped
      //so this being set to false isn't going to break anything either

      //if we are instead comming back from it because we no longer want to select a user by adding them
      //then this is the appropiate action
      backFromPageNOTpermissionPage.value = false;
    }
  }

  //NOTE: If rebuild fails then we are no longer mounted
  //hence all the if(rebuild(bool)) snippets

  //starts the process
  getContacts() async{
    PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    if(isAuthorized(permissionStatus)){

      //clear the contacts list
      contacts.value.clear();

      //tell the user the contacts are being retreived
      if(rebuildList(true)){

        //get the contacts (WITHOUT THUMBNAILS)
        contacts.value = (await ContactsService.getContacts(
          withThumbnails: false,
        )).toList(); 

        //don't tell the user we are retreiving contacts 
        //because technically now we are just updating contacts
        if(rebuildList(false)){

          //get the contacts (WITH THUMBNAILS)
          contacts.value = (await ContactsService.getContacts(
            photoHighResolution: false,
          )).toList(); 

          /*
          //updte contacts the last time
          if(rebuildList(false)){

            //get the contacts (WITH HIGH QUALITY THUMBNAILS)
            contacts.value = (await ContactsService.getContacts(
              photoHighResolution: true,
            )).toList(); 
          }
          */
        }
      }
    }
  }

  bool rebuildList(bool isRetreiving){
    if(mounted){
      retreivingContacts.value = isRetreiving;
      return true;
    }
    else return false;    
  }

  //build
  @override
  Widget build(BuildContext context) {
    //pass the widgets
    return WillPopScope(
      //IF first page I should be able to close the app
      //ELSE -> I block the user from going back IF forceSelection is enabled
      onWillPop: () async => !(widget.forceSelection && !firstPage),
      child: SelectContactUX(
        //value notifiers that will be listened to below in the tree
        retreivingContacts: retreivingContacts,
        contacts: contacts,
        backFromPageNOTpermissionPage: backFromPageNOTpermissionPage,
        //passed once and done
        onSelect: onSelect,
        userPrompt: widget.userPrompt,
      ),
    );
  }
}