import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/scrollBar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'dart:math' as math;

//Mostly taken from this article
//https://medium.com/flutter-community/creating-draggable-scrollbar-in-flutter-a0ae8cf3143b
//Left off here
//Search "As we see on screen capture when list is scrolled scrollthumb is not moving"

class DraggableScrollBar extends StatefulWidget {
  DraggableScrollBar({
    @required this.visualScrollBarHeight,
    @required this.programaticScrollBarHeight,
    @required this.alphaOverlayHeight,
    @required this.scrollThumbHeight,
    @required this.autoScrollController,
    @required this.paddingAll,
    @required this.thumbColor,
    @required this.positions,
  });

  final double visualScrollBarHeight;
  final double programaticScrollBarHeight;
  final double alphaOverlayHeight;
  final double scrollThumbHeight;
  final AutoScrollController autoScrollController;
  final double paddingAll;
  final Color thumbColor;
  final List<double> positions;

  @override
  _DraggableScrollBarState createState() => new _DraggableScrollBarState();
}

class _DraggableScrollBarState extends State<DraggableScrollBar> {
  double barOffsetPercent;

  //handle thumb
  double thumbScrollBarHeight;
  double thumbMultiplier;

  //offsets
  double barOffset;
  double thumbOffset;

  //the index we will be scroll onto
  int index;
  int lastIndex;

  //keeps track of the calculated offsets
  //between start and end we might select difference indexes
  //before start only FIRST
  //after end only LAST
  double space;
  double offsetAtSart;
  double offsetAtEnd;

  //init
  @override
  void initState() {
    //super init
    super.initState();
    //we start on top so this is set as such
    index = 0;
    barOffsetPercent = 0.0;
    //do initial math
    doMath();
  }

  //---------------
  /*
  //if list takes 300.0 pixels of height on screen and scrollthumb height is 40.0
  //then max bar offset is 260.0
  double get barMaxScrollExtent => context.size.height - widget.scrollThumbHeight;
  double get barMinScrollExtent => 0.0;

  //this is usually lenght (in pixels) of list
  //if list has 1000 items of 100.0 pixels each, maxScrollExtent is 100,000.0 pixels
  double get viewMaxScrollExtent => widget.autoScrollController.position.maxScrollExtent;
  //this is usually 0.0
  double get viewMinScrollExtent => widget.autoScrollController.position.minScrollExtent;
  */
  //---------------

  void doMath(){
    //calculate the offset
    space = (widget.programaticScrollBarHeight - widget.alphaOverlayHeight) / 2;
    offsetAtSart = space;
    offsetAtEnd = widget.programaticScrollBarHeight - space;

    //regular bar offset
    barOffset = widget.programaticScrollBarHeight * barOffsetPercent;

    //the thumbScrollHeight
    thumbScrollBarHeight = widget.visualScrollBarHeight - widget.scrollThumbHeight;

    //determine thumb offset
    if(barOffset <= offsetAtSart) thumbOffset = 0;
    else if(offsetAtEnd <= barOffset) thumbOffset = thumbScrollBarHeight;
    else{
      //adjusted offset: 0 -> (programatic - space)
      //thumb offset: 0 -> thumbScrollBarHeight
      double adjustedHeight = widget.programaticScrollBarHeight - (space * 2);
      thumbMultiplier = thumbScrollBarHeight / adjustedHeight;
      double adjustedOffset = barOffset - space;
      thumbOffset = adjustedOffset * thumbMultiplier;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    //travel to our fingers position
    double barOffset = details.localPosition.dy;
    //clamp the values
    barOffset = barOffset.clamp(0, widget.programaticScrollBarHeight).toDouble();
    //shift the offset to a percent of travel
    barOffsetPercent = barOffset / widget.programaticScrollBarHeight;

    //do math based on the barOffSet percent
    doMath();

    /*
    //idk why i need to do this here instead of in init
    lastIndex = widget.positions.length - 1;

    //determine what index to go to
    int newIndex = 0;
    /*
    if(barOffset <= offsetAtSart) newIndex = 0;
    else if(offsetAtEnd <= barOffset) newIndex = lastIndex;
    else{
      //we are between offsetAtStart AND offsetAtEnd
      double adjustedOffset = barOffset;// - offsetAtSart;
      //print("offset at end: " + offsetAtEnd.toString());
      //print("last index: " + lastIndex.toString());
      double ratio = lastIndex / offsetAtEnd; 
      //print("ratio " + ratio.toString());
      double roughIndex = adjustedOffset * ratio;
      newIndex = roughIndex.round();
      print("rough: " + roughIndex.toString());
    }
    */
    //we are between offsetAtStart AND offsetAtEnd
    double adjustedOffset = barOffset;// - offsetAtSart;
    //print("offset at end: " + offsetAtEnd.toString());
    //print("last index: " + lastIndex.toString());
    double ratio = lastIndex / widget.programaticScrollBarHeight; 
    //print("ratio " + ratio.toString());
    double roughIndex = adjustedOffset * ratio;
    newIndex = roughIndex.round();
    print("rough: " + roughIndex.toString());
    print("refined: " + newIndex.toString());

    //only trigger new index thing IF this scroll position changes our index
    if(newIndex != index){
      index = newIndex;
      print("---------------------------------------------------------TO INDEX: " + index.toString());
    }
    */

    //TODO... jump to that location
    //widget.autoScrollController.jumpTo(widget.positions.first);
    
    //set state to reflect all the changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    doMath();

    //build
    return Stack(
      children: <Widget>[
        Center(
          child: GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            child: Container(
              color: (scrollBarColors) ? Colors.green.withOpacity(0.5) : Colors.transparent,
              height: widget.programaticScrollBarHeight,
              child: Container(
                color: (scrollBarColors) ? Colors.red.withOpacity(0.5) : Colors.transparent,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: barOffset),
                child: Container(),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Container(
              height: widget.visualScrollBarHeight,
              width: 24,
              padding: EdgeInsets.only(top: thumbOffset),
              color: (scrollBarColors) ? Colors.yellow : Colors.transparent,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: widget.scrollThumbHeight,
                    decoration: new BoxDecoration(
                      color: widget.thumbColor,
                      borderRadius: new BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}