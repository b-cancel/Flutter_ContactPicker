import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBarOverlay.dart';
import 'package:not_at_home/selectContact/scrollThumb.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//the scroll has issues with this but 
//1. it looks nice in screen caps
//2. AND it shows off the alpha overlay feature I made
bool useDynamicTopPadding = true;

//only use to debug
bool scrollBarColors = false;

class ScrollBar extends StatelessWidget {
  ScrollBar({
    Key key,
    @required this.statusBarHeight,
    @required this.autoScrollController,
    @required this.bannerHeight,
    @required this.expandedBannerHeight,
    @required this.sortedLetterCodes,
    @required this.showThumbTack,
    @required this.letterToListItems,
  }) : super(key: key);

  final double statusBarHeight;
  final AutoScrollController autoScrollController;
  final ValueNotifier<double> bannerHeight;
  final double expandedBannerHeight;
  final List<int> sortedLetterCodes;
  final ValueNotifier<bool> showThumbTack;
  final Map<int, List<Widget>> letterToListItems;

  @override
  Widget build(BuildContext context) {
    print("NEW SCROLL BAR");

    return AnimatedBuilder(
      animation: bannerHeight,
      builder: (BuildContext context, Widget child) {
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
        double appBarHeight = (useDynamicTopPadding) ? bannerHeight.value : expandedBannerHeight;  
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
        scrollBarAreaHeight -= statusBarHeight;
        scrollBarAreaHeight = noNegative(scrollBarAreaHeight);

        //--------------------------------------------------
        double paddingAll = 16;

        double scrollBarVisualHeight = scrollBarAreaHeight - (paddingAll * 2);
        scrollBarVisualHeight = noNegative(scrollBarVisualHeight);

        //based on this scrollBarHeight we can calculate the size of our alpha overlay
        double alphaOverlayHeight = scrollBarAreaHeight - (paddingAll * 2) - (endsVertical * 2);
        alphaOverlayHeight = noNegative(alphaOverlayHeight);

        //other vars for position
        double maxScroll = autoScrollController.position.maxScrollExtent;
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
        for(int i = 0; i < sortedLetterCodes.length; i++){
          double thisItemsOffset = calculateOffset(
            bannerHeight.value, //820.5714285714286, 
            //for header in index 3... there are 3 headers above.. [0,1,2]
            //then also include yourself
            i + 1, //closedHeaders
            itemCountSoFar - 1, //items above
            spacerCountSoFar - 1, //spacers above
          );

          //make sure we haven't passed the limit (otherwise weird bounce)
          //print('max scroll ' + maxScroll.toString() + " VS " + thisItemsOffset.toString());
          //thisItemsOffset = (thisItemsOffset > maxScroll) ? maxScroll : thisItemsOffset;

          //TODO... testing (for last 3 itmes)
          if(i >= (sortedLetterCodes.length - 3)){
            //thisItemsOffset = maxsc
          }
          
          //add the offset
          offsets.add(thisItemsOffset);

          //add ourselves
          int ourItemCount = letterToListItems[sortedLetterCodes[i]].length;
          itemCountSoFar += ourItemCount;
          spacerCountSoFar += (ourItemCount - 1);
        }

        //build
        return Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            height: totalHeight,
            color: scrollBarColors ? Colors.red : Colors.transparent,
            padding: EdgeInsets.only(
              //avoids flexible app bar height
              top: appBarHeight,
            ),
            child: Container(
              color: scrollBarColors ? Colors.grey : Colors.transparent,
              padding: EdgeInsets.only(
                top: extraPaddingTop,
                bottom: extraPaddingBottom,
              ),
              child: Container(
                color: scrollBarColors ? Colors.black : Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: paddingVertical,
                ),
                child: Container(
                  color: scrollBarColors ? Colors.white : Colors.transparent,
                  height: scrollBarAreaHeight,
                  width: 24 + (paddingAll * 2),
                  //-------------------------CUSTOM START-------------------------
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
                        autoScrollController: autoScrollController,
                        paddingAll: paddingAll,
                        positions: offsets,
                        sortedKeys: sortedLetterCodes,
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
                                  items: sortedLetterCodes,
                                ),
                              ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //-------------------------CUSTOM END-------------------------
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

double noNegative(double number){
  return (number < 0) ? 0 : number;
}

double calculateOffset(
  double expandedHeight, 
  int headerCount, 
  int itemsAbove, 
  int spacersAbove,
){
  //assume that each header after overflow on top
  //grow to their max size of 80
  double headers = 80.0 * headerCount;
  double items = 70.0 * itemsAbove;
  double spacers = 2.0 * spacersAbove;
  return expandedHeight + headers + items + spacers;
}