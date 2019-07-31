import 'package:flutter/material.dart';
import 'package:not_at_home/newContactHelper.dart';

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
        new NameRow(
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
        ),
        //displayName, givenName, middleName, prefix, suffix, familyName;
        //Name prefix(prefix), Name suffix(suffix)
        //First name (givenName), Middle name (middleName), Last name (familyName)
        //display name = prefix, first name, middle name, last name, ',' suffix
        Visibility(
          visible: (namesSpread.value == false),
          child: Container(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: new NameRow(
                    bottomBarHeight: bottomBarHeight,
                    label: "Name",
                    focusNode: nameField.focusNode,
                    controller: nameField.controller,
                    nextFunction: nameField.nextFunction,
                  ),
                ),
                FlatButton(
                  padding: EdgeInsets.all(0),
                  splashColor: Colors.transparent,  
                  highlightColor: Colors.transparent,
                  onPressed: (){
                    namesSpread.value = !namesSpread.value;
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    padding: EdgeInsets.only(right: 0),
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 42,
                          width: 24,
                          child: Icon(
                            Icons.keyboard_arrow_down,
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
                        right: 32,
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
                        padding: EdgeInsets.only(right: 0),
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
        new Title( 
          icon: Icons.phone,
          name: "Phone",
          onPressed: (){
            print("tapped phone");
          }
        ),
        new Title( 
          icon: Icons.email,
          name: "Email",
          onPressed: (){
            print("tapped email");
          }
        ),
        new Title( 
          icon: Icons.work,
          name: "Work",
          onPressed: workOpen.value
          ? null
          : (){
            workOpen.value = true;
          }
        ),
        Visibility(
          visible: workOpen.value,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 16, right: 32),
                child: Row(
                  children: <Widget>[
                    IconWidget(),
                    Flexible(
                      child: TheField(
                        focusNode: jobTitleField.focusNode, 
                        controller: jobTitleField.controller, 
                        bottomBarHeight: bottomBarHeight, 
                        nextFunction: jobTitleField.nextFunction, 
                        label: "Job title",
                      ),
                    ),
                  ]
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 16, right: 32),
                child: Row(
                  children: <Widget>[
                    IconWidget(),
                    Flexible(
                      child: TheField(
                        focusNode: companyField.focusNode, 
                        controller: companyField.controller, 
                        bottomBarHeight: bottomBarHeight, 
                        nextFunction: companyField.nextFunction, 
                        label: "Company",
                      ),
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
        new Title( 
          icon: Icons.location_on,
          name: "Address",
          onPressed: (){
            print("tapped address");
          }
        ),
        new Title( 
          icon: Icons.note,
          name: "Note",
          onPressed: noteOpen.value
          ? null
          : (){
            noteOpen.value = true;
          }
        ),
        Visibility(
          visible: noteOpen.value,
          child: Container(
            padding: EdgeInsets.only(bottom: 16, right: 32),
            child: Row(
              children: <Widget>[
                IconWidget(),
                Flexible(
                  child: TheField(
                    focusNode: noteField.focusNode, 
                    controller: noteField.controller, 
                    bottomBarHeight: bottomBarHeight, 
                    nextFunction: noteField.nextFunction, 
                    label: "Note",
                  ),
                ),
              ]
            ),
          ),
        ),
      ],
    );
  }
}

IconData down = Icons.keyboard_arrow_down;
IconData up = Icons.keyboard_arrow_up;

class NameRow extends StatelessWidget {
  const NameRow({
    Key key,
    @required this.bottomBarHeight,
    @required this.label,
    @required this.focusNode,
    @required this.controller,
    @required this.nextFunction,
  }) : super(key: key);

  final double bottomBarHeight;
  final String label;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function nextFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconWidget(),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: new TheField(
                focusNode: focusNode, 
                controller: controller, 
                bottomBarHeight: bottomBarHeight, 
                nextFunction: nextFunction, 
                label: label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TheField extends StatelessWidget {
  const TheField({
    Key key,
    @required this.focusNode,
    @required this.controller,
    @required this.bottomBarHeight,
    @required this.nextFunction,
    @required this.label,
  }) : super(key: key);

  final FocusNode focusNode;
  final TextEditingController controller;
  final double bottomBarHeight;
  final Function nextFunction;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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