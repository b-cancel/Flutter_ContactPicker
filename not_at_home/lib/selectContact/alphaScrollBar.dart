import 'package:flutter/material.dart';

import 'dart:math' as math;

//NOTE: this widget is designed specifically to 
//go over an alphabet slider
//so it MUST 
//1. fill the entirety of the totalHeight
//   - we do this by making the spacing larger if needed
//   - really we don't control spacing but rather set it minimum
//2. have the first and last key displayed
//   - we do this by approaching the math a little differently
//   - sometimes we can't possible divide things into groups 
//      - because we are working off of a prime
//      - in which case we basically combine the last group with the last number

//TODO... might not be true for later implementations
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
    int possibleItems = ((overlayBarHeight + spacing) ~/ (height + spacing));

    //if there isnt enough space for anything then -> simply fill the space there is
    if(possibleItems == 0) return Container(height: overlayBarHeight);
    else{
      //if there is only space for one thing
      if(possibleItems == 1){
        //AND we have nothing to fill it with -> simply fill the space there is
        if(keys.length == 0) return Container(height: overlayBarHeight);
        else{
          //AND we have anything to fill it with -> fill it with the first
          return Container(
            height: overlayBarHeight,
            child: Center(
              child: Container(
                height: height,
                child: Text(
                  String.fromCharCode(keys[0])
                ),
              ),
            ),
          );
        }
      }
      else{
        //NOTE: we KNOW we have space for atleast 2 possible spots

        if(keys.length == 0) return Container(height: overlayBarHeight);
        else{
          if(keys.length == 1){
            return Container(
              height: overlayBarHeight,
              child: Center(
                child: Container(
                  height: height,
                  child: Text(
                    String.fromCharCode(keys[0])
                  ),
                ),
              ),
            );
          }
          else{
            //NOTE: we KNOW we have atleast 2 possible spots
            //AND 2 possible items
            //SO... we will be able to atleast have the first and last items
            //on top of the scroll bar, but we may also be able to have more

            //we ALWAYS include the first key 
            int keyCount = keys.length - 1;
            possibleItems -= 1;

            //calc how many extra items we can have in our list
            int extraItems = 0;

            //do the extra math
            if(isPrime(keyCount)){
              extraItems = keyCount ~/ possibleItems;
            }

            /*
            return Container(
      
            );
            */
          }
        }
      }
    }
  }

  //Taken from https://stackoverflow.com/questions/31105664/check-if-a-number-is-prime
  bool isPrime(int n){
    if(n <= 1) return false;
    else if(n <= 3) return true;
    else{
      int i = 2;
      while(i*i <= n){
        if(n%i == 0) return false;
        else i +=1;
      }
      return true;
    }
  }
}

/*
Container(
        color: Colors.yellow,
        height: 500,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
            Expanded(
              child: Container(),
            ),
            new OverFlowTest(),
          ],
        )
      )

      class OverFlowTest extends StatelessWidget {
  const OverFlowTest({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      height: 0,
      width: 0,
      child: OverflowBox(
        minHeight: 100,
        maxHeight: 100,
        minWidth: 100,
        maxWidth: 100,
        child: Container(
          color: Colors.red.withOpacity(0.1),
        ),
      )
    );
  }
}
*/