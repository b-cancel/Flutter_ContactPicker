/*
class _ScrollToTopBottomListViewState extends State<ScrollToTopBottomListView> {
  ScrollController _scrollController;
  bool _isOnTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _scrollToTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
    setState(() => _isOnTop = true);
  }

  _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 1000), curve: Curves.easeOut);
    setState(() => _isOnTop = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scroll to Top / Bottom Example'),
        ),
        body: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(10.0),
          children: _listViewData
              .map((data) => ListTile(
                    leading: Icon(Icons.person),
                    title: Text(data),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isOnTop ? _scrollToBottom : _scrollToTop,
          child: Icon(_isOnTop ? Icons.arrow_downward : Icons.arrow_upward),
        ));
  }
}
*/

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:vector_math/vector_math_64.dart' as VECT;
import 'dart:math' as math;
import 'package:not_at_home/newContact.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

class SelectContactUX extends StatelessWidget {
  SelectContactUX({
    this.retreivingContacts: false,
    @required this.sortedKeys,
    @required this.sectionWidgets,
    @required this.backFromNewContact,
    @required this.onSelect,
    @required this.userPrompt,
  });

  final bool retreivingContacts;
  final List<int> sortedKeys;
  final List<Widget> sectionWidgets;
  final ValueNotifier<bool> backFromNewContact;
  final Function onSelect;
  final List<String> userPrompt;

  final ValueNotifier<double> flexibleHeight = new ValueNotifier(0);
  final ValueNotifier<bool> flexibleClosed = new ValueNotifier(false);

  final AutoScrollController autoScrollController = new AutoScrollController();

  //on load we start on top
  final ValueNotifier<bool> isOnTop = new ValueNotifier(true);

  scrollToTop() async{
    await autoScrollController.animateTo(
      autoScrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 200), 
      curve: Curves.ease,
      //curve: Curves.easeIn,
    );

    //we scrolled to top so we are on top
    isOnTop.value = true;
  }

  scrollToBottom() async{
    await autoScrollController.animateTo(
      autoScrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
      //curve: Curves.easeOut,
    );

    //we scroll to bottom so we are not on top
    isOnTop.value = false;
  }

  @override
  Widget build(BuildContext context) {
    //add the autoscroll stuff to section widgets
    for(int i = 0; i < sectionWidgets.length; i++){
      Widget section = sectionWidgets[i];

      sectionWidgets[i] = AutoScrollTag(
        key: ValueKey(i),
        controller: autoScrollController,
        index: i,
        child: section,
        highlightColor: Colors.red,
      );
    }

    //Styling of the User Question Prompt
    TextStyle questionStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );

    //Generate the Widget shown in the contacts scroll area
    //Depending on whether or not there are contacts or they are being retreived
    Widget bodyWidget;
    if(retreivingContacts || sectionWidgets.length == 0){
      bodyWidget = SliverFillRemaining(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Text(
            (retreivingContacts) ? "Retreiving Contacts" : "No Contacts Found",
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
          sectionWidgets,
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
                  for(int i = 0; i < userPrompt.length; i++){
                    //add a spacer before each textspan that is not the first
                    if(i != 0){
                      textSpans.add(
                        TextSpan(text: "\n"),
                      );
                    }

                    //add the actual textSpan
                    textSpans.add(
                      TextSpan(
                        text: userPrompt[i],
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
                  for(int i = 0; i < userPrompt.length; i++){
                    if(i == 0) generateString += userPrompt[i];
                    else generateString += (" " + userPrompt[i]);
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
                                      Container(
                                        alignment: Alignment.center,
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
                          padding: EdgeInsets.only(
                            top: 24.0 + 16 + 24 + 16,
                            bottom: 16 + 32.0 + 16,
                          ),
                          child: Container(
                            color: Colors.red,
                            padding: EdgeInsets.all(16),
                            child: Container(
                              color: Colors.blue,
                              width: 24,
                            ),
                          ),
                        ),
                        builder: (BuildContext context, Widget child) {
                          return Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: MediaQuery.of(context).size.height - flexibleHeight.value,
                              child: child,
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
                  animation: flexibleClosed,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: scrollToTop,
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
                          (showNewContact.value) ? (16.0 + 48) : 0.0, 
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