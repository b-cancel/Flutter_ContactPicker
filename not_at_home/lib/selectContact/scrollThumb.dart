import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'dart:math' as math;

//Mostly taken from this article
//https://medium.com/flutter-community/creating-draggable-scrollbar-in-flutter-a0ae8cf3143b
//Left off here
//Search "As we see on screen capture when list is scrolled scrollthumb is not moving"

class DraggableScrollBar extends StatefulWidget {
  DraggableScrollBar({
    @required this.scrollBarHeight,
    @required this.autoScrollController,
    @required this.scrollThumbHeight,
  });

  final double scrollBarHeight;
  final AutoScrollController autoScrollController;
  final double scrollThumbHeight;

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

  @override
  void initState() {
    super.initState();
    barOffset = 0.0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    print("dets: " + details.localPosition.dy.toString());
    print("double: " + widget.scrollBarHeight.toString());
    setState(() {
      //_barOffset += details.delta.dy;
      barOffset = details.localPosition.dy;
      //370
      barOffset = barOffset.clamp(0, widget.scrollBarHeight).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: Container(
          width: 16 + 24.0 + 16,
          height: widget.scrollBarHeight,
          child: Stack(
            children: <Widget>[
              Container(
                width: 16 + 24.0 + 16,
                color: Colors.green.withOpacity(0.5),
              ),
              Container(
                width: 16 + 24.0 + 16,
                color: Colors.red.withOpacity(0.5),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: barOffset),
                child: Container(
                  height: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
widget.scrollThumbHeight,
  decoration: new BoxDecoration(
    color: Colors.purple,
    borderRadius: new BorderRadius.all(
      Radius.circular(25.0),
    ),
  ),
*/