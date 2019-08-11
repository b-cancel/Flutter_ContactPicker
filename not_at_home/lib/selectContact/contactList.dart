import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:not_at_home/helper.dart';
import 'package:not_at_home/selectContact/contactTile.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//contact deletion is NOT functional
//as in... DOES NOT delete the contact...
//but still work on the UI side
//TODO... make this functional
bool contactDeletionUI = false;

class ContactList extends StatefulWidget {
  ContactList({
    //set once and doen
    @required this.autoScrollController,
    @required this.onSelect,
    @required this.headerSlivers,
    //value notifiers (used to update ourselves)
    @required this.retreivingContacts,
    @required this.contacts,
    //value notifiers (used by other to update themeselves)
    @required this.sortedLetterCodes,
    @required this.letterToListItems,
  });

  //set once and doen
  final AutoScrollController autoScrollController;
  final Function onSelect;
  final List<Widget> headerSlivers;
  //value notifiers
  final ValueNotifier<bool> retreivingContacts;
  final ValueNotifier<List<Contact>> contacts;
  final ValueNotifier<List<int>> sortedLetterCodes; 
  final ValueNotifier<Map<int, List<Widget>>> letterToListItems;

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  Map<int, List<Widget>> createLetterToWidgetListMap(){
    Map<int, List<Widget>> letterToListItemsNEW = new Map<int,List<Widget>>();
    for(int i = 0; i < widget.contacts.value.length; i++){
      //create the new list if we have to
      int letterCode = widget.contacts.value[i].givenName?.toUpperCase()?.codeUnitAt(0) ?? 63; //63 = ?
      if(letterToListItemsNEW.containsKey(letterCode) == false){
        letterToListItemsNEW[letterCode] = new List<Widget>();
      }

      //make contact list tile
      Widget tile = ContactListTile(
        thisContact: widget.contacts.value[i],
        thisColor: colorsForContacts[i],
        onSelect: widget.onSelect,
      );

      //add contact delete UI if desired
      //current not functional
      
      if(contactDeletionUI){ //TODO... parametrize this
        tile = Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) async{
            //remove it from the all the lists (contacts, colors, keys)
            widget.contacts.value.removeAt(i);
            colorsForContacts.removeAt(i);

            //have those changes reflected on rebuild
            //NOTE: you may be tempted to just merge the contact with its spacer
            //and then let the automatic deletion occur... BUT
            //take this scenario
            //item 1 | [spacer | item 2] | [spacer | item 3]
            //delete item 1
            //[spacer | item 2] | [spacer | item 3]
            //NOTE: how the spacer is not deleted
            //TODO... in all edge cases where we don't have to rebuild manually... DONT
            setState(() {
              
            });

            //delete the contact
            //await ContactsService.deleteContact(contacts.value[i]); 
          },
          child: tile,
          background: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.red,
            alignment: Alignment.centerLeft,
            child: Icon(
              FontAwesomeIcons.trash,
              color: Colors.black,
            ),
          ),
        );
      }

      //add to the list
      letterToListItemsNEW[letterCode].add(tile);
    }
    return letterToListItemsNEW;
  }

  List<Widget> createSliverSectionsList(
    List<int> sortedLetterCodes,
    Map<int, List<Widget>> letterToListItems,
  ){
    List<Widget> sliverSectionsNEW = new List<Widget>();
    for(int i = 0; i < sortedLetterCodes.length; i++){
      List<Widget> widgetsWithDividers = new List<Widget>();
      int key = sortedLetterCodes[i];

      //go through keys, grab widgets, and place dividers between
      List<Widget> widgetsForSection = letterToListItems[key];
      for(int item = 0; item < widgetsForSection.length; item++){
        //add divider above all items except first
        if(item > 0){
          widgetsWithDividers.add(
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 80, right: 24), 
              child: Container(
                color: Theme.of(context).dividerColor,
                height: 2,
              ),
            ),
          );
        }

        //add widget
        widgetsWithDividers.add(widgetsForSection[item]);
      }

      //add all these items into the section
      sliverSectionsNEW.add(
        SliverStickyHeader(
          header: Container(
            color: Theme.of(context).primaryColor,
            padding: new EdgeInsets.only(
              left: 32,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 16,
              alignment: Alignment.centerLeft,
              child: new Text(
                String.fromCharCode(key),
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
          sliver: new SliverList(
            delegate: new SliverChildListDelegate([
              Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: widgetsWithDividers,
                ),
              ),
            ]),
          ),
        ),
      );
    }
    return sliverSectionsNEW;
  }

  List<Color> colorsForContacts = new List<Color>();

  @override
  void initState() {
    //listen to retreiving contact changes
    widget.retreivingContacts.addListener((){
      print("retreiving contacts changed");

      setState(() {
        
      });
    });

    //listen to contact changes
    widget.contacts.addListener((){
      print("contacts changed");

      //NOTE: that this should ONLY happen once
      if(widget.contacts.value.length > 0 && colorsForContacts.isEmpty){
        //assign a color to each contact
        for(int i = 0; i < widget.contacts.value.length; i++){
          colorsForContacts.add(theColors[rnd.nextInt(theColors.length)]);
        }
      }

      //you set state when contacts get updated in any way
      setState(() {
        
      });
    });

    //super init
    super.initState();
  }

  //TODO... it seems to be possible to make some changes here
  @override
  Widget build(BuildContext context) {
    print("-------------------------Building Contact List");

    //for each letter assemble a list of widget
    Map<int, List<Widget>> letterToListItems = createLetterToWidgetListMap();
    //update notifier so scroll bar can adjust
    widget.letterToListItems.value = letterToListItems;

    //sort keys
    List<int> sortedLetterCodes = letterToListItems.keys.toList();
    sortedLetterCodes.sort();
    //update notifier so scroll bar can adjust
    widget.sortedLetterCodes.value = sortedLetterCodes;

    //iterate through all letters
    //and compile the sections with their headers
    List<Widget> sliverSections = createSliverSectionsList(
      sortedLetterCodes,
      letterToListItems,
    );

    //the body slivers
    List<Widget> bodySlivers = new List<Widget>();

    //Generate the Widget shown in the contacts scroll area
    //Depending on whether or not there are contacts or they are being retreived
    if(widget.retreivingContacts.value || widget.contacts.value.length == 0){
      //add sliver to fill screen
      bodySlivers.add(
        SliverFillRemaining(
          hasScrollBody: false, //makes it the proper size
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            child: Text(
              (widget.retreivingContacts.value) ? "Retreiving Contacts" : "No Contacts Found",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }
    else{
      //add all sections to body
      bodySlivers = sliverSections;

      //add the bottom sliver that gives you section information
      bodySlivers.add(
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(widget.contacts.value.length.toString() + " Contacts"),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                //make sure to top button isnt covered
                //16 is padding
                //48 is the size of the button
                height: 16.0 + 48 + 16,
              ),
            ],
          ),
        ),
      );
    }

    //all slivers
    List<Widget> allSlivers = new List.from(widget.headerSlivers)..addAll(bodySlivers);

    //build
    return CustomScrollView(
      controller: widget.autoScrollController,
      //HEADER
      //-banner
      //-toolbar

      //BODY
      //-IF no contacts OR retreiving contacts -> fill remaining
      //-ELSE -> list of widgets
      slivers: allSlivers,
    );
  }
}