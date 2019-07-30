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
          nameOpen: namesSpread,
          icon: (i == 0) 
            ? Icons.keyboard_arrow_up
            : null,
          focusNode: thisField.focusNode,
          controller: thisField.controller,
          nextFunction: thisField.nextFunction,
          label: nameLabels[i],
        ), 
      );
    }

    //build
    return Column(
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
            focusNode: nameField.focusNode,
            controller: nameField.controller,
            nextFunction: nameField.nextFunction,
          ),
        ),
        Visibility(
          visible: namesSpread.value,
          child: Column(
            children: nameRows,
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
                padding: EdgeInsets.only(bottom: 8),
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
                padding: EdgeInsets.only(bottom: 8),
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
            padding: EdgeInsets.only(bottom: 8),
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
    this.icon,
    @required this.label,
    @required this.nameOpen,
    @required this.focusNode,
    @required this.controller,
    @required this.nextFunction,
  }) : super(key: key);

  final double bottomBarHeight;
  final IconData icon;
  final String label;
  final ValueNotifier<bool> nameOpen;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function nextFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          IconWidget(),
          Flexible(
            child: new TheField(
              focusNode: focusNode, 
              controller: controller, 
              bottomBarHeight: bottomBarHeight, 
              nextFunction: nextFunction, 
              label: label,
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