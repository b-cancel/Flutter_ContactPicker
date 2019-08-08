import 'dart:math';

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
    //name = scrambler(name, 3/4); //SCRAMBLE
    
    //process the phone string
    String number;
    if(thisContact.phones.toList().length == 0){
      number = "no number";
    }
    else{
      Item firstNumber = thisContact.phones.toList()[0];
      number = firstNumber.value.toString();
      
      //number = scrambler(number, 1, onlyNumbers: true); //SCRAMBLE
      number += " | " + firstNumber.label.toString();
    }

    //title: theme.textTheme.subhead;
    //subtitle: theme.textTheme.body1 | theme.textTheme.caption.color
    

    //return widget
    return ListTile(
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
      ),
      subtitle: Text(number),
    );
  }
}

/*
Container(
        height: 64,
        padding: EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            new Container(
              width: 48,
              height: 48,
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
            Column(
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                ),
                Text(
                  number,
                  maxLines: 1,
                ),
              ],
            )
          ],
        ),
      ),
*/

//NOTE: we never scramble the first letter
String scrambler(String original, double scrambleFactor, {bool onlyNumbers: false}){
  //otherwise substring stuff will break things
  if(original.length > 2){
    //setup
    var rnd = new Random();
    int len = original.length;
    int valuesToScramble = (len * scrambleFactor).toInt();

    //scramble
    while(valuesToScramble > 0){
      //never scramble the first value (For section purposes)
      int indexToReplace = rnd.nextInt(len-2) + 1;

      //scramble that index
      int replacementLetter;
      if(onlyNumbers){
        //IF we didn't land a number then don't replace it
        String maybeNumber = original[indexToReplace];
        //check if we landed a number we can replace
        if(isNumeric(maybeNumber)){ //we can replace it
          replacementLetter = rnd.nextInt(10) + 48;
        }
        else{ //we can't it isnt a number
          replacementLetter = -1;
        }
      }
      else{ //only replace lower case letters
        if(isLowerCase(original[indexToReplace])){
          replacementLetter = rnd.nextInt(26) + 97;
        }
        else replacementLetter = -1;
      }

      //update string IF possible
      if(replacementLetter != -1){
        String newChar = String.fromCharCode(replacementLetter);
        String left = original.substring(0, indexToReplace); 
        String right = original.substring(indexToReplace+1, len); 
        original = left + newChar + right;

        //keep scrambling maybe
        valuesToScramble--;
      }
    }

    //return
    return original;
  }
  else return original;
}

bool isNumeric(String s) {
  if(s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}

bool isLowerCase(String str){
    return str == str.toLowerCase() && str != str.toUpperCase();
}