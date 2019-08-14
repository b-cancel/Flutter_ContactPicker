import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/helper.dart';
import 'package:not_at_home/newContact/categorySelect.dart';
import 'package:not_at_home/newContact/newContactHelper.dart';
import 'package:not_at_home/permission.dart';
import 'package:permission/permission.dart';

import 'newContactUX.dart';

/*
We only confirm and request access to contacts before we save and pass it
If we already have access we save the contact and run onselect
ELSE we request access

Whenever we request access we also want to customize the permission page
Because manual input from here can simply mean that we run onSelect without actually saving the contact
which isnt ideal but it does the trick if the user simply doesn't want to grant us access for whatever reason
*/

/*
When we come back from requesting access
IF we have access now we save the contact and run onselect
ELSE we wait for the user to decide to go back
  NOTE: we could go all the back into contact selection BUT
  the pain of the software going back and erasing all the new contact work
  is going to be much worse than the pain of clicking back again because you don't want to grant access
*/

class NewContact extends StatefulWidget {
  NewContact({
    @required this.onSelect,
  });

  final Function onSelect;

  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> with WidgetsBindingObserver {
  //-------------------------Logic Code-------------------------
  ValueNotifier<bool> namesSpread = new ValueNotifier<bool>(false);

  ValueNotifier<String> imageLocation = new ValueNotifier<String>("");

  //keep track of whether or not we returned from the permissions page
  ValueNotifier<bool> backFromPermissionPage = new ValueNotifier<bool>(false);

  //-------------------------Fields Options-------------------------

  //NOTE: these are designed to be set ONCE and DONE
  //NOTE: we NEED a name so it autofocuses and therefore auto opens

  //-------------------------Fields Code-------------------------

  //-------------------------Name (put together)
  FieldData nameField = FieldData();

  //-------------------------Names (split up)
  //prefix, first, middle, last, suffix
  List<FieldData> nameFields = List<FieldData>();
  List<String> nameLabels = List<String>();

  //-------------------------Phones
  bool autoAddFirstPhone = true;
  List<FieldData> phoneValueFields = List<FieldData>();
  List<ValueNotifier<String>> phoneLabelStrings = List<ValueNotifier<String>>();

  //-------------------------Emails
  bool autoAddFirstEmail = true;
  List<FieldData> emailValueFields = List<FieldData>();
  List<ValueNotifier<String>> emailLabelStrings = List<ValueNotifier<String>>();

  //-------------------------Work
  bool autoOpenWork = true;
  FieldData jobTitleField = FieldData(); //jobTitle
  FieldData companyField = FieldData(); //company
  ValueNotifier<bool> workOpen = new ValueNotifier<bool>(false);

  //-------------------------Addresses
  bool autoAddFirstAddress = false;
  List<FieldData> addressStreetFields = new List<FieldData>();
  List<FieldData> addressCityFields = new List<FieldData>();
  List<FieldData> addressPostcodeFields = new List<FieldData>();
  List<FieldData> addressRegionFields = new List<FieldData>();
  List<FieldData> addressCountryFields = new List<FieldData>();
  List<ValueNotifier<String>> addressLabelStrings = new List<ValueNotifier<String>>();

  //-------------------------Note
  bool autoOpenNote = true;
  FieldData noteField = FieldData(); //note
  ValueNotifier<bool> noteOpen = new ValueNotifier<bool>(false);

  //-------------------------Next Function Helpers-------------------------
  //NOTE: these WILL only be called IF indeed things are empty

  //start with value
  addFirstPhone(){
    if(phoneValueFields.isEmpty){
      addPhone(); //sets state AND focuses on field
    }
  }

  //start with value
  addFirstEmail(){
    if(emailValueFields.isEmpty){
      addEmail(); //sets state AND focuses on field
    }
  }

  //starting with job title
  openWork(){
    if(workOpen.value == false){
      //open the work section
      workOpen.value = true;
      //the value changing to true will trigger a listener
      //that will set state and focus on the right field
    }
  }

  //starting with street
  addFirstPostalAddress(){
    if(addressStreetFields.isEmpty){
      addPostalAddress(); //sets state AND focuses on field
    }
  }

  //start with note (only way to start :p)
  openNote(){
    if(noteOpen.value == false){
      //open the note section
      noteOpen.value = true;
      //the value changing to true will trigger a listener
      //that will set state and focus on the right field
    }
  }

  //-------------------------Next Function Helper's Helpers-------------------------

  toFirstItem(
    List<FieldData> fields, 
    bool autoAddFirstField, 
    Function addFirst, 
    Function alternative,
    ){
    bool fieldsPresent = (fields.length > 0);
    bool canAddFirstField = fieldsPresent == false && autoAddFirstField;
    if(fieldsPresent || canAddFirstField){
      if(canAddFirstField) addFirst(); //will focus after build
      else FocusScope.of(context).requestFocus(fields[0].focusNode);
    }
    else alternative();
  }

  //-------------------------Next Function Helpers-------------------------

  toFirstPhone(){ //TODO... shift addPhone to addFirstPhone
    toFirstItem(phoneValueFields, autoAddFirstPhone, addPhone, toFirstEmail);
  }

  toFirstEmail(){ //TODO... shift addEmail to addFirstEmail
    toFirstItem(emailValueFields, autoAddFirstEmail, addEmail, toWork);
  }

  toWork(){
    if(workOpen.value) FocusScope.of(context).requestFocus(jobTitleField.focusNode);
    else{
      if(autoOpenWork) openWork();
      else toFirstAddress();
    }
  }

  toFirstAddress(){ //TODO... shift addPostalAddress to addFirstPostalAddress
    toFirstItem(addressStreetFields, autoAddFirstAddress, addPostalAddress, toNote);
  }

  toNote(){
    if(noteOpen.value) FocusScope.of(context).requestFocus(noteField.focusNode);
    else{
      if(autoOpenNote) openNote();
      //ELSE... there is nothing else to do
    }
  }

  //-------------------------Add To List Helper-------------------------

  addItem(List<List<FieldData>> allFields){
    int newIndex = allFields[0].length; 

    //init all fields for the new item
    for(int i = 0; i < allFields.length; i++){
      allFields[i].add(FieldData()); //add both values
    }

    //set the state so the UI rebuilds with the new number
    setState(() {});

    //focus on the first field AFTER build completes (above)
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(allFields[0][newIndex].focusNode);
    });
  }

  //-------------------------Add To Lists-------------------------
  //NOTES: 
  //1. we always add at the end of the list
  //2. we must set state afterwards
  //3. whenever we add, we also have to focus on what we add

  addPhone(){
    //add field
    addItem([
      phoneValueFields,
    ]);

    //add default string
    phoneLabelStrings.add(
      ValueNotifier<String>(CategoryData.phoneLabels[0]),
    );
  }

  addEmail(){
    //add field
    addItem([
      emailValueFields,
    ]);

    //add default string
    emailLabelStrings.add(
      ValueNotifier<String>(CategoryData.emailLabels[0]),
    );
  }

  addPostalAddress(){
    //add field
    addItem([
      addressStreetFields,
      addressCityFields,
      addressPostcodeFields,
      addressRegionFields,
      addressCountryFields,
    ]);

    //add default string
    addressLabelStrings.add(
      ValueNotifier<String>(CategoryData.addressLabels[0]),
    );
  }

  //-------------------------Remove From Lists Helper-------------------------

  //NOTE: edge case where you delete the last item is handled
  //NOTE: if you are focused on some other item while deleting this one, your focus will not shift
  //NOTE: if you delete the last item in a list focus will be taken and keyboard closed
  removeItem(int index, List<List<FieldData>> allFields){
    if(0 <= index && index < allFields[0].length){
      //determine if we are currently focusing on any fields that will be deleted
      bool deleteFocusedField = false;
      for(int i = 0; i < allFields.length; i++){
        if(allFields[i][index].focusNode.hasFocus){
          deleteFocusedField = true;
          break;
        }
      }

      //remove the all fields of the item
      for(int i = 0; i < allFields.length; i++){
        allFields[i].removeAt(index);
      }

      //set the state so the UI rebuilds with the new number
      setState(() {});

      //focus on the NEXT field AFTER build completes (above)
      if(deleteFocusedField){
        print("length: " + allFields.length.toString());
        WidgetsBinding.instance.addPostFrameCallback((_){
          FocusScope.of(context).requestFocus(new FocusNode());
          //NOTE: we could focus on the "nextFunction" of the deleted item
          //but it seems more standard to simply close up the keybaord
        });
      }
      //ELSE... stay focused on whatever other field you were before deleting this one
    }
    //ELSE... we can't remove what doesn't exist
  }

  //-------------------------Remove From Lists-------------------------
  //NOTE: 
  //1. we can remove from any location in the list
  //2. we must set state afterwards
  //3. whenever we remove we also focus on whatever was going to be next
  //  on the thing we removed

  removePhone(int index){
    //remove field
    removeItem(index, [
      phoneValueFields,
    ]);

    //remove string
    phoneLabelStrings.removeAt(
      index,
    );
  }

  removeEmail(int index){
    //remove field
    removeItem(index, [
      emailValueFields,
    ]);

    //remove string
    emailLabelStrings.removeAt(
      index,
    );
  }

  removalPostalAddress(int index){
    //remove field
    removeItem(index, [
      addressStreetFields,
      addressCityFields,
      addressPostcodeFields,
      addressRegionFields,
      addressCountryFields,
    ]);

    //remove string
    addressLabelStrings.removeAt(
      index,
    );
  }

  //-------------------------Init-------------------------
  @override
  void initState() {
    workOpen.addListener((){
      //set state to reflect that change
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(jobTitleField.focusNode);
      });
    });

    noteOpen.addListener((){
      //set state to reflect that change
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(noteField.focusNode);
      });
    });

    //-------------------------Variable Prep-------------------------

    //prefix, first, middle, last, suffix
    int fieldCount = 0; //0,1,2,3,4
    while(fieldCount < 5){
      nameFields.add(FieldData());
      fieldCount++;
    }
    nameLabels.add("Name prefix");
    nameLabels.add("First name");
    nameLabels.add("Middle name");
    nameLabels.add("Last name");
    nameLabels.add("Name suffix");

    //-------------------------Other-------------------------

    //observer for onResume
    WidgetsBinding.instance.addObserver(this); 

    //NOTE: we could keep everything in its position 
    //IF after all the names are merged the merge name isn't updated
    //But that's too much work

    //if we spread or unspread the name
    namesSpread.addListener((){
      //modify text editing controller value
      if(namesSpread.value){ //if all the names have been spread
        //wipe all fields
        for(int i = 0; i < nameFields.length; i++){
          nameFields[i].controller.text = "";
        }

        //split the names
        List<String> names = nameField.controller.text.split(" ");

        //trim all the names of whitespace
        for(int i = 0; i < names.length; i++){
          names[i] = names[i].trim();
        }

        //start processing the split
        if(names.length > 0){
          //check if the first name is a prefix
          String maybePrefix = onlyCharacters(names[0].toLowerCase());
          bool isAPrefix = isPrefix(maybePrefix); 
          if(isAPrefix){
            nameFields[0].controller.text = names[0];
            names.removeAt(0);
          }

          //NOTE: now first name is at 0

          if(names.length > 0){
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
            int lastNameIndex = names.length - 1;
            String lastName = names[lastNameIndex];
            bool commaBeforeLast = (lastName.length > 0 && lastName[0] == ",");
            if(commaBeforeLast){
              //remove the comma
              names[lastNameIndex] = names[lastNameIndex].substring(1);
              //0(prefix), 1, 2, 3, 4(suffix)
              nameFields[4].controller.text = names[lastNameIndex];
              //remove this name from the list since it's been handled
              names.removeLast();
            }
            else{
              if(names.length > 1){
                String beforeLastName = names[lastNameIndex - 1];
                bool commaAfterBeforeLast = (beforeLastName.length > 0 && beforeLastName[beforeLastName.length - 1] == ",");
                if(commaAfterBeforeLast){
                  //remove the comma
                  names[lastNameIndex - 1] = names[lastNameIndex - 1].substring(0, beforeLastName.length - 1);
                  //0(prefix), 1, 2, 3, 4(suffix)
                  nameFields[4].controller.text = names[lastNameIndex - 1];
                  //remove this name from the list since it's been handled
                  names.removeLast();
                } 
                //ELSE... no preffix exists
              }
              //ELSE... we have no name before to check
            }

            if(names.length > 0){
              //NOTE: now only first(s), middle, and last names are left
              //1 name is first
              //2 names first, last
              //3 names first, middle, last
              //4+ mames (other), before last, last

              switch(names.length){
                case 1:
                  if(isAPrefix){ //consider last name
                    nameFields[3].controller.text = names[0];
                  }
                  else{
                    nameFields[1].controller.text = names[0];
                  }

                  break;
                case 2:
                  //set first name
                  nameFields[1].controller.text = names[0];
                  //set last name
                  nameFields[3].controller.text = names[1];

                  break;
                case 3:
                  //set first name
                  nameFields[1].controller.text = names[0];
                  //set middle name
                  nameFields[2].controller.text = names[1];
                  //set last name
                  nameFields[3].controller.text = names[2];

                  break;
                default:
                  //the first removal is the last name
                  String lastName = names.removeLast();
                  nameFields[3].controller.text = lastName;

                  //the second removal is the middle name
                  String middleName = names.removeLast();
                  nameFields[2].controller.text = middleName;

                  //sum all the rest of the names as the first name
                  String firstName = "";
                  for(int i = 0; i < names.length; i++){
                    firstName = firstName + names[i];
                  }
                  nameFields[3].controller.text = firstName;

                  break;
              }
            }
          }
        }
      }
      else{ //If all the names have been closed
        //combine all the names into a single name
        //NOTE: before suffix we add a ','
        String name = "";
        for(int i = 0; i < nameFields.length; i++){
          FieldData thisField = nameFields[i];
          String text = thisField.controller.text.trim();
          if(i == (nameFields.length - 1)){
            if(text != ""){
              if(name == ""){
                name += "," + text;
              }
              else{
                name += " ," + text;
              }
            }
          }
          else{
            if(i == 0) name = text;
            else{ //there is some text already in the name
              //so to do things properly we have to add a space behind us
              if(text != ""){
                name = name + " " + text;
              }
            }
          }
        }

        //set the combine name into our field
        nameField.controller.text = name;
      }

      //actually open the names
      setState(() {});

      //focus on the proper name
      WidgetsBinding.instance.addPostFrameCallback((_){
        if(namesSpread.value){ //if all the names have been spread
          FocusScope.of(context).requestFocus(nameFields[1].focusNode);
        }
        else{ //If all the names have been closed
          FocusScope.of(context).requestFocus(nameField.focusNode);
        }
      });
    });

    //super init
    super.initState();
  }

  //-------------------------Dispose-------------------------
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //-------------------------Change-------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /*
    IF we have access now we save the contact and run onselect
    ELSE we wait for the user to decide what to do
    */
    if(state == AppLifecycleState.resumed) onResume();
  }

  //this run even if the image picker modal is above it
  //which is why we need the 2 variables
  onResume() async{
    print("*************************NEW CONTACT RESUME");
    if(backFromPermissionPage.value){
      backFromPermissionPage.value = false;
      PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;

      //since the permissions page was brought up because the user wanted to save the contact
      //we can imply the user wants to save the contact immediately after ther permissions page
      //WITHOUT making any changes
      if(isAuthorized(permissionStatus)){
        createContact();
      }
      //ELSE... we might let them just go back, edit the contact, or etc
    }
    //ELSE we are back from either picking an image or deciding not to pick an image, both of which do nothing
  }

  //-------------------------build-------------------------
  @override
  Widget build(BuildContext context) {
    print("*****BUILDING*****");

    //TODO... I should be able to shift everything below to init
    //from our name field we move onto the first phone
    //or whatever else we can
    nameField.nextFunction = toFirstPhone;
    
    //only if we are in our last name do we move onto our first phone
    //or whatever else we can
    for(int i = 0; i < nameFields.length; i++){
      FieldData thisField = nameFields[i];
      if(i != (nameFields.length - 1)){ //not last index
        thisField.nextFunction = (){
          FocusScope.of(context).requestFocus(nameFields[i+1].focusNode);
        };
      }
      else thisField.nextFunction = toFirstPhone;
    }
    
    //phones section
    for(int i = 0; i < phoneValueFields.length; i++){
      FieldData thisField = phoneValueFields[i];
      if(i != (phoneValueFields.length - 1)){ //not last index
        thisField.nextFunction = (){
          FocusScope.of(context).requestFocus(phoneValueFields[i+1].focusNode);
        };
      }
      else thisField.nextFunction = toFirstEmail;
    }

    //emails section
    for(int i = 0; i < emailValueFields.length; i++){
      FieldData thisField = emailValueFields[i];
      if(i != (emailValueFields.length - 1)){ //not last index
        thisField.nextFunction = (){
          FocusScope.of(context).requestFocus(emailValueFields[i+1].focusNode);
        };
      }
      else thisField.nextFunction = toWork;
    }

    //handle work section
    jobTitleField.nextFunction = (){
      FocusScope.of(context).requestFocus(companyField.focusNode);
    };
    companyField.nextFunction = toFirstAddress;

    //TODO... addresses section

    //handle note section
    noteField.nextFunction = null;

    return OrientationBuilder(
      builder: (context, orientation) {
        bool isPortrait = (orientation == Orientation.portrait);

        //calc bottom bar height
        double bottomBarHeight = 32;
        if(isPortrait == false) bottomBarHeight = 0;

        return NewContactOuterShell(
          cancelContact: cancelContact,
          createContact: createContact,
          imageLocation: imageLocation,
          onImagePicked: () => setState(() {}),
          isPortrait: isPortrait,
          bottomBarHeight: bottomBarHeight,
          fields: NewContactUX(
            //names stuff
            bottomBarHeight: bottomBarHeight,
            namesSpread: namesSpread,
            nameField: nameField,
            nameFields: nameFields,
            nameLabels: nameLabels,

            //phones
            addPhone: addPhone,
            removePhone: removePhone,
            phoneFields: phoneValueFields,
            phoneLabels: phoneLabelStrings,

            //emails
            addEmail: addEmail,
            removeEmail: removeEmail,
            emailFields: emailValueFields,
            emailLabels: emailLabelStrings,

            //work stuff
            jobTitleField: jobTitleField,
            companyField: companyField,
            workOpen: workOpen,

            //address
            //TODO... address stuff

            //note stuff
            noteField: noteField,
            noteOpen: noteOpen,
          ),
        );
      }
    );
  }

  //-------------------------Save Contact Helper-------------------------
  List<Item> itemFieldData2ItemList(List<FieldData> values, List<ValueNotifier<String>> labels){
    List<Item> itemList = new List<Item>();
    for(int i = 0; i < values.length; i++){
      itemList.add(Item(
        value: values[i].controller.text,
        label: labels[i].value,
      ));
    }
    return itemList;
  }

  List<PostalAddress> fieldsToAddresses(){
    List<PostalAddress> addresses = new List<PostalAddress>();
    for(int i = 0; i < addressStreetFields.length; i++){
      addresses.add(PostalAddress(
        street: addressStreetFields[i].controller.text,
        city: addressCityFields[i].controller.text,
        postcode: addressPostcodeFields[i].controller.text,
        region: addressRegionFields[i].controller.text,
        country: addressCountryFields[i].controller.text,
        label: addressLabelStrings[i].value,
      ));
    }
    return addresses;
  }

  //-------------------------Submit Action Functionality-------------------------
  cancelContact(){
    Navigator.of(context).pop();
  }

  createContact() async{
    //create empty contact
    Contact newContact = new Contact();

    //save the image
    if(imageLocation.value != ""){
      List<int> avatarList = await File(imageLocation.value).readAsBytes();
      newContact.avatar = Uint8List.fromList(avatarList);
    }

    //save the name(s)
    newContact.givenName = nameField.controller.text;

    newContact.prefix = nameFields[0].controller.text;
    newContact.displayName = nameFields[1].controller.text;
    newContact.middleName = nameFields[2].controller.text;
    newContact.familyName = nameFields[3].controller.text;
    newContact.suffix = nameFields[4].controller.text;

    //save the phones
    newContact.phones = itemFieldData2ItemList(
      phoneValueFields, 
      phoneLabelStrings,
    );

    //save the emails
    newContact.emails= itemFieldData2ItemList(
      emailValueFields, 
      emailLabelStrings,
    );

    //save the work stuff
    newContact.jobTitle = jobTitleField.controller.text;
    newContact.company = companyField.controller.text;

    //save the addresses
    //TODO... save the addresses

    //save the note
    newContact.note = noteField.controller.text;

    //TODO... remove this test code
    // The contact must have a firstName / lastName to be successfully added
    if(newContact.givenName == "") newContact.givenName = "given";
    if(newContact.displayName == "") newContact.displayName = "display";
    if(newContact.familyName == "") newContact.familyName = "family";
    if(newContact.middleName == "") newContact.middleName = "middle";
    newContact.phones = [Item(value: "9567772692", label: "mobile")];

    //handle permissions
    PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    if(isAuthorized(permissionStatus)){
      //with permission we can both
      //1. add the contact
      //NOTE: The contact must have a firstName / lastName to be successfully added  
      await ContactsService.addContact(new Contact(givenName: "a", familyName: "b"));  
      //2. and update the contact
      widget.onSelect(context, newContact);
    }
    else{
      //we know that we don't have permission so we know either the modal or page will pop up
      backFromPermissionPage.value = true;

      //without permission we give the user the option to ONLY
      //1. update the contact
      permissionRequired(
        context,
        //the user is never forced to create a contact, only to select one
        false, 
        false, //we are creating a contact
        (){
          //on Select only updates the contact
          //or the user can give us permission and come back and add it as well
          widget.onSelect(context, newContact);
        }
      );
    }
  }
}