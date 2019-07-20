import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:permission/permission.dart';

import 'helper.dart';
import 'imagePicker.dart';

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
        false, 
        false, //we are creating a contact
        (){
          widget.onSelect(context, newContact);
        }
      );
    }
  }

  //---Name section open and closing
  ValueNotifier<bool> namesSpread = new ValueNotifier<bool>(false);

  //---Name Focus Nodes
  FocusNode nameFocusNode = new FocusNode();

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
          FocusScope.of(context).requestFocus(nameFocusNode);
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
      if(backFromPermissionPage.value){
        backFromPermissionPage.value = false;
        PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
        if(isAuthorized(permissionStatus)){
          saveContact();
        }
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

        //react
        if(isPortrait == false) bottomBarHeight = 0;

        double imageDiameter = MediaQuery.of(context).size.width / 2;
        if(isPortrait == false){
          imageDiameter = MediaQuery.of(context).size.height / 2;
        }

        //build
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[
              //Cancel Buton
              isPortrait == false ? 
              new Action(
                func: (){
                  Navigator.maybePop(context);
                }, 
                str: "Cancel",
              )
              : Container(),
              //Save Button
              isPortrait == false ? 
              new Action(
                func: () => saveContact(), 
                str: "Save",
              )
              : Container()
            ],
          ),
          body: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          8,
                          imageDiameter * (5/7),
                          8,
                          16,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Card(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                  0, 
                                  imageDiameter * (2/7) + 16 * 2, 
                                  16, 
                                  0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    new Title(
                                      icon: Icons.person,
                                      name: "Name",
                                    ),
                                    //displayName, givenName, middleName, prefix, suffix, familyName;
                                    //Name prefix(prefix), Name suffix(suffix)
                                    //First name (givenName), Middle name (middleName), Last name (familyName)
                                    //display name = prefix, first name, middle name, last name, ',' suffix
                                    Visibility(
                                      visible: (namesSpread.value == false),
                                      child: new NameRow(
                                        bottomBarHeight: bottomBarHeight,
                                        nameOpen: namesSpread,
                                        icon: Icons.keyboard_arrow_down,
                                        label: "Name",
                                        focusNode: nameFocusNode,
                                        controller: nameCtrl,
                                      ),
                                    ),
                                    Visibility(
                                      visible: namesSpread.value,
                                      child: Column(
                                        children: <Widget>[
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: namesSpread,
                                            icon: Icons.keyboard_arrow_up,
                                            label: "Name prefix",
                                            focusNode: prefixFC,
                                            controller: prefixCtrl,
                                          ), 
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: namesSpread,
                                            label: "First name",
                                            focusNode: firstFC,
                                            controller: firstCtrl,
                                          ),
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: namesSpread,
                                            label: "Middle name",
                                            focusNode: middleFC,
                                            controller: middleCtrl,
                                          ),
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: namesSpread,
                                            label: "Last name",
                                            focusNode: lastFC,
                                            controller: lastCtrl,
                                          ),
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: namesSpread,
                                            label: "Name suffix",
                                            focusNode: suffixFC,
                                            controller: suffixCtrl,
                                          ),  
                                        ],
                                      ),
                                    ),
                                    new Title( 
                                      icon: Icons.work,
                                      name: "Work",
                                      onPressed: (){
                                        print("tapped");
                                      }
                                    ),
                                    new Title( 
                                      icon: Icons.phone,
                                      name: "Phone",
                                      onPressed: (){
                                        print("tapped");
                                      }
                                    ),
                                    new Title( 
                                      icon: Icons.email,
                                      name: "Email",
                                      onPressed: (){
                                        print("tapped");
                                      }
                                    ),
                                    new Title( 
                                      icon: Icons.location_on,
                                      name: "Address",
                                      onPressed: (){
                                        print("tapped");
                                      }
                                    ),
                                  ],
                                )
                              ),
                            ),
                            //makes sure that we can always see all of our items
                            //with a little extra padding for looks
                            Container(
                              height: bottomBarHeight + 16,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: (){
                            showImagePicker(
                              context,
                              imageLocation,
                              (){
                                setState(() {
                                  
                                });
                              }
                            );
                          },
                          child: Stack(
                            children: <Widget>[
                              new Container(
                                width: imageDiameter,
                                height: imageDiameter,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).indicatorColor,
                                  shape: BoxShape.circle,
                                ),
                                child: (imageLocation.value == "") ? Icon(
                                  Icons.camera_alt,
                                  size: imageDiameter / 2,
                                  color: Theme.of(context).primaryColor,
                                )
                                : ClipOval(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                      child: Image.file(
                                      File(imageLocation.value),
                                    ),
                                  )
                                )
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: new Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    border: Border.all(
                                      width: 3,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Visibility(
                  visible: isPortrait,
                  child: Container(
                    color: Theme.of(context).primaryColorDark,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left:16, right:16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new BottomButton(
                          width: MediaQuery.of(context).size.width / 2 - 16,
                          name: "Cancel",
                          onPressed: (){
                            Navigator.maybePop(context);
                          },
                        ),
                        new BottomButton(
                          width: MediaQuery.of(context).size.width / 2 - 16,
                          name: "Save",
                          onPressed: () => saveContact(),
                        ),
                      ],
                    )
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Action extends StatelessWidget {
  const Action({
    Key key,
    @required this.func,
    @required this.str,
  }) : super(key: key);

  final Function func;
  final String str;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        func();
      },
      child: Text(str),
    );
  }
}

IconData down = Icons.keyboard_arrow_down;
IconData up = Icons.keyboard_arrow_up;

class NameRow extends StatelessWidget {
  const NameRow({
    Key key,
    @required this.bottomBarHeight,
    this.icon,
    this.label,
    this.nameOpen,
    this.focusNode,
    this.controller,
  }) : super(key: key);

  final double bottomBarHeight;
  final IconData icon;
  final String label;
  final ValueNotifier<bool> nameOpen;
  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          IconWidget(),
          Flexible(
            child: TextFormField(
              focusNode: focusNode,
              controller: controller,
              scrollPadding: EdgeInsets.only(bottom: bottomBarHeight * 2 + 8),
              autofocus: true,
              style: TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 4),
                hintText: label,
                hintStyle: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              if(icon == down){
                nameOpen.value = true;
              }
              else if(icon == up){
                nameOpen.value = false;
              }
            },
            child: IconWidget(
              icon: icon,
              right: 16,
              left: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final String name;
  final Function onPressed;
  final double width;

  const BottomButton({
    this.name,
    this.onPressed,
    this.width,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: new OutlineButton(
        child: new Text(
          name,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        onPressed: onPressed,
        highlightedBorderColor: Colors.transparent,
        disabledBorderColor: Colors.transparent,
        borderSide: BorderSide(style: BorderStyle.none),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}

class IconWidget extends StatelessWidget {
  final double left;
  final double right;
  final IconData icon;

  IconWidget({
    this.left,
    this.right,
    this.icon,
  });

  @override
  Widget build(BuildContext context) { 
    Color iconColor;
    if(icon == null){
      iconColor = Colors.transparent;
    }
    else{
      iconColor = Theme.of(context).primaryColorLight;
    }

    //return widget
    return Container(
      padding: EdgeInsets.only(
        left: left ?? 16,
        right: right ?? 8,
      ),
      child: Icon(
        icon ?? Icons.lock,
        color: iconColor,
      ),
    );
  }
}

class Title extends StatelessWidget {
  final IconData icon;
  final String name;
  final Function onPressed;

  const Title({
    this.icon,
    this.name,
    this.onPressed,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Container theTitle = Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );

    //whether or not the area is clickable
    if(onPressed == null) return theTitle;
    else{
      return InkWell(
        onTap: onPressed,
        child: theTitle,
      );
    }
  }
}