import 'package:flutter/material.dart';
import 'package:not_at_home/selectContact/scrollBar.dart';
import 'package:not_at_home/vibrate.dart';
import 'package:page_transition/page_transition.dart';

import 'package:vector_math/vector_math_64.dart' as VECT;
import 'package:not_at_home/newContact.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

//add search bar
//https://blog.usejournal.com/flutter-search-in-listview-1ffa40956685

//Potential but complicated
//https://github.com/zhahao/list_view_item_builder

/*
await controller.scrollToIndex(verseID, preferPosition: AutoScrollPosition.begin);
controller.highlight(verseID);
*/

class SelectContactUX extends StatefulWidget {
  SelectContactUX({
    this.retreivingContacts: false,
    @required this.contactCount,
    @required this.sortedLetterCodes,
    @required this.letterToListItems,
    @required this.sectionWidgets,
    @required this.backFromNewContact,
    @required this.onSelect,
    @required this.userPrompt,
  });

  final bool retreivingContacts;
  final int contactCount;
  final List<int> sortedLetterCodes;
  final Map<int, List<Widget>> letterToListItems;
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

  //determines whether or not to show the scrolling thumb tack
  final ValueNotifier<bool> showThumbTack = new ValueNotifier(false);

  //the scroll conroller
  AutoScrollController autoScrollController;

  //status bar height to be used throughout
  double statusBarHeight;
  double toolBarHeight;

  //init
  @override
  void initState() {
    //auto scroll controller
    autoScrollController = new AutoScrollController();
    autoScrollController.addListener((){
      ScrollPosition position = autoScrollController.position;
      //&& !position.outOfRange
      if (autoScrollController.offset <= position.minScrollExtent) {
        onTop.value = true;
      }
      else onTop.value = false;
    });
    toolBarHeight = 40;

    //super
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
    //Styling of the User Question Prompt
    TextStyle questionStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );

    //Generate the Widget shown in the contacts scroll area
    //Depending on whether or not there are contacts or they are being retreived
    Widget bodyWidget;
    bool contactsVisible = true;
    if(widget.retreivingContacts || widget.sectionWidgets.length == 0){
      contactsVisible = false;
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
      //spacer on bottom of list
      //NOTE: be after the above
      int nextIndex = widget.sectionWidgets.length;
      widget.sectionWidgets.add(
        Column(
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
              //16 is padding
              //48 is the size of the button
              height: 16.0 + 48 + 16,
            ),
          ],
        ),
      );

      //wrap items in sliver list
      bodyWidget = SliverList(
        delegate: SliverChildListDelegate(
          widget.sectionWidgets,
        ),
      );
    }

    //status bar height grabber (MUST NOT BE IN) init
    statusBarHeight = MediaQuery.of(context).padding.top;

    //build widgets
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            OrientationBuilder(
              builder: (context, orientation){
                //variables prepped
                bool isPortrait = (orientation == Orientation.portrait);
                double expandedHeight = MediaQuery.of(context).size.height;
                print("expandedHeight: " + expandedHeight.toString());

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
                  orientationPrompt = RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: textSpans,
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
                  orientationPrompt = Text(
                    generateString,
                    style: questionStyle,
                  );
                }

                //add the fitted box to the widget
                orientationPrompt = FittedBox(
                  fit: BoxFit.contain,
                  child: orientationPrompt,
                );

                //build
                return Container(
                  color: Theme.of(context).primaryColor,
                  child: Stack(
                    children: <Widget>[
                      CustomScrollView(
                        controller: autoScrollController,
                        slivers: <Widget>[
                          new TopAppBar(
                            toolBarHeight: toolBarHeight,
                            expandedHeight: expandedHeight, 
                            flexibleHeight: flexibleHeight,
                            flexibleClosed: flexibleClosed, 
                            extraPadding: extraPadding, 
                            orientationPrompt: orientationPrompt, 
                            backFromNewContact: widget.backFromNewContact,
                            onSelect: widget.onSelect,
                          ),
                          //IF no contacts OR retreiving contacts -> fill remaining
                          //ELSE -> list of widgets
                          bodyWidget,
                        ],
                      ),
                      (contactsVisible) ? new ScrollBar(
                        statusBarHeight: statusBarHeight,
                        autoScrollController: autoScrollController,
                        flexibleHeight: flexibleHeight, //(useDynamicTopPadding) ? flexibleHeight : new ValueNotifier(0), 
                        expandedHeight: expandedHeight,
                        sortedLetterCodes: widget.sortedLetterCodes,
                        showThumbTack: showThumbTack,
                        letterToListItems: widget.letterToListItems,
                      ) : Container(),
                    ],
                  ),
                );
              },
            ),
            ScrollToTopButton(
                onTop: onTop, 
                autoScrollController: autoScrollController,
            ),
          ],
        ),
      ),
    );
  }
}

class TopAppBar extends StatelessWidget {
  const TopAppBar({
    Key key,
    @required this.toolBarHeight,
    @required this.expandedHeight,
    @required this.flexibleHeight,
    @required this.flexibleClosed,
    @required this.extraPadding,
    @required this.orientationPrompt,
    @required this.backFromNewContact,
    @required this.onSelect,
  }) : super(key: key);

  final double toolBarHeight;
  final double expandedHeight;
  final ValueNotifier<double> flexibleHeight;
  final ValueNotifier<bool> flexibleClosed;
  final double extraPadding;
  final Widget orientationPrompt;
  final ValueNotifier<bool> backFromNewContact;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      //true so that we get the safe area added on top
      primary: true,

      //Pinned MUST be True for ease of use
      pinned: true, //show the user then can search regardless of where they are on the list
      //Floating MUST be true so for ease of use
      //but NAW its false because any user that is going to search or add a contact will do so at the start
      floating: true, //show scroll bar as soon as user starts scrolling up
      //Snap is TRUE so that our flexible space result looks as best as it can
      //but NAW its FALSE cuz it snaps weird...
      snap: false, //ONLY if floating is true

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
            flexibleClosed.value = (flexibleHeight.value == toolBarHeight);
          });

          //build
          return FlexibleSpaceBar(
            background: Container(
              color: Theme.of(context).primaryColorDark,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(extraPadding),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: toolBarHeight,
                ),
                child: Container(
                  child: orientationPrompt,
                ),
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
          toolBarHeight,
        ),
        child: Container(
          color: Theme.of(context).primaryColorDark,
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
                  color: Theme.of(context).primaryColorDark,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          backFromNewContact.value = true;
                          Navigator.push(
                            context, PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: NewContact(
                                onSelect: onSelect,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: toolBarHeight,
                          width: 16.0 + 24 + 16,
                          child: Icon(Icons.add),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          print("SEARCH");
                        },
                        child: Container(
                          height: toolBarHeight,
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
    );
  }
}

class ScrollToTopButton extends StatelessWidget {
  const ScrollToTopButton({
    Key key,
    @required this.onTop,
    @required this.autoScrollController,
  }) : super(key: key);

  final ValueNotifier<bool> onTop;
  final AutoScrollController autoScrollController;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: 16),
        child: AnimatedBuilder(
          animation: onTop,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
            onPressed: (){
              vibrate();
              //scrollToIndex -> too slow to find index
              //jumpTo -> happens instant but scrolling to top should have some animation
              //NOTE: I ended up going with jump since animate was not fully opening the prompt
              autoScrollController.jumpTo(0);
            },
            //slightly shift the combo of the two icons
            child: FittedBox(
              fit: BoxFit.contain,
              child: Transform.translate(
                offset: Offset(0,-12), //-4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 12,
                      child: Icon(
                        Icons.minimize,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Container(
                      height: 12,
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white.withOpacity(0.5),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          builder: (context, child){
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              transform: Matrix4.translation(
                VECT.Vector3(
                  0, 
                  (onTop.value) ? (16.0 + 56) : 0.0, 
                  0,
                ),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }
}