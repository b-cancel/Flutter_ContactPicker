import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBarOverlay.dart';
import 'package:not_at_home/selectContact/scrollThumb.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//the scroll has issues with this but 
//1. it looks nice in screen captures
//2. AND it shows off the alpha overlay feature I made
bool useDynamicTopPadding = false;

//only use to debug
bool scrollBarColors = false;

class ScrollBar extends StatefulWidget {
  ScrollBar({
    @required this.autoScrollController,
    //contacts
    @required this.retreivingContacts,
    @required this.contacts,
    //heights
    @required this.statusBarHeight,
    @required this.bannerHeight,
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
  final ValueNotifier<double> bannerHeight;
  final double expandedBannerHeight;
  //show widget
  final List<int> sortedLetterCodes;
  final Map<int, List<Widget>> letterToListItems;
  //show/hide thumb tack
  final ValueNotifier<bool> showThumbTack;

  @override
  _ScrollBarState createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> {
  ValueNotifier<bool> showContacts = new ValueNotifier(false);

  @override
  void initState() {
    //when the banner changes we update the scroll bar
    if(useDynamicTopPadding){
      widget.bannerHeight.addListener((){
        rebuild();
      });
    }

    //update whether or not the contacts should be visible
    widget.retreivingContacts.addListener((){
      updateContactsVisible();
    });

    widget.contacts.addListener((){
      updateContactsVisible();
    });

    //if either var above changes this might change 
    //which should trigger a set state
    showContacts.addListener((){
      setState(() {
        
      });
    });

    //init the super
    super.initState();
  }

  rebuild(){
    if(mounted){
      setState(() {
        
      });
    }
  }

  updateContactsVisible(){
    if(widget.retreivingContacts.value || widget.contacts.value.length == 0){
      showContacts.value = false;
    }
    else showContacts.value = true;
  }

  @override
  Widget build(BuildContext context) {
    if(showContacts.value) return Container();
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
      double appBarHeight = (useDynamicTopPadding) ? widget.bannerHeight.value : widget.expandedBannerHeight;  
      double paddingVertical = 16;
      double extraPaddingTop = 40 * 2.0; //TODO... size of toolbar AND sticky header
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

      //other vars for position
      double maxScroll = widget.autoScrollController.position.maxScrollExtent;
      maxScroll -= MediaQuery.of(context).size.height;

      //generate the positions
      int itemCountSoFar = 0;
      int spacerCountSoFar = 0;
      List<double> offsets = new List<double>();
      //NOTE: SADLY because of how strange slivers can be sometimes
      //the offset of 0 does not always open up the sliver all the way
      //this means its dangerous to assume that it is ALWAYS closing it
      //if we do this we might shift lower than we have to
      //the label will show that we are in the correct section
      //but above the label there might be some of the desired items
      //and that isn't going to bode well for the user experience
      //JUST KIDDING if we snap the sliver into place we CAN GUARANTEE this
      for(int i = 0; i < widget.sortedLetterCodes.length; i++){
        double thisItemsOffset = 0;
        double bannerAndToolbar = widget.expandedBannerHeight + 40;
        int headersBefore = i - 1;

        if(i != 0){
          thisItemsOffset = bannerAndToolbar 
          + (itemCountSoFar * 70) 
          + (spacerCountSoFar * 2)
          + (headersBefore * 40);
        }
        
        //add the offset
        offsets.add(thisItemsOffset);

        //add ourselves
        int ourItemCount = widget.letterToListItems[widget.sortedLetterCodes[i]].length;
        itemCountSoFar += ourItemCount;
        spacerCountSoFar += (ourItemCount - 1);
      }
      
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
                  thumbColor: Theme.of(context).accentColor.withOpacity(0.25),
                  visualScrollBarHeight: scrollBarVisualHeight,
                  programaticScrollBarHeight: scrollBarAreaHeight,
                  alphaOverlayHeight: alphaOverlayHeight,
                  scrollThumbHeight: 4 * itemHeight,
                  autoScrollController: widget.autoScrollController,
                  paddingAll: paddingAll,
                  positions: offsets,
                  sortedKeys: widget.sortedLetterCodes,
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
                            items: widget.sortedLetterCodes,
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