import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/scrollBar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:vibration/vibration.dart';

import '../vibrate.dart';

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
    @required this.sortedKeys,
  });

  final double visualScrollBarHeight;
  final double programaticScrollBarHeight;
  final double alphaOverlayHeight;
  final double scrollThumbHeight;
  final AutoScrollController autoScrollController;
  final double paddingAll;
  final Color thumbColor;
  final List<double> positions;
  final List<int> sortedKeys;

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

  //show or hide the slider
  ValueNotifier<bool> showSlider;

  //init
  @override
  void initState() {
    //super init
    super.initState();

    //handle show hide slider stuff
    showSlider = new ValueNotifier(false);

    //whenever this changes we need to set state
    showSlider.addListener((){
      setState(() {
        
      });
    });

    //we start on top so this is set as such
    index = 0;
    barOffsetPercent = 0.0;

    //do initial math
    doMath();
  }

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

    //idk why i need to do this here instead of in init
    lastIndex = widget.positions.length - 1;

    //determine what index to go to
    int newIndex = 0;
    double ratio = lastIndex / thumbScrollBarHeight;
    //print("ratio " + ratio.toString());
    double roughIndex = thumbOffset * ratio;
    newIndex = roughIndex.round();

    //only trigger new index thing IF this scroll position changes our index
    if(newIndex != index){
      index = newIndex;
      vibrate();
      widget.autoScrollController.jumpTo(widget.positions[index]);
    }
    
    //set state to reflect all the changes
    setState(() {});
  }

  //build
  @override
  Widget build(BuildContext context) {
    doMath();

    double circleSize = 75;
    String thumbTackChar;
    if(widget.sortedKeys.length == 0) thumbTackChar = " ";
    else thumbTackChar = String.fromCharCode(widget.sortedKeys[index]);

    //build
    return Visibility(
      visible: showSlider.value,
      maintainAnimation: true,
      maintainInteractivity: true,
      maintainSemantics: true,
      maintainSize: true,
      maintainState: true,
      child: Stack(
        children: <Widget>[
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragDown: (dragDownDetails){
                showSlider.value = true;
              },
              onVerticalDragStart: (dragStartDetails){
                showSlider.value = true;
              },
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragCancel: (){
                showSlider.value = false;
              },
              onVerticalDragEnd: (dragEndDetails){
                showSlider.value = false;
              },
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
                //the stack is needed to allow height to actual take effect
                child: Stack(
                  children: <Widget>[
                    Stack(
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
                          child: Transform.translate(
                            offset: Offset(
                              //the last one is extra
                              -(circleSize/2) - (24/2) - 16, 
                              0,
                            ),
                            child: Center(
                              child: Container(
                                child: OverflowBox(
                                  minWidth: circleSize,
                                  maxWidth: circleSize,
                                  maxHeight: circleSize,
                                  minHeight: circleSize,
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      color: widget.thumbColor,
                                      borderRadius: new BorderRadius.all(
                                        Radius.circular(circleSize / 2),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        thumbTackChar,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: circleSize/2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}