import 'package:flutter/material.dart';

//NOTE: this widget is designed specifically to go OVER a slider
//the idea is that the slider takes you to certain positions and this should give you some idea of what those positions are

//In order to meet it's goals as best as possible we MUST
//1. fill the entirety of the totalHeight
//   - otherwise the overlay won't match the slider and it won't be helpful
//   - we do this by making the spacing larger if needed
//    - the minimumSpacing is just used to determine how many item guides we can show
//2. have the first and last item displayed as an item guide
//   - this is important once again because if not the overlay wont be reflective of the slider
//   - we do this by grabbing the first item and then trying to divide the rest in groups
//   - sometimes we can't possibly divide things into groups 
//      - because we are working off of a prime
//      - in which case we basically combine the last group with the last number

/*
Example of #2
we have 6 items and 3 spots for item guides

we need to have the 1st item as a item guide
[1] | 2, 3, 4, 5, 6
but now we have 5 items to cover and only 2 spots for item guides
the best we can do is a 2 group of 2 and one item on its own
[1] | [2,3] | [4,5] | 6
but we can combine the last two groups
[1] | [2,3] | [4,5,6]
then our item guides will be the last item in each group
[1] 2 [3] 4 5 [6]
this will create a bit of an unusual gap between 3 and 6
but this is the best that is possible if you want the overlay to still be reflective of whats happening
*/

//NOTE: we don't have to worry about the size of the item guide
//this is because after the math is done
//every item guide in the overlay is technically of size 0
//every spacing in the overlay is an expanded widget
//between every two item guides there is a spacer
//So since we are using overlay box as a child of every item guide
//thing will be aligned as expected

//NOTE: we are GUARANTEED to have letterCodes when passing that into this widget
//and since we only retreive contacts ONCE we know we don't need to do this again
//and therefore it can stay stateless
class AlphaScrollBarOverlay extends StatelessWidget {
  AlphaScrollBarOverlay({
    @required this.scrollBarHeight,
    @required this.spacingVertical,
    @required this.letterCodes,
    @required this.itemHeight,
  });

  final double scrollBarHeight;
  final double spacingVertical;
  //TODO... convert this to a list of widgets
  final List<int> letterCodes;
  //this should be the height of all the equally sized widgets in items
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    //ideally we show all of the keys but most likely it isnt possible
    //  (in fact this is the entire reason I built this tool)
    //so we have to calculate how many values we can take in
    //ONLY the first and last item MUST be visible

    //In A Perfect World
    //total height = height of items + height of items' spacing
    //height of items = height * items
    //height of items' spacing =  spacing * (items-1)

    //Reconfigure to calculate items
    //  ATH >= (H * items) + (S * [items - 1])
    //  ATH >= (H * items) - S + (S * items)
    //  ATH + S >= (H * items) + (S * items)
    //  ATH + S >= (H + S) * items
    // (ATH + S) / (H + s) >= items

    //Since initially ATH >= function
    //we truncate the result of items
    //no partial items can exist
    int itemGuideCount = ((scrollBarHeight + spacingVertical) ~/ (itemHeight + spacingVertical));

    //if there isnt enough space for anything then -> simply fill the space there is
    if(itemGuideCount == 0) return Container(height: scrollBarHeight);
    else{
      //if there is only space for one thing
      if(itemGuideCount == 1){
        //AND we have nothing to fill it with -> simply fill the space there is
        if(letterCodes.length == 0) return Container(height: scrollBarHeight);
        else{
          //AND we have anything to fill it with -> fill it with the first
          return new OnlyShowFirst(
            scrollBarHeight: scrollBarHeight, 
            itemHeight: itemHeight, 
            items: letterCodes,
          );
        }
      }
      else{
        //NOTE: we KNOW we have space for atleast 2 possible spots

        if(letterCodes.length == 0) return Container(height: scrollBarHeight);
        else{
          if(letterCodes.length == 1){
            return new OnlyShowFirst(
              scrollBarHeight: scrollBarHeight, 
              itemHeight: itemHeight, 
              items: letterCodes,
            );
          }
          else{
            //NOTE: we KNOW we have atleast 2 possible spots
            //AND 2 possible items
            //SO... we will be able to atleast have the first and last items
            //on top of the scroll bar, but we may also be able to have more

            //NOTE: works as long as we have ATLEAST ONE OF EACH

            //we ALWAYS include the first key 
            int keyCount = letterCodes.length - 1;
            itemGuideCount -= 1;

            //we know we are using the first index
            List<int> itemGuideIndices = new List<int>();
            itemGuideIndices.add(0);

            if(itemGuideCount > 0){
              //calc the group sizes of all the items left
              int groupSize = keyCount ~/ itemGuideCount;
              //covers case I noticed
              //EX: you have 21 slots and 28 items
              //MUST DO THIS
              //other wise might run into case where the last list is 
              //SO MUCH LARGER thatn the rest that the spacers mess things up
              //you would include index 0 to 19
              //then jump to index 27
              //an 8 item gap with spacers that would break everything
              //This bases itself off of the basic rule that although its better to
              //use all available itemGuide slots
              //its preferable to not use them all If it means things will look good

              //TODO... check if there is an alternative solution 
              //OR if we always need to add one (math.ceil)
              if((itemGuideCount * groupSize) < keyCount){
                groupSize++;
              }

              //iterate through all the items and mark the ones we will be using as item guides
              for(int i = groupSize; i < letterCodes.length && itemGuideCount > 0; i += groupSize){
                int addIndex;
                bool nextWillExit = (i + groupSize) >= letterCodes.length;
                if(itemGuideCount == 1 || nextWillExit){
                  addIndex = letterCodes.length - 1;
                }
                else addIndex = i;

                //this item took up an item guide slot
                itemGuideIndices.add(addIndex);
                itemGuideCount--;
              }
            }

            //generate widget list
            List<Widget> widgets = new List<Widget>();
            widgets.clear();
            for(int i = 0; i < letterCodes.length; i++){

              //If we marked this as an itemGuide then make it so
              //else put a placer holder
              Widget itemGuide;
              if(itemGuideIndices.contains(i)){
                itemGuide = OverflowBox(
                  minHeight: itemHeight,
                  maxHeight: itemHeight,
                  //NOTE: width auto set
                  child: Container(
                    height: itemHeight,
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        String.fromCharCode(letterCodes[i]),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }
              else itemGuide = Container();

              //add the spacer BEFORE if not the first item
              if(i != 0){
                widgets.add(
                  Expanded(
                    child: Container(),
                  ),
                );
              }
              
              //add the item widget
              widgets.add(
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 0,
                  child: itemGuide,
                )
              );
            }

            //output the widget
            return Center(
              child: Container(
                height: scrollBarHeight,
                width: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: widgets,
                ),
              ),
            );
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

//TODO... switch over to using the same thing as every thing else
//we may only have one possible slot but we still need 
//0 sized containers and expanded widget spacer
//so that we can properly align with the slider
class OnlyShowFirst extends StatelessWidget {
  const OnlyShowFirst({
    Key key,
    @required this.scrollBarHeight,
    @required this.itemHeight,
    @required this.items,
  }) : super(key: key);

  final double scrollBarHeight;
  final double itemHeight;
  final List<int> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: scrollBarHeight,
      child: Center(
        child: Container(
          height: itemHeight,
          child: Text(
            String.fromCharCode(items[0])
          ),
        ),
      ),
    );
  }
}