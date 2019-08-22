import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import '../helper.dart';

bool scramblerOn = false;

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    Key key,
    @required this.theContacts,
    @required this.theContactID,
    @required this.thisColor,
    this.onSelect,
  }) : super(key: key);

  final ValueNotifier<List<Contact>> theContacts;
  final int theContactID;
  final Color thisColor;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    Contact thisContact = theContacts.value[theContactID];

    //process name
    String name = contactToName(thisContact) ?? "UnKnown";
    if(scramblerOn){
      name = scrambler(name, 3/4); //SCRAMBLE
    }
    
    //process the phone string
    String number;
    if(thisContact.phones.toList().length == 0){
      number = "no number";
    }
    else{
      Item firstNumber = thisContact.phones.toList()[0];
      number = firstNumber.value.toString();
      
      if(scramblerOn){
        number = scrambler(number, 1, onlyNumbers: true); //SCRAMBLE
      }
      number += " | " + firstNumber.label.toString();
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
          child: TileImage(
            theContacts: theContacts,
            theContactID: theContactID,
          ),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          number,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class TileImage extends StatefulWidget {
  final ValueNotifier<List<Contact>> theContacts;
  final int theContactID;

  TileImage({
    @required this.theContacts,
    @required this.theContactID,
  });

  @override
  _TileImageState createState() => _TileImageState();
}

class _TileImageState extends State<TileImage> {
  Contact theContact;
  bool noImage;

  @override
  void initState() {
    //set the initial value
    theContact = widget.theContacts.value[widget.theContactID];
    

    //listen to contact list changes to update photo
    widget.theContacts.addListener((){
      //the list may have changed but did we?
      theContact = widget.theContacts.value[widget.theContactID];
      bool newNoImage = (theContact.avatar.length <= 0);

      //we now have an image, or a high res one
      if(noImage != newNoImage){
        setState(() {});
      }
    });

    //super init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    noImage = (theContact.avatar.length <= 0);

    if(noImage){
      String letter = contactToName(theContact);
      Widget center;

      //if possible have a letter
      if(letter.length == 0){
        center = Icon(
          Icons.person,
          color: Colors.black,
        );
      }
      else{
        center = Text(
          letter[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        );
      }

      //return
      return Center(
        child: center,
      );
    }
    else{
      return ClipOval(
        child: FittedBox(
          fit: BoxFit.cover,
            child: Image.memory(
            theContact.avatar,
          ),
        )
      );
    }
  }
}

//randomizer for below
Random random = new Random();

//NOTE: we never scramble the first letter
String scrambler(String original, double scrambleFactor, {bool onlyNumbers: false}){
  //otherwise substring stuff will break things
  if(original.length > 2){
    //setup
    int len = original.length;
    int valuesToScramble = (len * scrambleFactor).toInt();

    //scramble
    while(valuesToScramble > 0){
      //never scramble the first value (For section purposes)
      int indexToReplace = random.nextInt(len-2) + 1; //TODO... check 1->(len-1)

      //scramble that index
      int replacementLetter;
      if(onlyNumbers){ //only replace lower case letters
        if(isNumeric(original[indexToReplace])){ //TODO... check 48->57
          replacementLetter = random.nextInt(9) + 48;
        }
        else{ //we can't it isnt a number
          replacementLetter = -1;
        }
      }
      else{ //only replace lower case letters
        if(isLowerCase(original[indexToReplace])){ //TODO... check 97->122
          replacementLetter = random.nextInt(25) + 97;
        } //we can't it isn't lower case
        else replacementLetter = -1;
      }

      //update string IF possible
      if(replacementLetter != -1){
        String newChar = String.fromCharCode(replacementLetter);
        String left = original.substring(0, indexToReplace); 
        String right = original.substring(indexToReplace+1, len); 
        original = left + newChar + right;
      }

      //keep scrambling maybe
      //if we dont have this here 
      //then if the string doesn't have what we are looking for 
      //the function has the chance of never finishing
      valuesToScramble--;
    }

    //return
    return original;
  }
  else return original;
}

bool isNumeric(String s) {
  if(s == null || s.length == 0) return false;
  else{
    int code = s.codeUnitAt(0);
    if(48 <= code && code <= 57) return true;
    else return false;
  }
}

bool isLowerCase(String str){
    return str == str.toLowerCase() && str != str.toUpperCase();
}