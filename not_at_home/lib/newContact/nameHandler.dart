import 'package:not_at_home/helper.dart';
import 'package:not_at_home/newContact/newContactHelper.dart';

List<String> nameToNames(String name){
  List<String> resultNames = new List<String>();

  //field defaults
  for(int i = 0; i < 5; i++){
    resultNames.add("");
  }

  //split the names
  List<String> namesFound = name.split(" ");

  //trim all the names of whitespace
  for(int i = 0; i < namesFound.length; i++){
    namesFound[i] = namesFound[i].trim();
  }

  //start processing the split
  if(namesFound.length > 0){
    //check if the first name is a prefix
    String maybePrefix = onlyCharacters(namesFound[0].toLowerCase());
    bool isAPrefix = isPrefix(maybePrefix); 
    if(isAPrefix){
      resultNames[0] = namesFound[0];
      namesFound.removeAt(0);
    }

    //NOTE: now first name is at 0

    if(namesFound.length > 0){
      print("names left: " + namesFound.length.toString());

      //NOTE: below we could implement more complex logic like samsung does
      //but this is realistically never going to be used

      //NOTE: if not prefix the first name is considered the first name
      //    then 2nd is middle, 3rd is last... if more than that we know the first name has multiple names
      //  else if yes prefix the first name is considered the last name
      //    then ditto as above but first name is prefix

      //NOTE: suffix is never implied unless there is a comma and then that name
      //for suffix implied atleast two names first
      //if one name and then comma then suffix... its considered Lastname, Firstname
      //if comma then name... its considered firstname then last name... EX: ',' 'name' eventhough written ',name'

      //now try to extract the name suffix
      //only last name can be suffix and only if it has a comma before it
      //or after the name before
      int lastNameIndex = namesFound.length - 1;
      String lastName = namesFound[lastNameIndex];
      //NOTE: needs to check length
      bool commaBeforeLast = (lastName.length > 0 && lastName[0] == ",");
      if(commaBeforeLast){
        //remove the comma
        namesFound[lastNameIndex] = namesFound[lastNameIndex].substring(1);
        //0(prefix), 1, 2, 3, 4(suffix)
        resultNames[4] = namesFound[lastNameIndex];
        //remove this name from the list since it's been handled
        namesFound.removeLast();
      }
      else{
        if(namesFound.length > 1){
          String beforeLastName = namesFound[lastNameIndex - 1];
          bool commaAfterBeforeLast = (beforeLastName.length > 0 && beforeLastName[beforeLastName.length - 1] == ",");
          if(commaAfterBeforeLast){
            //remove the comma
            namesFound[lastNameIndex - 1] = namesFound[lastNameIndex - 1].substring(0, beforeLastName.length - 1);
            //0(prefix), 1, 2, 3, 4(suffix)
            resultNames[4] = namesFound[lastNameIndex];
            //remove this name from the list since it's been handled
            namesFound.removeLast();
          } 
          //ELSE... no preffix exists
        }
        //ELSE... we have no name before to check
      }

      if(namesFound.length > 0){
        //NOTE: now only first(s), middle, and last names are left
        //1 name is first
        //2 names first, last
        //3 names first, middle, last
        //4+ mames (other), before last, last

        switch(namesFound.length){
          case 1:
            if(isAPrefix){ //consider last name
              resultNames[3] = namesFound[0];
            }
            else{
              resultNames[1] = namesFound[0];
            }

            break;
          case 2:
            //set first name
            resultNames[1] = namesFound[0];
            //set last name
            resultNames[3] = namesFound[1];

            break;
          case 3:
            //set first name
            resultNames[1] = namesFound[0];
            //set middle name
            resultNames[2] = namesFound[1];
            //set last name
            resultNames[3] = namesFound[2];

            break;
          default:
            //the first removal is the last name
            String lastName = namesFound.removeLast();
            resultNames[3] = lastName;

            //the second removal is the middle name
            String middleName = namesFound.removeLast();
            resultNames[2] = middleName;

            //sum all the rest of the names as the first name
            String firstName = "";
            for(int i = 0; i < namesFound.length; i++){
              if(i > 0) firstName += " ";
              firstName = firstName + namesFound[i];
            }
            resultNames[1] = firstName;

            break;
        }
      }
    }
  }

  //ret 
  return resultNames;
}

String namesToName(List<FieldData> nameFields){
  //combine all the names into a single name
  //NOTE: before suffix we add a ', '
  List<String> names = new List<String>();
  bool prefixPresent = false;
  for(int i = 0; i < nameFields.length; i++){
    FieldData thisField = nameFields[i];
    String text = thisField.controller.text.trim();
    if(text.length > 0){
      names.add(text);

      //check if prefix
      if(i == (nameFields.length - 1)) prefixPresent = true;
    }
  }

  //from all grabbed names get name
  String name = "";
  for(int i = 0; i < names.length; i++){
    //dr cancel, bubo
    if(prefixPresent && i == (names.length - 1)) name += ", ";
    else if(i != 0) name += " ";
    name += names[i];
  }
  return name;
}