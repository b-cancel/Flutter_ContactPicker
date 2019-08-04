import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//Mostly taken from this article
//https://medium.com/flutter-community/creating-draggable-scrollbar-in-flutter-a0ae8cf3143b
//Left off here
//Search "As we see on screen capture when list is scrolled scrollthumb is not moving"

class DraggableScrollBar extends StatefulWidget {
  DraggableScrollBar({
    @required this.visualScrollBarHeight,
    @required this.programaticScrollBarHeight,
    @required this.scrollThumbHeight,
    @required this.autoScrollController,
    @required this.paddingAll,
  });

  final double visualScrollBarHeight;
  final double programaticScrollBarHeight;
  final double scrollThumbHeight;
  final AutoScrollController autoScrollController;
  final double paddingAll;

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

  //init
  @override
  void initState() {
    super.initState();
    barOffsetPercent = 0.0;

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
    //handle thumb
    thumbScrollBarHeight = widget.visualScrollBarHeight - widget.scrollThumbHeight;
    thumbMultiplier = thumbScrollBarHeight / widget.programaticScrollBarHeight;

    //convert the percent to an actual valued offset
    barOffset = widget.programaticScrollBarHeight * barOffsetPercent;
    thumbOffset = barOffset * thumbMultiplier;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    print("lskdfjlsadfj: " + widget.autoScrollController.position.maxScrollExtent.toString());

    //travel to our fingers position
    double barOffset = details.localPosition.dy;
    //clamp the values
    barOffset = barOffset.clamp(0, widget.programaticScrollBarHeight).toDouble();
    //shift the offset to a percent of travel
    barOffsetPercent = barOffset / widget.programaticScrollBarHeight;

    //do math based on the barOffSet percent
    doMath();

    //TODO... jump to that location
    
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
              color: Colors.green.withOpacity(0.5),
              width: 24.0 + (2 * widget.paddingAll),
              height: widget.programaticScrollBarHeight,
              child: Container(
                color: Colors.red.withOpacity(0.5),
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: barOffset),
                child: Container(
                  height: 0,
                ),
              ),
            ),
          ),
        ),
        /*
        IgnorePointer(
          child: Padding(
            padding: EdgeInsets.all(widget.paddingAll),
            child: Padding(
              padding: EdgeInsets.only(top: thumbOffset),
              child: Container(
                width: 24,
                height: widget.scrollThumbHeight,
                decoration: new BoxDecoration(
                  color: Colors.blue,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
       */ 
      ],
    );
  }
}