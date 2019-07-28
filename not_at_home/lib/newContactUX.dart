import 'dart:io';

import 'package:flutter/material.dart';

import 'imagePicker.dart';

class NewContactUX extends StatelessWidget {
  NewContactUX({
    this.imageDiameter,
    this.bottomBarHeight,
    this.imageLocation,
    this.isPortrait,
    this.contactSaved,
    this.imagePicked,
    this.namesSpread,

    this.nameFC,
    this.prefixFC,
    this.firstFC,
    this.middleFC,
    this.lastFC,
    this.suffixFC,

    this.nameCtrl,
    this.prefixCtrl,
    this.firstCtrl,
    this.middleCtrl,
    this.lastCtrl,
    this.suffixCtrl,
  });

  final double imageDiameter;
  final double bottomBarHeight;
  final ValueNotifier<String> imageLocation;
  final bool isPortrait;
  final Function contactSaved;
  final Function imagePicked;
  final ValueNotifier<bool> namesSpread;

  final FocusNode nameFC;
  final FocusNode prefixFC;
  final FocusNode firstFC;
  final FocusNode middleFC;
  final FocusNode lastFC;
  final FocusNode suffixFC;

  final TextEditingController nameCtrl;
  final TextEditingController prefixCtrl;
  final TextEditingController firstCtrl;
  final TextEditingController middleCtrl;
  final TextEditingController lastCtrl;
  final TextEditingController suffixCtrl;

  @override
  Widget build(BuildContext context) {
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
            focusNode: nameFC,
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