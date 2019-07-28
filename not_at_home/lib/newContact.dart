import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:permission/permission.dart';

import 'helper.dart';
import 'imagePicker.dart';
import 'newContactUX.dart';

class FieldData{
  int index;
  TextEditingController controller;
  FocusNode focusNode;
  Function nextFunction;

  FieldData(){
    index = 0;
    controller = new TextEditingController();
    focusNode = new FocusNode();
    nextFunction = (){
      print("next field");
    };
  }
}

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

  //-------------------------Add To Lists-------------------------
  //NOTE: MUST SET STATE
  //NOTE: we always add at the end

  addPhone(){
    int newIndex = phoneValueFields.length;

    //add both values
    phoneValueFields.add(FieldData());
    phoneLabelFields.add(FieldData());

    //set the indices
    phoneValueFields[newIndex].index = newIndex;
    phoneLabelFields[newIndex].index = newIndex;

    //set the state so the UI rebuilds with the new number
    setState(() {});
  }

  addEmail(){

  }

  addPostalAddress(){

  }

  //-------------------------Remove From Lists-------------------------
  //NOTE: MUST SET STATE

  removePhone(int index){
    
  }

  removeEmail(int index){

  }

  removalPostalAddress(int index){

  }

  //-------------------------Next Function Helpers-------------------------

  //start with value
  addFirstPhone(){
    if(phoneValueFields.isEmpty){
      //add the phone
      addPhone();

      //focus on the first field AFTER build completes (above)
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(phoneValueFields[0].focusNode);
      });
    }
  }

  //start with value
  addFirstEmail(){
    if(emailValueFields.isEmpty){
      //add the email
      addEmail();

      //focus on the first field AFTER build completes (above)
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(emailValueFields[0].focusNode);
      });
    }
  }

  //starting with job title
  openWork(){
    if(workOpen == false){
      //open the work section
      workOpen = true;
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
      //add the postal address
      addPostalAddress();

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(addressStreetFields[0].focusNode);
      });      
    }
  }

  //start with note (only way to start :p)
  openNote(){
    if(noteOpen == false){
      //open the note section
      noteOpen = true;
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_){
        FocusScope.of(context).requestFocus(noteField.focusNode);
      });
    }
  }

  //-------------------------Next Function Helpers-------------------------

  toFirstPhone() async{
    bool phonesPresent = (phoneValueFields.length > 0);
    bool canAddPhone = phonesPresent == false && autoAddFirstPhone;
    if(phonesPresent || canAddPhone){
      if(canAddPhone) addFirstPhone();
      else FocusScope.of(context).requestFocus(phoneValueFields[0].focusNode);
    }
    else toFirstEmail();
  }

  toFirstEmail() async{
    bool emailsPresent = (emailValueFields.length > 0);
    bool canAddEmail = emailsPresent == false && autoAddFirstEmail;
    if(emailsPresent || canAddEmail){
      if(canAddEmail) addFirstPhone();
      else FocusScope.of(context).requestFocus(emailValueFields[0].focusNode);
    }
    else toWork();
  }

  toWork() async{
    if(workOpen) FocusScope.of(context).requestFocus(jobTitleField.focusNode);
    else{
      if(autoOpenWork) openWork();
      else toFirstAddress();
    }
  }

  toFirstAddress() async{
    bool addressesPresent = (addressStreetFields.length > 0);
    bool canAddAddress = addressesPresent == false && autoAddFirstAddress;
    if(addressesPresent || canAddAddress){
      if(canAddAddress) addFirstPhone();
      else FocusScope.of(context).requestFocus(addressStreetFields[0].focusNode);
    }
    else toNote();
  }

  toNote() async{
    if(noteOpen) FocusScope.of(context).requestFocus(noteField.focusNode);
    else{
      if(autoOpenNote) openNote();
      //ELSE... there is nothing else to do
    }
  }

  //-------------------------Init-------------------------
  @override
  void initState() {
    //-------------------------Variable Prep-------------------------

    //-------------------------Name
    nameField.nextFunction = toFirstPhone();

    //-------------------------Names
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
    return OrientationBuilder(
      builder: (context, orientation) {
        bool isPortrait = (orientation == Orientation.portrait);

        //calc bottom bar height
        double bottomBarHeight = 32;
        if(isPortrait == false) bottomBarHeight = 0;

        //calc imageDiameter
        double imageDiameter = MediaQuery.of(context).size.width / 2;
        if(isPortrait == false){
          imageDiameter = MediaQuery.of(context).size.height / 2;
        }

        //make new contact UX
        Widget bodyWidget = ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(
                    8,
                    //push CARD down to the ABOUT middle of the picture
                    imageDiameter * (5/7),
                    8,
                    16,
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Card(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(
                            0, 
                            //push CARD CONTENT down to past the picture
                            imageDiameter * (2/7) + 16 * 2, 
                            16, 
                            16,
                          ),
                          child: Column(
                            children: <Widget>[
                              Text("asdfadsfads") //TODO... field items here
                            ],
                          )
                        ),
                      ),
                      //makes sure that we can always see all of our items
                      //with a little extra padding for looks
                      Container(
                        height: bottomBarHeight + 16,
                      ),
                    ],
                  ),
                ),
                //-------------------------Picture UX
                Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: (){
                      showImagePicker(
                        context,
                        imageLocation,
                        //we set state so we update the picture
                        () => setState(() {}),
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        new Container(
                          width: imageDiameter,
                          height: imageDiameter,
                          decoration: new BoxDecoration(
                            color: Theme.of(context).indicatorColor,
                            shape: BoxShape.circle,
                          ),
                          child: (imageLocation.value == "") ? Icon(
                            Icons.camera_alt,
                            size: imageDiameter / 2,
                            color: Theme.of(context).primaryColor,
                          )
                          : ClipOval(
                            child: FittedBox(
                              fit: BoxFit.cover,
                                child: Image.file(
                                File(imageLocation.value),
                              ),
                            )
                          )
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: new Container(
                            padding: EdgeInsets.all(8),
                            decoration: new BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                width: 3,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColorLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        //-------------------------Submit Button Locations
        if(isPortrait){
          //in portrait mode the buttons are large and at the bottom of the screen
          return Scaffold(
            body: Stack(
              children: <Widget>[
                bodyWidget,
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Theme.of(context).primaryColorDark,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left:16, right:16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new PortraitButton(
                          width: MediaQuery.of(context).size.width / 2 - 16,
                          name: "Cancel",
                          onPressed: () => cancelContact(),
                        ),
                        new PortraitButton(
                          width: MediaQuery.of(context).size.width / 2 - 16,
                          name: "Save",
                          onPressed: () => createContact(),
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
          );
        }
        else{
          //In landscape mode the buttons are small and on the app bar
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: <Widget>[
                new LandscapeButton(
                  func: () => cancelContact(),
                  str: "Cancel",
                ),
                new LandscapeButton(
                  func: () => createContact(), 
                  str: "Save",
                )
              ],
            ),
            body: bodyWidget,
          );
        }
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
    newContact.note = noteField.text;

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

//-------------------------Helper Widgets-------------------------

//the buttons used when the app is in landscape mode
class LandscapeButton extends StatelessWidget {
  const LandscapeButton({
    Key key,
    @required this.func,
    @required this.str,
  }) : super(key: key);

  final Function func;
  final String str;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        func();
      },
      child: Text(str),
    );
  }
}

//the buttons used when the app is in portrait mode
class PortraitButton extends StatelessWidget {
  final String name;
  final Function onPressed;
  final double width;

  const PortraitButton({
    this.name,
    this.onPressed,
    this.width,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: new OutlineButton(
        child: new Text(
          name,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        onPressed: onPressed,
        highlightedBorderColor: Colors.transparent,
        disabledBorderColor: Colors.transparent,
        borderSide: BorderSide(style: BorderStyle.none),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}