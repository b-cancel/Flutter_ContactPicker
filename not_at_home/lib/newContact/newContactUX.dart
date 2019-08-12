import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:not_at_home/newContact/newContactHelper.dart';

class LeftIcon extends StatelessWidget {
  final IconData icon;

  LeftIcon({
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
      ),
      child: SizedBox(
        width: 24,
        child: Icon(
          icon ?? Icons.lock,
          color: iconColor,
        ),
      ),
    );
  }
}

class RightIconButton extends StatelessWidget {
  RightIconButton({
    this.onPressed,
    this.height,
    this.icon,
  });

  final Function onPressed;
  final double height;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: Colors.grey,
      height: height,
      padding: EdgeInsets.only(
        right: 16
      ),
      child: Container(
        color: Colors.blue,
        child: SizedBox(
          width: 24,
          child: icon,
        ),
      ),
    );

    //button or no button
    if(onPressed == null){
      return child;
    }
    else{
      return FlatButton(
        padding: EdgeInsets.all(0),
        splashColor: Colors.transparent,  
        highlightColor: Colors.transparent,
        onPressed: onPressed,
        child: child,
      );
    } 
  }
}

//phones, emails, work (job title, company), addresses, note

class NewContactUX extends StatelessWidget {
  NewContactUX({
    @required this.bottomBarHeight,
    @required this.namesSpread,
    //handle names
    @required this.nameField,
    @required this.nameFields,
    @required this.nameLabels,
    //TODO... add phones here
    //TODO... add emails here
    //handle work
    @required this.jobTitleField,
    @required this.companyField,
    @required this.workOpen,
    //TODO... add addresses here
    @required this.noteField,
    @required this.noteOpen,
  });

  final double bottomBarHeight;
  final ValueNotifier<bool> namesSpread;
  //handle names
  final FieldData nameField;
  final List<FieldData> nameFields;
  final List<String> nameLabels;
  //TODO... add phones here
  //TODO... add emails here
  //handle work
  final FieldData jobTitleField;
  final FieldData companyField;
  final ValueNotifier<bool> workOpen;
  //TODO... add addresses here
  final FieldData noteField;
  final ValueNotifier<bool> noteOpen;

  @override
  Widget build(BuildContext context) {
    //create all the needed rows
    List<Widget> nameRows = new List<Widget>();
    for(int i = 0; i < nameLabels.length; i++){
      FieldData thisField = nameFields[i];
      nameRows.add(
        new TheField(
          bottomBarHeight: bottomBarHeight,
          focusNode: thisField.focusNode,
          controller: thisField.controller,
          nextFunction: thisField.nextFunction,
          label: nameLabels[i],
        ), 
      );
    }

    //build
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Title(
          icon: Icons.person,
          name: "Name",
          onPressed: null,
        ),
        //displayName, givenName, middleName, prefix, suffix, familyName;
        //Name prefix(prefix), Name suffix(suffix)
        //First name (givenName), Middle name (middleName), Last name (familyName)
        //display name = prefix, first name, middle name, last name, ',' suffix
        //NAME START-------------------------
        Visibility(
          visible: (namesSpread.value == false),
          child: Row(
            children: <Widget>[
              Flexible(
                child: new TheField(
                  bottomBarHeight: bottomBarHeight,
                  label: "Name",
                  focusNode: nameField.focusNode,
                  controller: nameField.controller,
                  nextFunction: nameField.nextFunction,
                ),
              ),
              RightIconButton(
                onPressed: (){
                  namesSpread.value = !namesSpread.value;
                },
                height: 42,
                icon: Icon(Icons.keyboard_arrow_down),
                //padding: EdgeInsets.only(left: 8), //TODO...
              ),
            ],
          ),
        ),
        Visibility(
          visible: namesSpread.value,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: nameRows,
                ),
              ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    /*
                    //GUIDE BELOW
                    Container(
                      color: Colors.pink,
                      //32 from right + 24 icon + 24 left
                      width: 80,
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Container(
                        width: 24,
                        height: 42,
                        color: Colors.green,
                      ),
                    ),
                    */
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      splashColor: Colors.transparent,  
                      highlightColor: Colors.transparent,
                      onPressed: (){
                        namesSpread.value = !namesSpread.value;
                      },
                      child: Container(
                        height: 42 * 5.0,
                        width: 80,
                        padding: EdgeInsets.only(left: 8),
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 42,
                              width: 24,
                              child: Icon(
                                Icons.keyboard_arrow_up,
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //NAME END-------------------------
        new Title( 
          icon: Icons.phone,
          name: "Phone",
          onPressed: (){
            print("tapped phone");
          },
          rightButton: RightIconButton(
            height: 42,
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ),
        //PHONE START-------------------------
        Column(
          children: <Widget>[
            TheField(
              focusNode: jobTitleField.focusNode, 
              controller: jobTitleField.controller, 
              bottomBarHeight: bottomBarHeight, 
              nextFunction: jobTitleField.nextFunction, 
              label: "Phone 1",
              rightIcon: RightIconButton(
                height: 42,
                onPressed: (){
                  print("right icon button pressed");
                },
                icon: Icon(
                  FontAwesomeIcons.minus,
                  color: Colors.red,
                  size: 16,
                ),
                //padding: EdgeInsets.only(left: 8), //TODO...
              ),
            ),
          ],
        ),
        //PHONE END-------------------------
        new Title( 
          icon: Icons.email,
          name: "Email",
          onPressed: (){
            print("tapped email");
          },
          rightButton: RightIconButton(
            height: 42,
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ),
        new Title( 
          icon: Icons.work,
          name: "Work",
          onPressed: (){
            workOpen.value = true;
          }
        ),
        Visibility(
          visible: workOpen.value,
          child: Column(
            children: <Widget>[
              TheField(
                  focusNode: jobTitleField.focusNode, 
                  controller: jobTitleField.controller, 
                  bottomBarHeight: bottomBarHeight, 
                  nextFunction: jobTitleField.nextFunction, 
                  label: "Job title",
                ),
              TheField(
                focusNode: companyField.focusNode, 
                controller: companyField.controller, 
                bottomBarHeight: bottomBarHeight, 
                nextFunction: companyField.nextFunction, 
                label: "Company",
              ),
            ],
          ),
        ),
        new Title( 
          icon: Icons.location_on,
          name: "Address",
          onPressed: (){
            print("tapped address");
          },
          rightButton: RightIconButton(
            height: 42,
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ),
        new Title( 
          icon: Icons.note,
          name: "Note",
          onPressed: (){
            noteOpen.value = true;
          }
        ),
        Visibility(
          visible: noteOpen.value,
          child: TheField(
            focusNode: noteField.focusNode, 
            controller: noteField.controller, 
            bottomBarHeight: bottomBarHeight, 
            nextFunction: noteField.nextFunction, 
            label: "Note",
          ),
        ),
      ],
    );
  }
}

class Title extends StatelessWidget {
  final IconData icon;
  final String name;
  final Function onPressed;
  final Widget rightButton;

  const Title({
    @required this.icon,
    @required this.name,
    this.onPressed,
    this.rightButton,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Container theTitle = Container(
      color: Colors.red,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: <Widget>[
          LeftIcon(
            icon: icon,
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20,
              ),
            ),
          ),
          rightButton ?? Container(),
        ],
      ),
    );

    //whether or not the area is clickable
    if(onPressed == null) return theTitle;
    else{
      return FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: onPressed,
        child: theTitle,
      );
    }
  }
}

class TheField extends StatelessWidget {
  const TheField({
    @required this.label,
    @required this.focusNode,
    @required this.controller,
    @required this.nextFunction,
    @required this.bottomBarHeight,
    this.rightIcon,
  });

  final String label;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function nextFunction;
  final double bottomBarHeight;
  final Widget rightIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      padding: EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          LeftIcon(),
          Flexible(
            child: TextFormField(
              focusNode: focusNode,
              controller: controller,
              scrollPadding: EdgeInsets.only(bottom: bottomBarHeight * 2 + 8),
              autofocus: true,
              style: TextStyle(
                fontSize: 18,
              ),
              onEditingComplete: (nextFunction == null)
              ? null
              : (){
                nextFunction();
              },
              textInputAction: (nextFunction == null)
              ? TextInputAction.done
              : TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 4),
                hintText: label,
                hintStyle: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          rightIcon ?? Container(),
        ],
      ),
    );
  }
}