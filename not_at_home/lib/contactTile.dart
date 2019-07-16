import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/main.dart';

import 'dart:io';

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    Key key,
    @required this.context,
    @required this.contact,
  }) : super(key: key);

  final BuildContext context;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    //process image
    bool noImage = contact.avatar.length == 0;

    //process name
    String name = contact.givenName ?? "UnKnown";

    //process the phone string
    String phoneString;
    if(contact.phones.toList().length == 0){
      phoneString = "no number";
    }
    else{
      Item firstNumber = contact.phones.toList()[0];
      phoneString = firstNumber.value.toString() + " | " + firstNumber.label.toString();
    }

    //return widget
    return ListTile(
      onTap: (){
        //TODO... replace this for code that returns this contact to the desired location
        print("tapped");
      },
      leading: new Container(
        width: 50,
        height: 50,
        decoration: new BoxDecoration(
          color: theColors[rnd.nextInt(theColors.length)],
          shape: BoxShape.circle,
        ),
        child: (noImage) ? Icon(
          Icons.person,
          color: Theme.of(context).primaryColor,
        )
        : ClipOval(
          child: FittedBox(
            fit: BoxFit.cover,
              child: Image.memory(
              contact.avatar,
            ),
          )
        )
      ),
      title: Text(name),
      subtitle: Text(phoneString),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}