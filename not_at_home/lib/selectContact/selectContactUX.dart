import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/searchContact.dart';
import 'package:not_at_home/selectContact/contactList.dart';
import 'package:not_at_home/selectContact/scrollBar.dart';
import 'package:not_at_home/vibrate.dart';
import 'package:page_transition/page_transition.dart';

import 'package:vector_math/vector_math_64.dart' as VECT;
import 'package:not_at_home/newContact.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

import 'dart:math' as math;

class SelectContactUX extends StatefulWidget {
  SelectContactUX({
    @required this.retreivingContacts,
    @required this.contacts,
    @required this.colorsForContacts,

    @required this.backFromNewContact,
    @required this.onSelect,
    @required this.userPrompt,
  });

  final ValueNotifier<bool> retreivingContacts;
  final ValueNotifier<List<Contact>> contacts;
  final List<Color> colorsForContacts;

  final ValueNotifier<bool> backFromNewContact;
  final Function onSelect;
  final List<String> userPrompt;

  @override
  _SelectContactUXState createState() => _SelectContactUXState();
}

class _SelectContactUXState extends State<SelectContactUX> {
  double expandedBannerHeight = 0;
  final ValueNotifier<double> bannerHeight = new ValueNotifier(0); 

  //show hid stuff on conditions
  final ValueNotifier<bool> onTop = new ValueNotifier(true);
  final ValueNotifier<bool> showThumbTack = new ValueNotifier(false);

  //the scroll conroller
  AutoScrollController autoScrollController;

  //NOTE: this is the absolute max height of this bar, else overflow occurs
  double toolBarHeight = 40;

  //init
  @override
  void initState() {
    //auto scroll controller
    autoScrollController = new AutoScrollController();
    autoScrollController.addListener((){
      ScrollPosition position = autoScrollController.position;
      double currentOffset = autoScrollController.offset;

      //Determine whether we are on the top of the scroll area
      if (currentOffset <= position.minScrollExtent) {
        onTop.value = true;
      }
      else onTop.value = false;

      //Determine whether to update the bannerHeight
      updateBanner();
    });

    //super
    super.initState();
  }

  updateBanner(){
    bool attached = autoScrollController.hasClients;
    double currentOffset = attached ? autoScrollController.offset : 0;
    if(currentOffset <= expandedBannerHeight){
      double visiblePortionOfBanner = currentOffset - expandedBannerHeight;
      bannerHeight.value = visiblePortionOfBanner.abs();
    }
    else bannerHeight.value = 0;
  }

  //dispose
  @override
  void dispose() {
    autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Styling of the User Question Prompt
    TextStyle questionStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );

    //build
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColorDark,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              OrientationBuilder(
                builder: (context, orientation){
                  //variables prepped
                  bool isPortrait = (orientation == Orientation.portrait);
                  expandedBannerHeight = MediaQuery.of(context).size.height;

                  //is portrait can have more of the screen taken up
                  expandedBannerHeight /= (isPortrait) ? 3 : 5;

                  //make sure that even in landscape we have min height
                  expandedBannerHeight = (expandedBannerHeight < (16 + 24)) ? 40 : expandedBannerHeight;

                  //update banner with expanded banner height
                  updateBanner();

                  //generate the prompt
                  Widget orientationPrompt;

                  //adjust the orientation prompt
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

                  //changes with orientation
                  double statusBarHeight = MediaQuery.of(context).padding.top;

                  //the header slivers
                  List<Widget> headerSlivers = [
                    Banner(
                      height: expandedBannerHeight, //varies with orientation
                      padding: 16,
                      prompt: orientationPrompt,
                    ),
                    ToolBar(
                      toolBarHeight: toolBarHeight,
                      orientationPrompt: orientationPrompt, //varies with orientation
                      backFromNewOrSearchContact: widget.backFromNewContact,
                      onSelect: widget.onSelect,
                    ),
                  ];

                  //NOTE: orientation changes -> size of banner changes -> scroll area changes
                  //-----
                  //the contact list itself SHOULD reload
                  //  - headerSlivers SHOULD update
                  //  - bodySliver SHOULD NOT update (they are created once and done)
                  //the scroll bar SHOULD reload and DOES
                  //BUT IF these TWO change it should only change the scrollbar
                  //  - sortedLetterCodes LIST
                  //  - letter2ItemCount MAP

                  //build
                  return Container(
                    color: Theme.of(context).primaryColor,
                    child: Stack(
                      children: <Widget>[
                        /*
                        ContactList(
                          autoScrollController: autoScrollController,
                          headerSlivers: headerSlivers,

                          retreivingContacts: widget.retreivingContacts,
                          contacts: widget.contacts,
                          colorsForContacts: widget.colorsForContacts,
                        ),
                        */
                        new ScrollBar(
                          autoScrollController: autoScrollController,
                          //we listen to their changes to determine if we should show the bar
                          retreivingContacts: widget.retreivingContacts,
                          contacts: widget.contacts,
                          //heights (change when orientation changes)
                          statusBarHeight: statusBarHeight,
                          bannerHeight: bannerHeight,
                          expandedBannerHeight: expandedBannerHeight,
                          //show widgets
                          sortedLetterCodes: new List<int>(), //widget.sortedLetterCodes,
                          letterToListItems: new Map<int, List<Widget>>(), //widget.letterToListItems,
                          //show/hide thumb tack
                          showThumbTack: showThumbTack,
                        ),
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
      ),
    );
  }
}

class Banner extends StatelessWidget {
  Banner({
    @required this.height,
    @required this.padding,
    @required this.prompt,
  });

  final double height;
  final double padding;
  final Widget prompt;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).primaryColorDark,
        height: height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(padding),
        child: prompt,
      ),
    );
  }
}

class ToolBar extends StatelessWidget {
  const ToolBar({
    Key key,
    @required this.toolBarHeight,
    @required this.orientationPrompt,
    @required this.backFromNewOrSearchContact,
    @required this.onSelect,
  }) : super(key: key);

  final double toolBarHeight;
  final Widget orientationPrompt;
  final ValueNotifier<bool> backFromNewOrSearchContact;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true, //avoid strange padding
      floating: true, //avoid strange padding
      expandedHeight: 0, //avoid strange padding
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
                          backFromNewOrSearchContact.value = true;
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
                          child: 
                          Hero(
                            flightShuttleBuilder: (
                              BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext,
                            ) {
                              Hero theHero;

                              Animation<double> newAnimation = 
                              Tween<double>(begin: 0, end: (1/8)).animate(animation);

                              if (flightDirection == HeroFlightDirection.pop) {
                                newAnimation = ReverseAnimation(newAnimation);
                                theHero = toHeroContext.widget;
                              }
                              else theHero = fromHeroContext.widget;

                              //animation goes from 0 to 1
                              return RotationTransition(
                                turns: newAnimation,
                                child: theHero,

                              );
                            },
                            tag: 'addToCancel',
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          backFromNewOrSearchContact.value = true;
                          Navigator.push(
                            context, PageTransition(
                              type: PageTransitionType.downToUp,
                              child: SearchContact(
                                onSelect: onSelect,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: toolBarHeight,
                          width: 16.0 + 24 + 16,
                          child: Hero(
                            tag: 'searchToBack',
                            child: Icon(Icons.search),
                          ),
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
            backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.5),
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