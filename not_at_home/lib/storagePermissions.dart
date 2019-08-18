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
  PermissionStatus startStatus = (await Permission.getPermissionsStatus([PermissionName.Storage]))[0].permissionStatus;
  if(isAuthorized(startStatus) == false){
    //NOTE: if notAgain && not firstTime -> guaranted notAgain
    //else if notAgain && firstTime -> maybe not valid notAgain 
    //  IF valid should show manual ELSE should ASK FOR PERMISSION
    //else we can ASK FOR PERMISSION -> if fail ask again

    if(startStatus == PermissionStatus.notAgain && !storageFirstTime.value){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ManuallyChangePermission(
            onPermissionGiven: onPermissionGiven,
          );
        },
      );
    }
    else{
      //covers edge case where the first time we request a permission its status is not at home
      storageFirstTime.value = false;

      //ask for permission
      PermissionStatus status = (await Permission.requestPermissions([PermissionName.Storage]))[0].permissionStatus;
      if(isAuthorized(status)) onPermissionGiven();
    }
  }
  else onPermissionGiven();
}

//display the WE NEED PERMISSION pop up
class ManuallyChangePermission extends StatefulWidget {
  final Function onPermissionGiven;

  ManuallyChangePermission({
    @required this.onPermissionGiven,
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
    PermissionStatus permissionStatus = (await Permission.getPermissionsStatus([PermissionName.Storage]))[0].permissionStatus;
    if(isAuthorized(permissionStatus)){
      widget.onPermissionGiven();
      Navigator.of(context).pop();
    }
  }

  //build
  @override
  Widget build(BuildContext context) {
    //NOTE: required on top of barrier dismissible thing
    return Theme(
      data: ThemeData.light(),
      child: AlertDialog(
        title: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.folder_open,
                color: Colors.black,
              ),
            ),
            new Text("Grant Us Access"),
          ],
        ),
        content: new Text(
          "In order to \"Select a Photo\" you must" 
          + "\n\n" 
          + "Enable \"Storage\" in the \"Permissions\" section of \"App Settings\"",
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Close"),
            onPressed: () async{
              Navigator.pop(context);
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
    );
  }
}