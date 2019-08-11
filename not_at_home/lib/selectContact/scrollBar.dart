import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBarOverlay.dart';
import 'package:not_at_home/selectContact/scrollThumb.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//only use to debug
bool scrollBarColors = false;

//scroll bar widgets
class ScrollBar extends StatefulWidget {
  ScrollBar({
    @required this.autoScrollController,
    //contacts
    @required this.retreivingContacts,
    @required this.contacts,
    //heights
    @required this.statusBarHeight,
    @required this.expandedBannerHeight,
    //show widgets
    @required this.sortedLetterCodes,
    @required this.letterToListItems,
    //show/hide thumb tack
    @required this.showThumbTack,
  });

  final AutoScrollController autoScrollController;
  //contacts
  final ValueNotifier<bool> retreivingContacts;
  final ValueNotifier<List<Contact>> contacts;
  //heights
  final double statusBarHeight;
  final double expandedBannerHeight;
  //show widget
  final ValueNotifier<List<int>> sortedLetterCodes;
  final ValueNotifier<Map<int, List<Widget>>> letterToListItems;
  //show/hide thumb tack
  final ValueNotifier<bool> showThumbTack;

  @override
  _ScrollBarState createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> {
  ValueNotifier<bool> showContacts = new ValueNotifier(false);

  @override
  void initState() {
    //update whether or not the contacts should be visible
    widget.retreivingContacts.addListener((){
      updateContactsVisible();
    });

    widget.contacts.addListener((){
      updateContactsVisible();
    });

    widget.sortedLetterCodes.addListener((){
      updateContactsVisible();
    });

    widget.letterToListItems.addListener((){
      updateContactsVisible();
    });

    //if either var above changes this might change 
    //which should trigger a set state
    showContacts.addListener((){
      rebuild();
    });

    //init the super
    super.initState();
  }

  //set state with mounted check first
  rebuild(){
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((_){
        setState(() {
        
        });
      });
    }
  }

  //this MIGHT trigger a rebuild
  updateContactsVisible(){
    if(
      widget.retreivingContacts.value 
      || widget.contacts.value.length == 0 
      || widget.letterToListItems.value.length == 0
      || widget.sortedLetterCodes.value.length == 0){
      showContacts.value = false;
    }
    else showContacts.value = true;
  }

  //build
  @override
  Widget build(BuildContext context) {
    if(showContacts.value == false) return Container();
    else{
      //a couple of manually set vars
      double itemHeight = 16;
      double spacingVertical = 2;
      //NOTE: endsVertical MUST NOT have any spacing since our spacing is MIN spacing
      double endsVertical = itemHeight;
      
      //NOTE: height is singular
      //vertical is double

      //prep vars for below
      double totalHeight = MediaQuery.of(context).size.height;
      //TODO... maybe instead have the largest flexible height
      //portrait mode and landscape mode should have seperate largest flexible heights
      double appBarHeight = widget.expandedBannerHeight;  
      double paddingVertical = 16;
      //size of toolbar AND NOT sticky header
      double extraPaddingTop = 40; 
      double extraPaddingBottom = 0; 

      //calculate scroll bar height
      //INCLUDES extra padding to make gesture detector stuff easy
      //SHOULD INCLUDE the area that turns white that has a child of stack
      double scrollBarAreaHeight = totalHeight - appBarHeight; //minus black
      scrollBarAreaHeight -= (paddingVertical * 2); //minus 2 grey
      scrollBarAreaHeight -= extraPaddingTop;
      scrollBarAreaHeight -= extraPaddingBottom;
      //NOT -> minus 2 white
      //NOT -> minus 2 endsVertical

      //NOTE: the totalHeight we start off with is the actual total height
      //BUT because we are within a widget using safe area
      //we need to remove statusBarHeight
      scrollBarAreaHeight -= widget.statusBarHeight;
      scrollBarAreaHeight = noNegative(scrollBarAreaHeight);

      //--------------------------------------------------
      double paddingAll = 16;

      double scrollBarVisualHeight = scrollBarAreaHeight - (paddingAll * 2);
      scrollBarVisualHeight = noNegative(scrollBarVisualHeight);

      //based on this scrollBarHeight we can calculate the size of our alpha overlay
      double alphaOverlayHeight = scrollBarAreaHeight - (paddingAll * 2) - (endsVertical * 2);
      alphaOverlayHeight = noNegative(alphaOverlayHeight);
      
      //calc padding
      EdgeInsets scrollBarPadding = EdgeInsets.only(
        top: appBarHeight + paddingVertical + extraPaddingTop,
        bottom: paddingVertical + extraPaddingBottom,
      );

      //build
      return Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child:  Padding(
          padding: scrollBarPadding,
          child: Container(
            height: scrollBarAreaHeight,
            width: 24 + (paddingAll * 2),
            child: Stack(
              children: <Widget>[
                //-----Scroll Bar Base
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingAll),
                    child: Container(
                      height: scrollBarVisualHeight,
                      decoration: new BoxDecoration(
                        color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                        borderRadius: new BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                      ),
                      child: Container(),
                    ),
                  ),
                ),
                //-----Scroll Bar Function
                DraggableScrollBar(
                  autoScrollController: widget.autoScrollController,
                  //set once and done
                  visualScrollBarHeight: scrollBarVisualHeight,
                  programaticScrollBarHeight: scrollBarAreaHeight,
                  alphaOverlayHeight: alphaOverlayHeight,
                  scrollThumbHeight: 4 * itemHeight,
                  paddingAll: paddingAll,
                  thumbColor: Theme.of(context).accentColor.withOpacity(0.25),
                  expandedBannerHeight: widget.expandedBannerHeight,
                  //value notifiers, don't need to notify since we KNOW when we pass these they will already not be empty
                  sortedLetterCodes: widget.sortedLetterCodes.value,
                  letterToListItems: widget.letterToListItems.value,
                ),
                //-----Letters Overlay
                IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: paddingAll),
                      child: Container(
                          height: alphaOverlayHeight,
                          color: scrollBarColors ? Colors.red.withOpacity(0.25) : Colors.transparent,
                          child: AlphaScrollBarOverlay(
                            scrollBarHeight: alphaOverlayHeight,
                            itemHeight: itemHeight,
                            spacingVertical: spacingVertical,
                            letterCodes: widget.sortedLetterCodes.value,
                          ),
                        ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  double noNegative(double number){
    return (number < 0) ? 0 : number;
  }
}