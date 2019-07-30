import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/newContactHelper.dart';
import 'package:not_at_home/permission.dart';
import 'package:permission/permission.dart';

import 'helper.dart';
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
  List<FieldData> phoneLabelFields = List<FieldData>();

  //-------------------------Emails
  bool autoAddFirstEmail = true;
  List<FieldData> emailValueFields = List<FieldData>();
  List<FieldData> emailLabelFields = List<FieldData>();

  //-------------------------Work
  bool autoOpenWork = true;
  FieldData jobTitleField = FieldData(); //jobTitle
  FieldData companyName = FieldData(); //company
  bool workOpen = false;

  //-------------------------Addresses
  bool autoAddFirstAddress = false; //add
  List<FieldData> addressStreetFields = new List<FieldData>();
  List<FieldData> addressCityFields = new List<FieldData>();
  List<FieldData> addressPostcodeFields = new List<FieldData>();
  List<FieldData> addressRegionFields = new List<FieldData>();
  List<FieldData> addressCountryFields = new List<FieldData>();
  List<FieldData> addressLabelFields = new List<FieldData>();

  //-------------------------Note
  bool autoOpenNote = true;
  FieldData noteField = FieldData(); //note
  bool noteOpen = false;

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
    if(workOpen == false){
      //open the work section
      workOpen = true;

      //set state to reflect that change
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(jobTitleField.focusNode);
      });
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
    if(noteOpen == false){
      //open the note section
      noteOpen = true;

      //set state to reflect that change
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(noteField.focusNode);
      });
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

  toFirstPhone(){
    toFirstItem(phoneValueFields, autoAddFirstPhone, addPhone, toFirstEmail);
  }

  toFirstEmail(){
    toFirstItem(emailValueFields, autoAddFirstEmail, addEmail, toWork);
  }

  toWork(){
    if(workOpen) FocusScope.of(context).requestFocus(jobTitleField.focusNode);
    else{
      if(autoOpenWork) openWork();
      else toFirstAddress();
    }
  }

  toFirstAddress(){
    toFirstItem(addressStreetFields, autoAddFirstAddress, addPostalAddress, toNote);
  }

  toNote(){
    if(noteOpen) FocusScope.of(context).requestFocus(noteField.focusNode);
    else{
      if(autoOpenNote) openNote();
      //ELSE... there is nothing else to do
    }
  }

  //-------------------------Add To List Helper-------------------------

  addItem(List<List<FieldData>> allFields){
    int newIndex = allFields[0].length;

    //init all fields
    for(int i = 0; i < allFields.length; i++){
      allFields[i].add(FieldData()); //add both values
      allFields[i][newIndex].index = newIndex; //set the indices
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
    addItem([
      phoneValueFields,
      phoneLabelFields,
    ]);
  }

  addEmail(){
    addItem([
      emailValueFields,
      emailLabelFields,
    ]);
  }

  addPostalAddress(){
    addItem([
      addressStreetFields,
      addressCityFields,
      addressPostcodeFields,
      addressRegionFields,
      addressCountryFields,
      addressLabelFields,
    ]);
  }

  //-------------------------Remove From Lists Helper-------------------------

  removeItem(int index, List<List<FieldData>> allFields){
    if(0 <= index && index < allFields[0].length){
      //save next focus function
      Function nextFocus = allFields.last[index].nextFunction;

      //remove the item
      for(int i = 0; i < allFields.length; i++){
        allFields[i].removeAt(index);
      }

      //set the state so the UI rebuilds with the new number
      setState(() {});

      //focus on the NEXT field AFTER build completes (above)
      WidgetsBinding.instance.addPostFrameCallback((_){
        nextFocus();
      });
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
    removeItem(index, [
      phoneValueFields,
      phoneLabelFields,
    ]);
  }

  removeEmail(int index){
    removeItem(index, [
      emailValueFields,
      emailLabelFields,
    ]);
  }

  removalPostalAddress(int index){
    removeItem(index, [
      addressStreetFields,
      addressCityFields,
      addressPostcodeFields,
      addressRegionFields,
      addressCountryFields,
      addressLabelFields,
    ]);
  }

  //-------------------------Init-------------------------
  @override
  void initState() {
    //-------------------------Variable Prep-------------------------

    //prefix, first, middle, last, suffix
    int fieldCount = 0; //0,1,2,3,4
    while(fieldCount < 5){
      nameFields.add(FieldData());
      nameFields[fieldCount].index = fieldCount;
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

    //if we spread or unspread the name
    namesSpread.addListener((){
      //actually open the names
      setState(() {});
      //focus on the proper name
      WidgetsBinding.instance.addPostFrameCallback((_){
        //Feature copied for samsung contacts
        if(namesSpread.value){
          //if all the names have been spread
          //TODO... break apart all the names
          //focus on the first name
          FocusScope.of(context).requestFocus(nameFields[1].focusNode);
        }
        else{
          //If all the names have been close
          //TODO... combine all the names into a single name in nameFocusNode
          //then focus on the combined names
          FocusScope.of(context).requestFocus(nameField.focusNode);
        }
      });
    });
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

    //TODO... fill all the function arguments depending on current vars

    //from our name field we move onto the first phone
    //or whatever else we can
    nameField.nextFunction = toFirstPhone;
    
    //only if we are in our last name do we move onto our first phone
    //or whatever else we can
    for(int i = 0; i < nameFields.length; i++){
      FieldData thisField = nameFields[i];
      if(i != (nameFields.length - 1)){
        thisField.nextFunction = (){
          FocusScope.of(context).requestFocus(nameFields[i+1].focusNode);
        };
      }
      else thisField.nextFunction = toFirstPhone;
    }
    
    //TODO... move onto doing phone section

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
            bottomBarHeight: bottomBarHeight,
            namesSpread: namesSpread,
            nameField: nameField,
            nameFields: nameFields,
            nameLabels: nameLabels,
          ),
        );
      }
    );
  }

  //-------------------------Save Contact Helper-------------------------
  List<Item> itemFieldData2ItemList(List<FieldData> values, List<FieldData> labels){
    List<Item> itemList = new List<Item>();
    for(int i = 0; i < values.length; i++){
      itemList.add(Item(
        value: values[i].controller.text,
        label: labels[i].controller.text,
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
        label: addressLabelFields[i].controller.text,
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
      phoneLabelFields,
    );

    //save the emails
    newContact.emails= itemFieldData2ItemList(
      emailValueFields, 
      emailLabelFields,
    );

    //save the work stuff
    newContact.jobTitle = jobTitleField.controller.text;
    newContact.company = companyName.controller.text;

    //save the addresses

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
      print("AUTHORIZED-------------------------");

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