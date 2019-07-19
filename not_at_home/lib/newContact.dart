import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

class NewContact extends StatefulWidget {
  NewContact({
    this.contact,
  });

  final ValueNotifier<Contact> contact;

  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  ValueNotifier<bool> nameOpen = new ValueNotifier<bool>(false);

  //---Focus Nodes
  FocusNode nameFocusNode = new FocusNode();

  FocusNode prefixFC = new FocusNode();
  FocusNode firstFC = new FocusNode();
  FocusNode middleFC = new FocusNode();
  FocusNode lastFC = new FocusNode();
  FocusNode suffixFC = new FocusNode();

  //---Text Editing Controllers
  TextEditingController nameCtrl = new TextEditingController();

  TextEditingController prefixCtrl = new TextEditingController();
  TextEditingController firstCtrl = new TextEditingController();
  TextEditingController middleCtrl = new TextEditingController();
  TextEditingController lastCtrl = new TextEditingController();
  TextEditingController suffixCtrl = new TextEditingController();

  //---Contact Save Functionality
  saveContact() async{
    //TODO... Create the contact from all the data

    //TODO... stop using dummy contact
    Contact newContact = getDummyContact();

    //save the avatar
    if(imageFile != null){
      List<int> avatarList = await imageFile.readAsBytes();
      newContact.avatar = Uint8List.fromList(avatarList);
    }

    print("-----------------------------------");

    //save the contact
    await ContactsService.addContact(newContact);  

    //TODO... replace this for code that returns this contact to the desired location

    /*
    Navigator.pushAndRemoveUntil(
      context, 
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: App(),
      ),
      (r) => false,
    );
    */
  }

  //---Image Picker Functionality
  File imageFile;

  void showImagePicker() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          child: Row(
            children: <Widget>[
              bigIcon(false, FontAwesomeIcons.images),
              bigIcon(true, Icons.camera),
            ],
          ),
        );
      },
    );
  }

  Widget bigIcon(bool fromCamera, dynamic icon){
    return Expanded(
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          padding: EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
          child: IconButton(
            onPressed: () => changeImage(fromCamera),
            icon: Icon(icon),
          ),
        ),
      ),
    );
  }

  Future changeImage(bool fromCamera) async {
    File tempImage = await ImagePicker.pickImage(
      source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
    );

    if(tempImage != null){
      Navigator.of(context).pop();

      imageFile = tempImage;

      setState(() {
        
      });
    }
    //ELSE... we keep whatever image we had here or
  }

  @override
  void initState() {
    nameOpen.addListener((){
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_){
        if(nameOpen.value){
          FocusScope.of(context).requestFocus(firstFC);
        }
        else{
          FocusScope.of(context).requestFocus(nameFocusNode);
        }
      });
    });
    super.initState();
  }

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
            title: Text("New Contact"),
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
                                      visible: (nameOpen.value == false),
                                      child: new NameRow(
                                        bottomBarHeight: bottomBarHeight,
                                        nameOpen: nameOpen,
                                        icon: Icons.keyboard_arrow_down,
                                        label: "Name",
                                        focusNode: nameFocusNode,
                                        controller: nameCtrl,
                                      ),
                                    ),
                                    Visibility(
                                      visible: nameOpen.value,
                                      child: Column(
                                        children: <Widget>[
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: nameOpen,
                                            icon: Icons.keyboard_arrow_up,
                                            label: "Name prefix",
                                            focusNode: prefixFC,
                                            controller: prefixCtrl,
                                          ), 
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: nameOpen,
                                            label: "First name",
                                            focusNode: firstFC,
                                            controller: firstCtrl,
                                          ),
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: nameOpen,
                                            label: "Middle name",
                                            focusNode: middleFC,
                                            controller: middleCtrl,
                                          ),
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: nameOpen,
                                            label: "Last name",
                                            focusNode: lastFC,
                                            controller: lastCtrl,
                                          ),
                                          new NameRow(
                                            bottomBarHeight: bottomBarHeight,
                                            nameOpen: nameOpen,
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
                          onTap: () => showImagePicker(),
                          child: Stack(
                            children: <Widget>[
                              new Container(
                                width: imageDiameter,
                                height: imageDiameter,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).indicatorColor,
                                  shape: BoxShape.circle,
                                ),
                                child: (imageFile == null) ? Icon(
                                  Icons.camera_alt,
                                  size: imageDiameter / 2,
                                  color: Theme.of(context).primaryColor,
                                )
                                : ClipOval(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                      child: Image.file(
                                      imageFile,
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