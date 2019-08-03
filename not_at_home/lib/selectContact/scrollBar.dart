import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBarOverlay.dart';
import 'package:not_at_home/selectContact/scrollThumb.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ScrollBar extends StatelessWidget {
  ScrollBar({
    Key key,
    @required this.autoScrollController,
    @required this.flexibleHeight,
    @required this.sortedKeys,
    @required this.showThumbTack,
  }) : super(key: key);

  final AutoScrollController autoScrollController;
  final ValueNotifier<double> flexibleHeight;
  final List<int> sortedKeys;
  final ValueNotifier<bool> showThumbTack;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flexibleHeight,
      builder: (BuildContext context, Widget child) {
        //prep vars for below
        double totalHeight = MediaQuery.of(context).size.height;
        double appBarHeight = flexibleHeight.value;
        double stickyHeaderHeight = 24.0 + 16;
        double paddingAll = 16;
        double paddingVertical = 12;

        //calculate scroll overlay height
        double scrollOverlayHeight = totalHeight - appBarHeight;
        scrollOverlayHeight -= (stickyHeaderHeight * 2);
        scrollOverlayHeight -= (paddingAll * 2);

        //a couple of manually set vars
        double itemHeight = 18;
        double minSpacing = 2;

        //build
        return Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
              //avoids flexible app bar height
              top: appBarHeight,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                //avoids sticky header bar
                vertical: stickyHeaderHeight,
              ),
              child: Container(
                child: Stack(
                  children: <Widget>[
                    //-----Scroll Bar Base
                    new ScrollBarWrapper(
                      paddingAll: paddingAll, 
                      paddingVertical: paddingVertical, 
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      widget: Container(),
                    ),
                    //-----Thumb tack shower
                    //Required since our mini scroll bar takes you to a section
                    //so it will be very dificult to get the scroll bar to align
                    //with the scroll area that holds the contacts
                    //so to keep things simple...
                    //we simply hide the scroll bar IF we are not dragging it specifically
                    Positioned.fill(
                      child: Container(
                          padding: EdgeInsets.all(0),
                          child: GestureDetector(
                            onPanDown: (tapDownDetails){
                              showThumbTack.value = true;
                            },
                            onPanEnd: (tapUpDetails){
                              showThumbTack.value = false;
                            },
                            onPanCancel: (){
                              showThumbTack.value = false;
                            },
                            child: Container(),
                          ),
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
                      paddingAll: paddingAll,
                      paddingVertical: paddingVertical,
                      autoScrollController: autoScrollController,
                      scrollThumbHeight: 4 * itemHeight,
                    ),
                    //-----Letters Overlay
                    IgnorePointer(
                      child: new ScrollBarWrapper(
                        paddingAll: paddingAll, 
                        paddingVertical: paddingVertical, 
                        color: Colors.transparent,
                        widget: AlphaScrollBarOverlay(
                          scrollBarHeight: scrollOverlayHeight,
                          itemHeight: itemHeight,
                          minimumSpacing: minSpacing,
                          items: sortedKeys,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScrollBarWrapper extends StatelessWidget {
  const ScrollBarWrapper({
    Key key,
    @required this.paddingAll,
    @required this.paddingVertical,
    @required this.widget,
    @required this.color,
  }) : super(key: key);

  final double paddingAll;
  final double paddingVertical;
  final Widget widget;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(paddingAll),
      child: Container(
        width: 24,
        padding: EdgeInsets.symmetric(
          vertical: paddingVertical,
        ),
        decoration: new BoxDecoration(
          color: color,
          borderRadius: new BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        child: widget,
      ),
    );
  }
}