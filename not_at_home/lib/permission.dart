import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

permissionRequired(BuildContext context, bool force) async{
  PermissionStatus startStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
  if(startStatus != PermissionStatus.granted){
    bool popUpNotBlocked = await PermissionHandler().shouldShowRequestPermissionRationale(PermissionGroup.contacts);
    if(popUpNotBlocked){
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
      PermissionStatus status = permissions[PermissionGroup.contacts];
      if(status != PermissionStatus.granted){
        permissionRequired(context, force);
      }
    }
    else{
      Navigator.push(
        context, PageTransition(
          type: PageTransitionType.leftToRight,
          child: Manual(
            forcePermission: force,
          ),
        ),
      );
    }
  }
}

class Manual extends StatefulWidget {
  final bool forcePermission;

  Manual({
    this.forcePermission,
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

  //---the user did what we wanted
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      checkIfCanPop();
    }
  }

  void checkIfCanPop() async{
    PermissionStatus status = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    if(status == PermissionStatus.granted){
      Navigator.of(context).pop();
    }
    //ELSE... wait for user to open up app settings and do what we expect
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:  () async => !widget.forcePermission,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(32),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              "Grant Us Access",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              "In order to select a contact",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Enable \"Contacts\" in the \"Permissions\" Section of \"App Settings\" Below",
                                ),
                              ],
                            ),
                          ),
                          /*
                          Container(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Or \"Manually Input\" the Contact below",
                                ),
                              ],
                            ),
                          ),
                          */
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(32),
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Icon(
                                Icons.contacts,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).accentColor,
                  )
                )
              ),
              child: Row(
                children: <Widget>[
                  BottomButton(
                    label: "", //Manual Input",
                  ),
                  BottomButton(
                    label: "App Settings",
                    func: (){
                      PermissionHandler().openAppSettings();
                    },
                    icon: Icons.keyboard_arrow_right,
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  const BottomButton({
    this.label,
    this.func,
    this.icon,
    Key key,
  }) : super(key: key);

  final String label;
  final Function func;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      color: Theme.of(context).primaryColorLight,
      fontSize: 18,
    );

    return Expanded(
      child: FlatButton(
        onPressed: func ?? null,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: (icon == null)
          ? Container(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: style,
              textAlign: TextAlign.left,
            ),
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                label,
                style: style,
              ),
              Icon(
                icon,
                color: Theme.of(context).primaryColorLight,
              ),
            ],
          ),
        )
      ),
    );
  }
}