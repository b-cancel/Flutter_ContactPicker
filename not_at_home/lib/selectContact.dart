import 'package:flutter/material.dart';
import 'package:not_at_home/permission.dart';
import 'package:not_at_home/selectContactUX.dart';

/*
  NOTE: this app is designed specifically for 2 cases
  case 1: select a contact on start up, once its selected we cant access the contact selection items
  case 2: select a contact from a page, and go back to that page (by poping)

  So case 3 below is NOT covered
  case 3: select a contact from a page, and go to another page 

  So...
  Case 1 is identified when we are not passed a name or a number
  Case 2 is the inverse
*/

/*
IF we are passed a name and number -> we update those
ELSE we create them -> then we update those

IF: lets us select a contact in most cases (which is probably what everyone else will need for their app)
ELSE: lets us select a contact on start up (which is what I need for my app)
*/

/*
IF we force selection
  IF -> select contact came up on start up -> we dont want to stop the user from closing the app
  ELSE -> we dont want to allow the user to back up
-----CHECK BELOW (once we implement on start up)
ELSE -> the user should be able to back away from the selection process at any stage
  IF we already have permission -> they should be able to easily back away from the page
  ELSE -> they should be able to easily back away from the
    1. page with the permissions pop up
    2. and the page that comes up IF you block the pop up
-----CHECK ABOVE
*/

class SelectContact extends StatefulWidget {
  SelectContact({
    this.forceSelection,
    this.name,
    this.number,
  });

  final bool forceSelection;
  final ValueNotifier<String> name;
  final ValueNotifier<String> number;

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> with WidgetsBindingObserver {
  //keeps track of whether or not select contact came up on start up
  bool firstPage;

  //init
  @override
  void initState() { 
    super.initState();

    //set first page
    if(widget.name != null && widget.number != null){
      firstPage = false;
    }
    else firstPage = true;

    //make sure we have permission to access contacts
    permissionRequired(context, widget.forceSelection);

    //setup
    WidgetsBinding.instance.addObserver(this);
  }

  //dispose
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      print("-------------------RESUMED");
      //TODO... handle all cases below
      //IF -> we came back from the permissions page
      //  IF we now have permission -> refill the contacts list with our contacts
      //  ELSE -> EITHER manual input OR (back because not forced)
      //    IF back because not forced -> we cant be here without the permissions so go back again to the previous page
      //    ELSE manual input
      //      IF first page -> go to the next page and bring up the manual input pop up (which should be in any page that is requesting a contact)
      //      ELSE -> go to the previous page and bring pu the manual input pop up (which should be in any page that is requesting a contact)
      //ELSE -> we came back from the create contact page
      //  nothing should really happen here
    }
  }

  //build
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //IF first page I should be able to close the app
      //ELSE -> I block the user from going back IF forceSelection is enabled
      onWillPop: () async => !(widget.forceSelection && !firstPage),
      child: SelectContactUX(),
    );
  }
}