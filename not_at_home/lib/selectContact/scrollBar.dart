import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBarOverlay.dart';

class ScrollBar extends StatelessWidget {
  ScrollBar({
    Key key,
    @required this.flexibleHeight,
    @required this.sortedKeys,
    @required this.showThumbTack,
  }) : super(key: key);

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
        double halfPadding = 16;
        double paddingForScrollBar = 12;

        //calculate scroll overlay height
        double scrollOverlayHeight = totalHeight - appBarHeight;
        scrollOverlayHeight -= (stickyHeaderHeight * 2);
        scrollOverlayHeight -= (halfPadding * 2);

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
              child: Stack(
                children: <Widget>[
                  //-----Scroll Bar Base
                  new ScrollBarWrapper(
                    halfPadding: halfPadding, 
                    paddingForScrollBar: paddingForScrollBar, 
                    color: Colors.transparent,
                    alphaScrollBar: AlphaScrollBarOverlay(
                      scrollBarHeight: scrollOverlayHeight,
                      itemHeight: 18,
                      minimumSpacing: 2,
                      items: sortedKeys,
                    ),
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
                          child: Container(
                          ),
                        ),
                      ),
                  ),
                  //-----thumb tack test
                  AnimatedBuilder(
                    animation: showThumbTack,
                    builder: (context, child){
                      return Positioned(
                        left: 0,
                        bottom: 0,
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
                      );
                    },
                  ),
                  //-----Letters Overlay
                  new ScrollBarWrapper(
                    halfPadding: halfPadding, 
                    paddingForScrollBar: paddingForScrollBar, 
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    alphaScrollBar: AlphaScrollBarOverlay(
                      scrollBarHeight: scrollOverlayHeight,
                      itemHeight: 18,
                      minimumSpacing: 2,
                      items: sortedKeys,
                    ),
                  ),
                ],
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
    @required this.halfPadding,
    @required this.paddingForScrollBar,
    @required this.alphaScrollBar,
    @required this.color,
  }) : super(key: key);

  final double halfPadding;
  final double paddingForScrollBar;
  final Widget alphaScrollBar;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      //extra padding
      padding: EdgeInsets.all(halfPadding),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            width: 24,
            decoration: new BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                borderRadius: new BorderRadius.all(
                  Radius.circular(25.0),
                ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //TODO... scroll items were here
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: paddingForScrollBar,
                ),
                width: 24,
                decoration: new BoxDecoration(
                  color: color,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
                child: alphaScrollBar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/*
new DraggableScrollbar(
          child: _buildGrid(),
          heightScrollThumb: 40.0,
          controller: controller,
        ),
*/

class DraggableScrollbar extends StatefulWidget {
  final double heightScrollThumb;
  final Widget child;
  final ScrollController controller;

  DraggableScrollbar({this.heightScrollThumb, this.child, this.controller});

  @override
  _DraggableScrollbarState createState() => new _DraggableScrollbarState();
}

class _DraggableScrollbarState extends State<DraggableScrollbar> {
  //this counts offset for scroll thumb in Vertical axis
  double _barOffset;
  //this counts offset for list in Vertical axis
  double _viewOffset;
  //variable to track when scrollbar is dragged
  bool _isDragInProcess;

  @override
  void initState() {
    super.initState();
    _barOffset = 0.0;
    _viewOffset = 0.0;
    _isDragInProcess = false;
  }

  //if list takes 300.0 pixels of height on screen and scrollthumb height is 40.0
  //then max bar offset is 260.0
  double get barMaxScrollExtent => context.size.height - widget.heightScrollThumb;
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
  ) {//propotion
    return barDelta * viewMaxScrollExtent / barMaxScrollExtent;
  }

  double getBarDelta(
    double scrollViewDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {//propotion
    return scrollViewDelta * barMaxScrollExtent / viewMaxScrollExtent;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragInProcess = false;
    });
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

  //this function process events when scroll controller changes it's position
  //by scrollController.jumpTo or scrollController.animateTo functions.
  //It can be when user scrolls, drags scrollbar (see line 139)
  //or any other manipulation with scrollController outside this widget
  changePosition(ScrollNotification notification) {
    //if notification was fired when user drags we don't need to update scrollThumb position
    if (_isDragInProcess) {
      return;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _barOffset += getBarDelta(
          notification.scrollDelta,
          barMaxScrollExtent,
          viewMaxScrollExtent,
        );

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        _viewOffset += notification.scrollDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          changePosition(notification);
        },
        child: new Stack(children: <Widget>[
          widget.child,
          GestureDetector(
              //we've add functions for onVerticalDragStart and onVerticalDragEnd
              //to track when dragging starts and finishes
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(top: _barOffset),
                  child: _buildScrollThumb())),
        ]));
  }

  Widget _buildScrollThumb() {
    return new Container(
      height: widget.heightScrollThumb,
      width: 20.0,
      color: Colors.blue,
    );
  }
}
*/