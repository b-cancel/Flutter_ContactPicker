import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:not_at_home/helper.dart';
import 'package:not_at_home/selectContact/selectContactLogic.dart';
import 'package:permission/permission.dart';
import 'package:contact_picker/contact_picker.dart' as contactPicker;

//required because of how the permission plugin operates
final ValueNotifier<bool> contactFirstTime = new ValueNotifier<bool>(true);

//request contact permission from the user
checkContactPermission(
  BuildContext context, 
  bool forcePermission, 
  bool selectingContact, 
  Function onSecondaryOption,
  {SelectContactBackUp selectContactBackUp: SelectContactBackUp.manualInput}
) async{
  PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
  if(isAuthorized(startStatus) == false){
    //NOTE: if notAgain && not firstTime -> guaranted notAgain
    //else if notAgain && firstTime -> maybe not valid notAgain 
    //  IF valid should show manual ELSE should ASK FOR PERMISSION
    //else we can ASK FOR PERMISSION -> if fail ask again

    if(startStatus == PermissionStatus.notAgain && !contactFirstTime.value){
      //NOTE: the below is taken care of by willPopScope function
      //when force permission is FALSE
      //AND we are selecting a contact -> we also need to pop back to whatever page brought us up
      //AND we are creating a contact -> we don't need to pop back because from the create contact page we retrigger things
      showDialog(
        context: context,
        barrierDismissible: (forcePermission == false),
        builder: (BuildContext context) {
          return Manual(
            forcePermission: forcePermission,
            selectingContact: selectingContact,
            onSecondaryOption: onSecondaryOption,
            selectContactBackUp: selectContactBackUp,
          );
        },
      );
    }
    else{
      //covers edge case where the first time we request a permission its status is not at home
      contactFirstTime.value = false;

      //ask for permission
      PermissionStatus status = (await Permission.requestPermissions([PermissionName.Contacts]))[0].permissionStatus;
      if(isAuthorized(status) == false){
        //---top
        checkContactPermission(
          context, 
          forcePermission, 
          selectingContact, 
          onSecondaryOption,
          selectContactBackUp: selectContactBackUp,
        );
      }
    }
  }
  //ELSE... permission already given
}

//display the WE NEED PERMISSION pop up
class Manual extends StatefulWidget {
  final bool forcePermission;
  final bool selectingContact;
  final Function onSecondaryOption;
  final SelectContactBackUp selectContactBackUp;

  Manual({
    @required this.forcePermission,
    @required this.selectingContact,
    @required this.onSecondaryOption,
    @required this.selectContactBackUp,
  });

  @override
  _ManualState createState() => _ManualState();
}

class _ManualState extends State<Manual> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //If the user came back to the permission page they must have traveled away from it
  //If they traveled away from it temporarily, it must have been because they decided to open 'App Settings'
  //because if they would have instead clicked BACK or select manual input
  //that would have traveled away from it permanently and this wouldn't run
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed && state != AppLifecycleState.paused){
      checkIfCanPop();
    }
  }

  //If the user came back having given us permission then we automatically pop
  //ELSE we let the read the message so we can evetually pop or allow then the other navigation options
  void checkIfCanPop() async{
    PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
    if(isAuthorized(permissionStatus)){
      Navigator.of(context).pop();
    }
  }

  final contactPicker.ContactPicker contactPickerInstance = new contactPicker.ContactPicker();

  //build
  @override
  Widget build(BuildContext context) {
    bool isSelecting = widget.selectingContact;
    bool manualInput = (widget.selectContactBackUp == SelectContactBackUp.manualInput);

    String inOrderTo = "In order to " + ((isSelecting) ? "\"Select\"" : "\"Save\"") + " a Contact.";
    String action = "Enable \"Contacts\" in the \"Permissions\" section of \"App Settings\"";
    String options;
    if(isSelecting){
      if(manualInput) options = "Or Manually Input the Contact below";
      else options = "Or \"System Select Contact\" below";
    }
    else options = "Use the Contact without saving it below";

    String altButton;
    if(isSelecting){
      if(manualInput) altButton = "Manual Input";
      else altButton = "System Select Contact";
    }
    else altButton = "Use Don't Save";

    //NOTE: required on top of barrier dismissible thing
    return WillPopScope(
      //NOTE: this is also triggered when we press the dismissable barrier
      //when force permission is FALSE
      //AND we are selecting a contact -> we also need to pop back to whatever page brought us up
      //AND we are creating a contact -> we don't need to pop back because from the create contact page we retrigger things
      onWillPop:  () async{
        //TODO... test this
        if(widget.forcePermission == false && widget.selectingContact){
          Navigator.pop(context);
        }
        return (widget.forcePermission == false);
      },
      child: Theme(
        data: ThemeData.light(),
        child: AlertDialog(
          title: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.contacts,
                  color: Colors.black,
                ),
              ),
              new Text("Grant Us Access"),
            ],
          ),
          content: new Text(
            inOrderTo + "\n\n" + action + "\n" + options,
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(altButton),
              onPressed: () async{
                if(isSelecting){ //manual input
                  if(manualInput){
                    showDialog(
                      context: context,
                      //NOTE: the barrier should be dismissible ALWAYS
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return ManualInput(
                          //this is simply passing a reference to a dynamic function 
                          //that can take 2 params 1. context 2. contact
                          onSubmit: widget.onSecondaryOption,
                        );
                      },
                    );
                  }
                  else{
                    contactPicker.Contact selectedContact = await contactPickerInstance.selectContact();
                    if(selectedContact != null){
                      //retreive system contact
                      String name = selectedContact.fullName;
                      Item number = Item(
                        value: selectedContact.phoneNumber.number,
                        label: selectedContact.phoneNumber.label,
                      );

                      //conver to other contact
                      Contact newContact = new Contact(
                        givenName: name,
                        phones: [number],
                      );

                      //select the contact
                      widget.onSecondaryOption(
                        context,
                        newContact,
                      );
                    }
                  }
                }
                else{ //use don't save
                  widget.onSecondaryOption();
                }
              },
            ),
            new RaisedButton(
              textColor: Colors.white,
              child: new Text(
                "App Settings",
              ),
              onPressed: (){
                Permission.openSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}

//display the we ATLEAST NEED MANUAL CONTACT box if you won't give us permission
//NOTE: here we know for a fact that we come from SELECTING A CONTACT
//AND: since the user could decide inputting the contact is too much work
//  we also don't force the user to stay here, they can back out if desired
class ManualInput extends StatefulWidget {
  const ManualInput({
    Key key,
    @required this.onSubmit,
  }) : super(key: key);

  final onSubmit;

  @override
  _ManualInputState createState() => _ManualInputState();
}

class _ManualInputState extends State<ManualInput> {
  //keep track of whether or not the form is valid
  ValueNotifier<bool> nameValid = new ValueNotifier<bool>(false);
  ValueNotifier<bool> phoneValid = new ValueNotifier<bool>(false);

  //Focus Nodes for our form fields
  FocusNode nameFN = new FocusNode();
  FocusNode phoneFN = new FocusNode();

  //the text editing controllers for our form fields
  TextEditingController nameCtrl = new TextEditingController();
  TextEditingController phoneCtrl = new TextEditingController();

  isNameValid(){
    nameValid.value = (nameCtrl.text != "");
  }
  
  isPhoneValid(){
    phoneValid.value = (onlyNumbers(phoneCtrl.text).length >= 10);
  }

  //determine what to do after a user finishes filling a field
  submitOrRefocus({bool onName: true}){
    if(nameValid.value && phoneValid.value) submitForm();
    else{
      //if we are on phone field and it isn't valid then stay
      if(onName != null && onName == false && phoneValid.value == false) return; //stay in phone
      else{ //focus on the first field that isnt valid
        if(nameValid.value == false) FocusScope.of(context).requestFocus(nameFN);
        else FocusScope.of(context).requestFocus(phoneFN);
      }
    }
  }

  //create the valid contact and submit it
  submitForm(){
    widget.onSubmit(context, new Contact(
      givenName: nameCtrl.text,
      phones: [Item(value: onlyNumbers(phoneCtrl.text), label: "manual")]
    ));
  }

  //init
  @override
  void initState() {
    //focus our name at the start
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(nameFN);
    });

    //set state on both things changing to update keyboard buttons
    nameValid.addListener((){
      setState(() {});
    });

    phoneValid.addListener((){
      setState(() {});
    });

    //super init
    super.initState();
  }

  //build
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.contacts,
                color: Theme.of(context).buttonColor,
              ),
            ),
            Expanded(
              child: new Text("Manually Add Contact"),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                //basics
                maxLines: 1,
                focusNode: nameFN,
                controller: nameCtrl,
                //if the other field is valid show submit
                textInputAction: (phoneValid.value)
                ? TextInputAction.done
                : TextInputAction.next,
                //decoration to indicate field type
                decoration: InputDecoration(
                  labelText: "Name",
                  helperText: "must not be empty"
                ),
                //on button action
                onEditingComplete: (){
                  submitOrRefocus(onName: true);
                },
                //update valid status
                onChanged: (str){
                  isNameValid();
                },
              ),
              TextField(
                maxLines: 1,
                focusNode: phoneFN,
                controller: phoneCtrl,
                //if the other field is valid show submit
                textInputAction: (nameValid.value) 
                ? TextInputAction.done
                : TextInputAction.next,
                //change keyboard for phone number
                keyboardType: TextInputType.number,
                //decoration to indicate field type
                decoration: InputDecoration(
                  labelText: "Phone",
                  helperText: "must be a valid number"
                ),
                //on button action
                onEditingComplete: (){
                  submitOrRefocus(onName: false);
                },
                //update valid status
                onChanged: (str){
                  isPhoneValid();
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Grant Permission"),
            onPressed: () {
              Navigator.pop(context);
              //this is implicit we can save the user an extra click
              Permission.openSettings();
            },
          ),
          new RaisedButton(
            textColor: Colors.white,
            child: new Text(
              "Add Contact",
            ),
            //disable the button until conditions are met
            //NOTE: we ONLY wait for one condition because otherwise we would have to check if conditions are met while we are typing
            onPressed: (nameValid.value && phoneValid.value)
            ? submitForm
            : null,
          ),
        ],
      ),
    );
  }
}