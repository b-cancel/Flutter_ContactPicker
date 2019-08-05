import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    Key key,
    @required this.thisContact,
    @required this.thisColor,
    this.onSelect,
  }) : super(key: key);

  final Contact thisContact;
  final Color thisColor;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    //process image
    bool noImage = thisContact.avatar.length == 0;

    //process name
    String name = thisContact.givenName ?? "UnKnown";

    //process the phone string
    String phoneString;
    if(thisContact.phones.toList().length == 0){
      phoneString = "no number";
    }
    else{
      Item firstNumber = thisContact.phones.toList()[0];
      phoneString = firstNumber.value.toString() + " | " + firstNumber.label.toString();
    }

    //return widget
    return SizedBox(
      height: 70,
      child: ListTile(
        onTap: (){
          onSelect(context, thisContact);
        },
        leading: new Container(
          width: 50,
          height: 50,
          decoration: new BoxDecoration(
            color: thisColor,
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
                thisContact.avatar,
              ),
            )
          )
        ),
        title: Text(
          name,
          maxLines: 1,
        ),
        subtitle: Text(phoneString),
        //trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}