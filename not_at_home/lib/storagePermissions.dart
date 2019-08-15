import 'package:flutter/material.dart';
import 'package:not_at_home/helper.dart';
import 'package:permission/permission.dart';

//required because of how the permission plugin operates
final ValueNotifier<bool> storageFirstTime = new ValueNotifier<bool>(true);

//request contact permission from the user
checkStoragePermission(
  BuildContext context, 
  Function onPermissionGiven,
) async{
  PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0].permissionStatus;
  if(isAuthorized(startStatus) == false){
    //NOTE: if notAgain && not firstTime -> guaranted notAgain
    //else if notAgain && firstTime -> maybe not valid notAgain 
    //  IF valid should show manual ELSE should ASK FOR PERMISSION
    //else we can ASK FOR PERMISSION -> if fail ask again

    if(startStatus == PermissionStatus.notAgain && !storageFirstTime.value){
      //NOTE: the below is taken care of by willPopScope function
      //when force permission is FALSE
      //AND we are selecting a contact -> we also need to pop back to whatever page brought us up
      //AND we are creating a contact -> we don't need to pop back because from the create contact page we retrigger things
      showDialog(
        context: context,
        barrierDismissible: true, //TODO... check (we are indeed never forcing)
        builder: (BuildContext context) {
          return ManuallyChangePermission(
            forcePermission: false, //TODO... check (we dont force but how do we react)
            onSecondaryOption: (){
              print("secondary option");
            },
          );
        },
      );
    }
    else{
      //covers edge case where the first time we request a permission its status is not at home
      storageFirstTime.value = false;

      //ask for permission
      PermissionStatus status = (await Permission.requestPermissions([PermissionName.Contacts]))[0].permissionStatus;
      if(isAuthorized(status) == false){
        //---top
        checkStoragePermission(
          context,
          onPermissionGiven,
        );
      }
    }
  }
  //ELSE... permission already given
}

//display the WE NEED PERMISSION pop up
class ManuallyChangePermission extends StatefulWidget {
  final bool forcePermission;
  final Function onSecondaryOption;

  ManuallyChangePermission({
    @required this.forcePermission,
    @required this.onSecondaryOption,
  });

  @override
  _ManuallyChangePermissionState createState() => _ManuallyChangePermissionState();
}

class _ManuallyChangePermissionState extends State<ManuallyChangePermission> with WidgetsBindingObserver {
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

    String inOrderTo = "In order to " + "\"Save\"" + " a Contact.";
    String action = "Enable \"Contacts\" in the \"Permissions\" section of \"App Settings\"";
    String options = "Use the Contact without saving it below";
    String altButton = "Use Don't Save";

    //NOTE: required on top of barrier dismissible thing
    return WillPopScope(
      //NOTE: this is also triggered when we press the dismissable barrier
      //when force permission is FALSE
      //AND we are selecting a contact -> we also need to pop back to whatever page brought us up
      //AND we are creating a contact -> we don't need to pop back because from the create contact page we retrigger things
      onWillPop:  () async{
        //TODO... test this
        /*
        if(widget.forcePermission == false && widget.selectingContact){
          Navigator.pop(context);
        }
        */
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