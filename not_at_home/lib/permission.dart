import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      print("*************************PERMISSION RESUME");
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
                if(isSelecting){
                  showDialog(
                    context: context,
                    //NOTE: the barrier should be dismissible
                    builder: (BuildContext context) {
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
                                TextFormField(
                                  autofocus: true,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: "Name",
                                  ),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: "Phone",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Grant Permission"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            new RaisedButton(
                              textColor: Colors.white,
                              child: new Text(
                                "Add Contact",
                              ),
                              //TODO... make this null until we can confirm
                              //1. we have some form of name
                              //2. we have atleast 7 numbers in the field (any more might be country codes)
                              onPressed: null, /*() {
                                
                              },*/
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                else{
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