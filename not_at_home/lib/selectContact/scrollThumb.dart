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
    @required this.autoScrollController,
    @required this.scrollThumbHeight,
    @required this.paddingAll,
  });

  final double visualScrollBarHeight;
  final double programaticScrollBarHeight;
  final AutoScrollController autoScrollController;
  final double scrollThumbHeight;
  final double paddingAll;

  @override
  _DraggableScrollBarState createState() => new _DraggableScrollBarState();
}

class _DraggableScrollBarState extends State<DraggableScrollBar> {
  /*
  //this counts offset for scroll thumb in Vertical axis
  double _barOffset;
  //this counts offset for list in Vertical axis
  double _viewOffset;
  @override
  void initState() {
    super.initState();
    _barOffset = 0.0;
    _viewOffset = 0.0;
  }

  //if list takes 300.0 pixels of height on screen and scrollthumb height is 40.0
  //then max bar offset is 260.0
  double get barMaxScrollExtent =>
      context.size.height - widget.heightScrollThumb;
  double get barMinScrollExtent => 0.0;

  //this is usually lenght (in pixels) of list
  //if list has 1000 items of 100.0 pixels each, maxScrollExtent is 100,000.0 pixels
  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;
  //this is usually 0.0
  double get viewMinScrollExtent => widget.controller.position.minScrollExtent;

  double getScrollViewDelta(
    double barDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) { //propotion
    return barDelta * viewMaxScrollExtent / barMaxScrollExtent;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _barOffset += details.delta.dy;

      if (_barOffset < barMinScrollExtent) {
        _barOffset = barMinScrollExtent;
      }
      if (_barOffset > barMaxScrollExtent) {
        _barOffset = barMaxScrollExtent;
      }

      double viewDelta = getScrollViewDelta(
          details.delta.dy, barMaxScrollExtent, viewMaxScrollExtent);

      _viewOffset = widget.controller.position.pixels + viewDelta;
      if (_viewOffset < widget.controller.position.minScrollExtent) {
        _viewOffset = widget.controller.position.minScrollExtent;
      }
      if (_viewOffset > viewMaxScrollExtent) {
        _viewOffset = viewMaxScrollExtent;
      }
      widget.controller.jumpTo(_viewOffset);
    });
  }
  */

  //this counts offset for scroll thumb for Vertical axis
  double barOffset;
  double thumbOffset;

  @override
  void initState() {
    super.initState();
    barOffset = 0.0;
    thumbOffset = 0.0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    print("dets: " + details.localPosition.dy.toString());
    print("double: " + widget.programaticScrollBarHeight.toString());

    //widget.visualScrollBarHeight
    double scrollThumbTravel = widget.visualScrollBarHeight - widget.scrollThumbHeight;
    double mutliplier = scrollThumbTravel / widget.programaticScrollBarHeight;
    setState(() {
      //travel to our fingers position
      barOffset = details.localPosition.dy;
      //clamp the values
      barOffset = barOffset.clamp(0, widget.programaticScrollBarHeight).toDouble();
      //apply values to visual
      thumbOffset = barOffset * mutliplier;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        )
      ],
    );
  }
}