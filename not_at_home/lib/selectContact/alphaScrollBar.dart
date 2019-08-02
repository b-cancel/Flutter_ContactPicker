import 'package:flutter/material.dart';

import 'dart:math' as math;

//NOTE: this widget is designed specifically to 
//go over an alphabet slider
//so it MUST 
//1. fill the entirety of the totalHeight
//   - we do this by making the spacing larger if needed
//2. have the first and last key displayed
//   - we do this by approaching the math a little differently

//NOTE: since [2] and each of these keys has a [height]
//in order for [this] to be lined up with our [scroll bar]
//the returned widget will be of height
//[scrollBarHeight] - [(height/2) * 2]
//since it pushes the middle of the first and last key
//into the ends of the scrollBar it will be over

class AlphaScrollBar extends StatelessWidget {
  AlphaScrollBar({
    @required this.keys,
    @required this.scrollBarHeight,
    @required this.height,
    @required this.spacing,
  });

  final List<int> keys; //String.fromCharCode(key)
  final double scrollBarHeight;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    //adjust the scrollBarHeight as explained above
    double overlayBarHeight = scrollBarHeight + height;

    //ideally we show all of the keys but most likely it isnt possible
    //so we have to calculate how many values we can take in
    //ONLY the ends of the scroll bar should match actual

    //In A Perfect World
    //total height = height of items + height of items' spacing
    //height of items = height * items
    //height of items' spacing =  spacing * (items-1)

    //The Spacing Is As Such
    //Height Of Item
    //Spacing
    //Heigth Of Item

    //Reconfigure to calculate items
    //  ATH >= (H * items) + (S * [items - 1])
    //  ATH >= (H * items) - S + (S * items)
    //  ATH + S = (H * items) + (S * items)
    //  ATH + S = (H + S) * items
    // (ATH + S) / (H + s) = items

    //Since initially ATH >= function
    //we truncate the result of items
    //no partial items can exist
    int possibleItems = ((scrollBarHeight + spacing) ~/ (height + spacing));

    //build
    return Container(
      
    );
  }
}