import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:permission/permission.dart';

import 'helper.dart';
import 'newContactUX.dart';

/*
We only confirm and request access to contacts before we save and pass it
If we already have access we save the contact and run onselect
ELSE we request access

Whenever we request access we also want to customize the permission page
Because manual input from here can simply mean that we run onSelect without actually saving the contact
which isnt ideal but it does the trick if the user simply doesn't want to grant us access for whatever reason
*/

/*
When we come back from requesting access
IF we have access now we save the contact and run onselect
ELSE we wait for the user to decide to go back
  NOTE: we could go all the back into contact selection BUT
  the pain of the software going back and erasing all the new contact work
  is going to be much worse than the pain of clicking back again because you don't want to grant access
*/

class NewContact extends StatefulWidget {
  NewContact({
    @required this.onSelect,
  });

  final Function onSelect;

  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> with WidgetsBindingObserver {
  //---Image
  ValueNotifier<String> imageLocation = new ValueNotifier<String>("");

  //---Names
  TextEditingController nameCtrl = new TextEditingController(); //givenName

  TextEditingController prefixCtrl = new TextEditingController(); //prefix
  TextEditingController firstCtrl = new TextEditingController(); //displayName
  TextEditingController middleCtrl = new TextEditingController(); //middleName
  TextEditingController lastCtrl = new TextEditingController(); //familyName
  TextEditingController suffixCtrl = new TextEditingController(); //suffix

  //---Work
  TextEditingController companyCtrl = new TextEditingController(); //company
  TextEditingController jobTitleCtrl = new TextEditingController(); //jobTitle

  //---Lists
  List<Item> phones = new List<Item>(); //phones
  List<Item> emails = new List<Item>(); //emails
  List<PostalAddress> addresses = new List<PostalAddress>(); //addresses

  //---Note
  TextEditingController noteCtrl = new TextEditingController(); //note

  //---Contact Save Functionality
  saveContact() async{
    //create empty contact
    Contact newContact = new Contact();

    //save the image
    if(imageLocation.value != ""){
      List<int> avatarList = await File(imageLocation.value).readAsBytes();
      newContact.avatar = Uint8List.fromList(avatarList);
    }

    //save the name(s)
    newContact.givenName = nameCtrl.text;
    newContact.prefix = nameCtrl.text;
    newContact.displayName = firstCtrl.text;
    newContact.middleName = middleCtrl.text;
    newContact.familyName = lastCtrl.text;
    newContact.suffix = suffixCtrl.text;

    //save the work stuff
    newContact.company = companyCtrl.text;
    newContact.jobTitle = jobTitleCtrl.text;

    //save the lists
    newContact.phones = phones;
    newContact.emails = emails;
    newContact.postalAddresses = addresses;

    //save the note
    newContact.note = noteCtrl.text;

    //TODO... remove this test code
    // The contact must have a firstName / lastName to be successfully added
    if(newContact.givenName == "") newContact.givenName = "given";
    if(newContact.displayName == "") newContact.displayName = "display";
    if(newContact.familyName == "") newContact.familyName = "family";

    //handle permissions
    PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    if(isAuthorized(permissionStatus)){
      //with permission we can both
      //1. add the contact
      await ContactsService.addContact(newContact);  
      //2. and update the contact
      widget.onSelect(context, newContact);
    }
    else{
      //we know that we don't have permission so we know either the modal or page will pop up
      backFromPermissionPage.value = true;

      //without permission we give the user the option to ONLY
      //1. update the contact
      permissionRequired(
        context,
        //the user is never forced to create a contact, only to select one
        false, 
        false, //we are creating a contact
        (){
          //on Select only updates the contact
          //or the user can give us permission and come back and add it as well
          widget.onSelect(context, newContact);
        }
      );
    }
  }

  //---Name section open and closing
  ValueNotifier<bool> namesSpread = new ValueNotifier<bool>(false);

  //---Name Focus Nodes
  FocusNode nameFC = new FocusNode();

  FocusNode prefixFC = new FocusNode();
  FocusNode firstFC = new FocusNode();
  FocusNode middleFC = new FocusNode();
  FocusNode lastFC = new FocusNode();
  FocusNode suffixFC = new FocusNode();

  @override
  void initState() {
    //observer for onResume
    WidgetsBinding.instance.addObserver(this); 

    //if we spread or unspread the name
    namesSpread.addListener((){
      //actually open the names
      setState(() {});
      //focus on the proper name
      WidgetsBinding.instance.addPostFrameCallback((_){
        //Feature copied for samsung contacts
        if(namesSpread.value){
          //if all the names have been spread
          //TODO... break apart all the names
          //focus on the first name
          FocusScope.of(context).requestFocus(firstFC);
        }
        else{
          //If all the names have been close
          //TODO... combine all the names into a single name in nameFocusNode
          //then focus on the combined names
          FocusScope.of(context).requestFocus(nameFC);
        }
      });
    });
    super.initState();
  }

  //dispose
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //keep track of whether or not we returned from the permissions page
  ValueNotifier<bool> backFromPermissionPage = new ValueNotifier<bool>(false);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /*
    IF we have access now we save the contact and run onselect
    ELSE we wait for the user to decide what to do
    */
    if(state == AppLifecycleState.resumed) onResume();
  }

  //this run even if the image picker modal is above it
  //which is why we need the 2 variables
  onResume() async{
    print("*************************NEW CONTACT RESUME");
    if(backFromPermissionPage.value){
      backFromPermissionPage.value = false;
      PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;

      //since the permissions page was brought up because the user wanted to save the contact
      //we can imply the user wants to save the contact immediately after ther permissions page
      //WITHOUT making any changes
      if(isAuthorized(permissionStatus)){
        saveContact();
      }
      //ELSE... we might let them just go back, edit the contact, or etc
    }
    //ELSE we are back from either picking an image or deciding not to pick an image, both of which do nothing
  }

  //-------------------------Everything Above Is OK-------------------------

  @override
  Widget build(BuildContext context) {
    double bottomBarHeight = 32;

    return OrientationBuilder(
      builder: (context, orientation) {
        bool isPortrait = (orientation == Orientation.portrait);

        //cal bottom bar height
        if(isPortrait == false) bottomBarHeight = 0;
        else bottomBarHeight = 32;

        //calc imageDiameter
        double imageDiameter = MediaQuery.of(context).size.width / 2;
        if(isPortrait == false){
          imageDiameter = MediaQuery.of(context).size.height / 2;
        }

        //make new contact UX
        Widget bodyWidget = NewContactUX(
          imageDiameter: imageDiameter,
          bottomBarHeight: bottomBarHeight,
          imageLocation: imageLocation,
          isPortrait: isPortrait,
          contactSaved: () => saveContact(),
          imagePicked: (){
            setState(() {
              
            });
          },
          namesSpread: namesSpread,

          nameFC: nameFC,
          prefixFC: prefixFC,
          firstFC: firstFC,
          middleFC: middleFC,
          lastFC: lastFC,
          suffixFC: suffixFC,

          nameCtrl: nameCtrl,
          prefixCtrl: prefixCtrl,
          firstCtrl: firstCtrl,
          middleCtrl: middleCtrl,
          lastCtrl: lastCtrl,
          suffixCtrl: suffixCtrl,
        );

        //react to isPortrait
        if(isPortrait){
          return Scaffold(
            body: bodyWidget,
          );
        }
        else{
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: <Widget>[
                //Cancel Buton
                isPortrait == false ? 
                new ActionButton(
                  func: (){
                    Navigator.maybePop(context);
                  }, 
                  str: "Cancel",
                )
                : Container(),
                //Save Button
                isPortrait == false ? 
                new ActionButton(
                  func: () => saveContact(), 
                  str: "Save",
                )
                : Container()
              ],
            ),
            body: bodyWidget,
          );
        }
      }
    );
  }
}