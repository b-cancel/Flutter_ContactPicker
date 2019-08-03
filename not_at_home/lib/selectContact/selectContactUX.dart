import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/alphaScrollBar.dart';
import 'package:page_transition/page_transition.dart';

import 'package:vector_math/vector_math_64.dart' as VECT;
import 'dart:math' as math;
import 'package:not_at_home/newContact.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

//add search bar
//https://blog.usejournal.com/flutter-search-in-listview-1ffa40956685

//Potential but complicated
//https://github.com/zhahao/list_view_item_builder

//Scrollable.ensureVisible(_key);

/*
await controller.scrollToIndex(verseID, preferPosition: AutoScrollPosition.begin);
controller.highlight(verseID);
*/

class SelectContactUX extends StatefulWidget {
  SelectContactUX({
    this.retreivingContacts: false,
    @required this.contactCount,
    @required this.sortedKeys,
    @required this.sectionWidgets,
    @required this.backFromNewContact,
    @required this.onSelect,
    @required this.userPrompt,
  });

  final bool retreivingContacts;
  final int contactCount;
  final List<int> sortedKeys;
  final List<Widget> sectionWidgets;
  final ValueNotifier<bool> backFromNewContact;
  final Function onSelect;
  final List<String> userPrompt;

  @override
  _SelectContactUXState createState() => _SelectContactUXState();
}

class _SelectContactUXState extends State<SelectContactUX> {
  //assume the flexible is open at the start
  final ValueNotifier<bool> flexibleClosed = new ValueNotifier(true);
  //TODO... use largest not smallest
  final ValueNotifier<double> flexibleHeight = new ValueNotifier(40); 

  //starts off on top
  final ValueNotifier<bool> onTop = new ValueNotifier(true);

  //the scroll conroller
  AutoScrollController autoScrollController;

  //init
  @override
  void initState() {
    autoScrollController = new AutoScrollController();
    autoScrollController.addListener((){
      ScrollPosition position = autoScrollController.position;
      //&& !position.outOfRange
      if (autoScrollController.offset <= position.minScrollExtent) {
        onTop.value = true;
      }
      else onTop.value = false;
    });
    super.initState();
  }

  //dispose
  @override
  void dispose() {
    autoScrollController.dispose();
    super.dispose();
  }

  //build
  @override
  Widget build(BuildContext context) {
    //add the autoscroll stuff to section widgets
    for(int i = 0; i < widget.sectionWidgets.length; i++){
      Widget section = widget.sectionWidgets[i];

      widget.sectionWidgets[i] = AutoScrollTag(
        key: ValueKey(i),
        controller: autoScrollController,
        index: i,
        child: section,
      );
    }

    //spacer on bottom of list
    int nextIndex = widget.sectionWidgets.length;
    widget.sectionWidgets.add(
      AutoScrollTag(
        key: ValueKey(nextIndex),
        controller: autoScrollController,
        index: nextIndex,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(widget.contactCount.toString() + " Contacts"),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              //make sure to top button isnt covered
              height: 16.0 + 48 + 16,
            ),
          ],
        ),
      ),
    );

    //Styling of the User Question Prompt
    TextStyle questionStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );

    //Generate the Widget shown in the contacts scroll area
    //Depending on whether or not there are contacts or they are being retreived
    Widget bodyWidget;
    if(widget.retreivingContacts || widget.sectionWidgets.length == 0){
      bodyWidget = SliverFillRemaining(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Text(
            (widget.retreivingContacts) ? "Retreiving Contacts" : "No Contacts Found",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    else{
      bodyWidget = SliverList(
        delegate: SliverChildListDelegate(
          widget.sectionWidgets,
        ),
      );
    }

    //build widgets
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            OrientationBuilder(
              builder: (context, orientation){
                //variables prepped
                bool isPortrait = (orientation == Orientation.portrait);
                double screenWidth = MediaQuery.of(context).size.width;
                double expandedHeight = MediaQuery.of(context).size.height;

                //is portrait can have more of the screen taken up
                expandedHeight /= (isPortrait) ? 3 : 5;

                //make sure that even in landscape we have min height
                expandedHeight = (expandedHeight < (16 + 24)) ? 40 : expandedHeight;

                //determine how much extra padding we need
                double extraPadding = (isPortrait) ? 16 : 8;

                //generate the prompt
                Widget orientationPrompt;

                if(isPortrait){
                  //generate the multi lined string
                  List<TextSpan> textSpans = new List<TextSpan>();
                  for(int i = 0; i < widget.userPrompt.length; i++){
                    //add a spacer before each textspan that is not the first
                    if(i != 0){
                      textSpans.add(
                        TextSpan(text: "\n"),
                      );
                    }

                    //add the actual textSpan
                    textSpans.add(
                      TextSpan(
                        text: widget.userPrompt[i],
                        style: questionStyle,
                      ),
                    );
                  } 

                  //create the widget
                  orientationPrompt = FittedBox(
                    fit: BoxFit.fitWidth,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: textSpans,
                      ),
                    ),
                  );
                }
                else{
                  //generate the single lined string
                  String generateString = "";
                  for(int i = 0; i < widget.userPrompt.length; i++){
                    if(i == 0) generateString += widget.userPrompt[i];
                    else generateString += (" " + widget.userPrompt[i]);
                  }

                  //create the widget
                  orientationPrompt = FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      generateString,
                      style: questionStyle,
                    ),
                  );
                }

                List<Widget> scrollBarItems = new List<Widget>();
                for(int i = 0; i < widget.sortedKeys.length; i++){
                  Color color = (i%2==0) ? Colors.red : Colors.blue;

                  scrollBarItems.add(
                    Expanded(
                      child: GestureDetector(
                        onVerticalDragUpdate: (tdd){
                          print("---" + i.toString());
                        },
                        child: Container(
                          color: color,
                        ),
                      ),
                    )
                  );
                }

                //build
                return Container(
                  color: Theme.of(context).primaryColor,
                  child: Stack(
                    children: <Widget>[
                      CustomScrollView(
                        controller: autoScrollController,
                        slivers: <Widget>[
                          SliverAppBar(
                            //true so that we get the safe area added on top
                            primary: true,

                            //Pinned MUST be True for ease of use
                            pinned: true, //show the user then can search regardless of where they are on the list
                            //Floating MUST be true so for ease of use
                            //but NAW its false because any user that is going to search or add a contact will do so at the start
                            floating: true, //show scroll bar as soon as user starts scrolling up
                            //Snap is TRUE so that our flexible space result looks as best as it can
                            //but NAW its FALSE cuz it snaps weird...
                            snap: true, //ONLY if floating is true

                            //NOTE: title and leading not being used 
                            //because they are simply above the flexible widget
                            //but it hides after the flexible widget gets closed
                            
                            //Lets the user know what they are select a contact for
                            expandedHeight: expandedHeight,
                            flexibleSpace: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                //determine whether the space bar is open or closed
                                WidgetsBinding.instance.addPostFrameCallback((_){
                                  flexibleHeight.value = constraints.biggest.height;
                                  flexibleClosed.value = (flexibleHeight.value == 40.0);
                                });

                                //build
                                return FlexibleSpaceBar(
                                  background: Container(
                                    width: screenWidth,
                                    padding: EdgeInsets.fromLTRB(
                                      extraPadding,
                                      extraPadding,
                                      extraPadding,
                                      //extras come from the select contact bar
                                      extraPadding + 16 + 24,
                                    ),
                                    child: Container(
                                      child: orientationPrompt,
                                    ),
                                  ),
                                  //this does not seem to make any difference
                                  //but it MIGHT so ill keep it
                                  //it changes FlexibleSpaceBarSettings
                                  collapseMode: CollapseMode.parallax,
                                );
                              }
                            ),

                            //Lets the user know they can search
                            bottom: PreferredSize(
                              preferredSize: Size(
                                MediaQuery.of(context).size.width,
                                //16 from top and bottom padding below
                                //24 from the content in the child
                                16.0 + 24.0,
                              ),
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                width: MediaQuery.of(context).size.width,
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Text("Select Contact"),
                                        ),
                                      ),
                                      Material(
                                        color: Theme.of(context).primaryColor,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: (){
                                                widget.backFromNewContact.value = true;
                                                Navigator.push(
                                                  context, PageTransition(
                                                    type: PageTransitionType.rightToLeft,
                                                    child: NewContact(
                                                      onSelect: widget.onSelect,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 16.0 + 24 + 16,
                                                child: Icon(Icons.add),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (){
                                                print("SEARCH");
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 16.0 + 24 + 16,
                                                child: Icon(Icons.search),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          bodyWidget,
                        ],
                      ),
                      AnimatedBuilder(
                        animation: flexibleHeight,
                        child: Container(
                          color: Colors.green,
                          padding: EdgeInsets.all(16),
                          child: Container(
                            color: Colors.blue,
                            width: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: scrollBarItems,
                            ),
                          ),
                        ),
                        builder: (BuildContext context, Widget child) {
                          double topPadding = 27.0 + 16;

                          //padding so sticky header isnt covered
                          if(flexibleClosed.value){
                           topPadding += (24.0 + 16); 
                          }

                          //padding that must be removed in landscape mode from some reason
                          if(isPortrait == false){
                            topPadding -= 18;
                          }

                          //live calced
                          double scrollAreaHeight = MediaQuery.of(context).size.height - flexibleHeight.value;

                          //build
                          return Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: scrollAreaHeight,
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: topPadding,
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    child,
                                    Center(
                                      child: Container(
                                        width: 24,
                                        child: AlphaScrollBar(
                                          scrollBarHeight: scrollAreaHeight - topPadding - 32,
                                          itemHeight: 14,
                                          minimumSpacing: 8,
                                          items: widget.sortedKeys,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            //scroll to top button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 16),
                child: AnimatedBuilder(
                  animation: onTop,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: (){
                      autoScrollController.animateTo(
                        autoScrollController.position.minScrollExtent,
                        duration: Duration(milliseconds: 200), 
                        curve: Curves.easeOut,
                      );
                    },
                    child: Transform.translate(
                      offset: Offset(0,-4),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 12,
                            child: Icon(Icons.minimize),
                          ),
                          Container(
                            height: 12,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  builder: (context, child){
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      transform: Matrix4.translation(
                        VECT.Vector3(
                          0, 
                          (onTop.value) ? (16.0 + 48) : 0.0, 
                          0,
                        ),
                      ),
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}