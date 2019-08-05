import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBarOverlay.dart';
import 'package:not_at_home/selectContact/scrollThumb.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

bool scrollBarColors = false;

class ScrollBar extends StatelessWidget {
  ScrollBar({
    Key key,
    @required this.statusBarHeight,
    @required this.autoScrollController,
    @required this.flexibleHeight,
    @required this.sortedKeys,
    @required this.showThumbTack,
    @required this.positions,
  }) : super(key: key);

  final double statusBarHeight;
  final AutoScrollController autoScrollController;
  final ValueNotifier<double> flexibleHeight;
  final List<int> sortedKeys;
  final ValueNotifier<bool> showThumbTack;
  final List<double> positions;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flexibleHeight,
      builder: (BuildContext context, Widget child) {
        //a couple of manually set vars
        double itemHeight = 16;
        double spacingVertical = 2;
        //NOTE: endsVertical MUST NOT have any spacing since our spacing is MIN spacing
        double endsVertical = itemHeight;
        print("vertical " + endsVertical.toString());
        
        //NOTE: height is singular
        //vertical is double

        //prep vars for below
        double totalHeight = MediaQuery.of(context).size.height;
        //TODO... maybe instead have the largest flexible height
        //portrait mode and landscape mode should have seperate largest flexible heights
        double appBarHeight = flexibleHeight.value; 
        double stickyHeaderVertical = 24.0 + 16;
        double extraPaddingTop = 32;
        double extraPaddingBottom = 16;

        //calculate scroll bar height
        //INCLUDES extra padding to make gesture detector stuff easy
        //SHOULD INCLUDE the area that turns white that has a child of stack
        double scrollBarAreaHeight = totalHeight - appBarHeight; //minus black
        scrollBarAreaHeight -= (stickyHeaderVertical * 2); //minus 2 grey
        scrollBarAreaHeight -= extraPaddingTop;
        scrollBarAreaHeight -= extraPaddingBottom;
        //NOT -> minus 2 white
        //NOT -> minus 2 endsVertical

        //NOTE: the totalHeight we start off with is the actual total height
        //BUT because we are within a widget using safe area
        //we need to remove statusBarHeight
        scrollBarAreaHeight -= statusBarHeight;

        //--------------------------------------------------
        double paddingAll = 16;

        double scrollBarVisualHeight = scrollBarAreaHeight - (paddingAll * 2);

        //based on this scrollBarHeight we can calculate the size of our alpha overlay
        double alphaOverlayHeight = scrollBarAreaHeight - (paddingAll * 2) - (endsVertical * 2);

        //build
        return Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            color: scrollBarColors ? Colors.black : Colors.transparent,
            padding: EdgeInsets.only(
              //avoids flexible app bar height
              top: appBarHeight,
            ),
            child: Container(
              color: scrollBarColors ? Colors.grey : Colors.transparent,
              padding: EdgeInsets.symmetric(
                //avoids sticky header bar
                vertical: stickyHeaderVertical,
              ),
              child: Container(
                color: scrollBarColors ? Colors.black : Colors.transparent,
                padding: EdgeInsets.only(
                  top: extraPaddingTop,
                  bottom: extraPaddingBottom,
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
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              borderRadius: new BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                            ),
                            child: Container(),
                          ),
                        ),
                      ),

                      
                      //-----Thumb tack shower
                      //Required since our mini scroll bar takes you to a section
                      //so it will be very dificult to get the scroll bar to align
                      //with the scroll area that holds the contacts
                      //so to keep things simple...
                      //we simply hide the scroll bar IF we are not dragging it specifically
                      GestureDetector(
                        onPanDown: (tapDownDetails){
                          showThumbTack.value = true;
                        },
                        onPanEnd: (tapUpDetails){
                          showThumbTack.value = false;
                        },
                        onPanCancel: (){
                          showThumbTack.value = false;
                        },
                        child: Container(
                          height: scrollBarAreaHeight,
                          color: scrollBarColors ? Colors.orange.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      //-----thumb tack test
                      /*
                      AnimatedBuilder(
                        animation: showThumbTack,
                        builder: (context, child){
                          return Positioned(
                            left: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: Visibility(
                                visible: showThumbTack.value,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.green.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      */
                      DraggableScrollBar(
                        thumbColor: Theme.of(context).accentColor.withOpacity(0.25),
                        visualScrollBarHeight: scrollBarVisualHeight,
                        //alphaOverlayHeight 
                        //OR scrollBarHeight - (paddingAll * 2) - (endsVertical * 2)
                        //yields the least ammount of vertical slack
                        programaticScrollBarHeight: scrollBarAreaHeight,
                        alphaOverlayHeight: alphaOverlayHeight,
                        scrollThumbHeight: 4 * itemHeight,
                        autoScrollController: autoScrollController,
                        paddingAll: paddingAll,
                        positions: positions,
                        sortedKeys: sortedKeys,
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
                                  items: sortedKeys,
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