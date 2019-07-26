import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:not_at_home/helper.dart';
import 'package:permission/permission.dart';

//required because of how the permission plugin operates
final ValueNotifier<bool> firstTime = new ValueNotifier<bool>(true);

//request contact permission from the user
permissionRequired(BuildContext context, bool forcePermission, bool selectingContact, Function onSecondaryOption) async{
  //---bottom
  PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
  print("-------------------------before start " + startStatus.toString() + " " + firstTime.value.toString());
  if(isAuthorized(startStatus) == false){
    print("-------------------------Before (NOT AUTH) " + DateTime.now().toString());
    //NOTE: if notAgain && not firstTime -> guaranted notAgain
    //else if notAgain && firstTime -> maybe not valid notAgain 
    //  IF valid should show manual ELSE should ASK FOR PERMISSION
    //else we can ASK FOR PERMISSION -> if fail ask again


    if(startStatus == PermissionStatus.notAgain && !firstTime.value){
      print("-------------------------pushing new screen");
      showDialog(
        context: context,
        barrierDismissible: (forcePermission == false),
        builder: (BuildContext context) {
          return Manual(
            forcePermission: forcePermission,
            selectingContact: selectingContact,
            onSecondaryOption: onSecondaryOption,
          );
        },
      );
    }
    else{
      print("-------------------------permission request " + DateTime.now().toIso8601String());

      //covers edge case where the first time we request a permission its status is not at home
      firstTime.value = false;

      //ask for permission
      PermissionStatus status = (await Permission.requestPermissions([PermissionName.Contacts]))[0].permissionStatus;
      print("-------------------------result " + status.toString() + " " + DateTime.now().toIso8601String());
      if(isAuthorized(status) == false){
        //---top
        permissionRequired(context, forcePermission, selectingContact, onSecondaryOption);
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

  Manual({
    @required this.forcePermission,
    @required this.selectingContact,
    @required this.onSecondaryOption,
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

  //build
  @override
  Widget build(BuildContext context) {
    bool isSelecting = widget.selectingContact;

    return WillPopScope(
      onWillPop:  () async => (widget.forcePermission == false),
      child: Theme(
        data: ThemeData.light(),
        child: AlertDialog(
          title: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.contacts,
                  color: Theme.of(context).buttonColor,
                ),
              ),
              new Text("Grant Us Access"),
            ],
          ),
          content: new Text(
            "In order to " + ((isSelecting) ? "\"Select\"" : "\"Save\"") + " a Contact. "
            + "\n\n" + "Enable \"Contacts\" in the \"Permissions\" section of \"App Settings\""
            + "\n" + ((isSelecting) ? "Or Manually Input the Contact below" : "Use the Contact without saving it below"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text((isSelecting) ? "Manual Input" : "Use Don't Save"),
              onPressed: () {
                if(isSelecting){ //manual input
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
                else{ //use don't save
                  widget.onSecondaryOption();
                }
              },
            ),
            new RaisedButton(
              textColor: Colors.white,
              child: new Text(
                "Settings",
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
                  print("change phone");
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