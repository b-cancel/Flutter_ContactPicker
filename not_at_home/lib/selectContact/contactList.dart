import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:not_at_home/selectContact/contactTile.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/*
//contact deletion is NOT functional
//as in... DOES NOT delete the contact...
//but still work on the UI side
//TODO... make this functional
bool contactDeletionUI = false;

class ContactList extends StatelessWidget {
  ContactList({
    @required this.autoScrollController,
    @required this.headerSlivers,

    @required this.retreivingContacts,
    @required this.contacts,
    @required this.colorsForContacts,
  });

  final AutoScrollController autoScrollController;
  final List<Widget> headerSlivers;

  final ValueNotifier<bool> retreivingContacts;
  final ValueNotifier<List<Contact>> contacts;
  final List<Color> colorsForContacts;
  

  Map<int, List<Widget>> createLetterToWidgetListMap(){
    Map<int, List<Widget>> letterToListItems = new Map<int,List<Widget>>();
    for(int i = 0; i < contacts.value.length; i++){
      //create the new list if we have to
      int letterCode = contacts.value[i].givenName?.toUpperCase()?.codeUnitAt(0) ?? 63; //63 = ?
      if(letterToListItems.containsKey(letterCode) == false){
        letterToListItems[letterCode] = new List<Widget>();
      }

      //make contact list tile
      Widget tile = ContactListTile(
        thisContact: contacts.value[i],
        thisColor: colorsForContacts[i],
        onSelect: onSelect,
      );

      //add contact delete UI if desired
      //current not functional
      
      if(contactDeletionUI){ //TODO... parametrize this
        tile = Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) async{
            //remove it from the all the lists (contacts, colors, keys)
            contacts.value.removeAt(i);
            colorsForContacts.removeAt(i);
            keys.removeAt(i);

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
      letterToListItems[letterCode].add(tile);
    }
    return letterToListItems;
  }

  List<Widget> createSliverSectionsList(
    List<int> sortedLetterCodes,
    Map<int, List<Widget>> letterToListItems,
  ){
    List<Widget> sliverSections = new List<Widget>();
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
      sliverSections.add(
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
    return sliverSections;
  }

  @override
  Widget build(BuildContext context) {
    //for each letter assemble a list of widget
    Map<int, List<Widget>> letterToListItems = createLetterToWidgetListMap();

    //sort keys
    List<int> sortedLetterCodes = letterToListItems.keys.toList();
    sortedLetterCodes.sort();

    //iterate through all letters
    //and compile the sections with their headers
    List<Widget> sliverSections = createSliverSectionsList(
      sortedLetterCodes,
      letterToListItems,
    );

    //--------------------------------------------------------

    //the body slivers
    List<Widget> bodySlivers = new List<Widget>();

    //Generate the Widget shown in the contacts scroll area
    //Depending on whether or not there are contacts or they are being retreived
    bool contactsVisible = true;
    if(widget.retreivingContacts || widget.sliverSections.length == 0){
      contactsVisible = false;

      //add sliver to fill screen
      bodySlivers.add(
        SliverFillRemaining(
          hasScrollBody: false, //makes it the proper size
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            child: Text(
              (widget.retreivingContacts) ? "Retreiving Contacts" : "No Contacts Found",
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
      bodySlivers = widget.sliverSections;

      //add the bottom sliver that gives you section information
      bodySlivers.add(
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(widget.contactCount.toString() + " Contacts"),
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
    List<Widget> allSlivers = new List.from(headerSlivers)..addAll(bodySlivers);

    //--------------------------------------------------------

    //build
    return CustomScrollView(
      controller: autoScrollController,
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
*/