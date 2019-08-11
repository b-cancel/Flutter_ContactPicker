import 'dart:io';

import 'package:flutter/material.dart';
import 'package:not_at_home/newContact/imagePicker.dart';

class FieldData{
  int index;
  TextEditingController controller;
  FocusNode focusNode;
  Function nextFunction;

  FieldData(){
    index = 0;
    controller = new TextEditingController();
    focusNode = new FocusNode();
    nextFunction = (){
      print("next field");
    };
  }
}

class NewContactOuterShell extends StatelessWidget {
  NewContactOuterShell({
    @required this.createContact,
    @required this.cancelContact,
    @required this.imageLocation,
    @required this.onImagePicked,
    @required this.fields,
    @required this.isPortrait,
    @required this.bottomBarHeight,
  });

  final Function createContact;
  final Function cancelContact;
  final ValueNotifier<String> imageLocation;
  final Function onImagePicked;
  final Widget fields;
  final bool isPortrait;
  final double bottomBarHeight;

  @override
  Widget build(BuildContext context) {
    double bottomBarHeight = 32;
    if(isPortrait == false) bottomBarHeight = 0;

    //calc imageDiameter
    double imageDiameter = MediaQuery.of(context).size.width / 2;
    if(isPortrait == false){
      imageDiameter = MediaQuery.of(context).size.height / 2;
    }

    //make new contact UX
    Widget bodyWidget = ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColorDark,
              padding: EdgeInsets.fromLTRB(
                0,
                //push CARD down to the ABOUT middle of the picture
                imageDiameter * (5/7),
                0,
                16,
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(
                        0, 
                        //push CARD CONTENT down to past the picture
                        imageDiameter * (2/7) + 16 * 2, 
                        0, 
                        16,
                      ),
                      child: fields,
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
            //-------------------------Picture UX
            Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: (){
                  showImagePicker(
                    context,
                    imageLocation,
                    //we set state so we update the picture
                    onImagePicked,
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
    );

    //-------------------------Submit Button Locations
    if(isPortrait){
      //in portrait mode the buttons are large and at the bottom of the screen
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Stack(
          children: <Widget>[
            bodyWidget,
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).primaryColorDark,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left:16, right:16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new PortraitButton(
                      width: MediaQuery.of(context).size.width / 2 - 16,
                      name: "Cancel",
                      onPressed: () => cancelContact(),
                    ),
                    new PortraitButton(
                      width: MediaQuery.of(context).size.width / 2 - 16,
                      name: "Save",
                      onPressed: () => createContact(),
                    ),
                  ],
                )
              ),
            ),
          ],
        ),
      );
    }
    else{
      //In landscape mode the buttons are small and on the app bar
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColorDark,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            new LandscapeButton(
              func: () => cancelContact(),
              str: "Cancel",
            ),
            new LandscapeButton(
              func: () => createContact(), 
              str: "Save",
            )
          ],
        ),
        body: bodyWidget,
      );
    }
      
  }
}

//-------------------------Helper Widgets-------------------------

//the buttons used when the app is in landscape mode
class LandscapeButton extends StatelessWidget {
  const LandscapeButton({
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

//the buttons used when the app is in portrait mode
class PortraitButton extends StatelessWidget {
  final String name;
  final Function onPressed;
  final double width;

  const PortraitButton({
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