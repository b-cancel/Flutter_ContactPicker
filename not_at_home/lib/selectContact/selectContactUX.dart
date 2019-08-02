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

  final ValueNotifier<bool> showNewContact = new ValueNotifier(true);
  final ValueNotifier<double> flexibleHeight = new ValueNotifier(0);

  final AutoScrollController autoScrollController = new AutoScrollController();

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
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollNotification) {
                    //do your logic
                    if(scrollNotification is ScrollUpdateNotification){
                      Offset change = scrollNotification.dragDetails?.delta;
                      //if a change actually occured
                      if(change != null){
                        //stop slow scrolling from making any changes
                        double absoluteChange = math.sqrt(math.pow(change.dy, 2));
                        if(absoluteChange > 2.5){
                          //show one thing or the other given our scroll direction
                          showNewContact.value = (change.dy > 0);
                        }
                      }
                    }
                    //return true since this function requires it
                    return true;
                  },
                  child: Container(
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
                                  padding: EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width,
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text("Select Contact"),
                                        Icon(Icons.search)
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
                  ),
                );
              },
            ),

            //Let the user know they can add a new contact
            Positioned(
              bottom: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: showNewContact,
                builder: (context, child){
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    transform: Matrix4.translation(
                      VECT.Vector3(
                        0, 
                        (showNewContact.value) ? 0.0 : (16.0 + 48), 
                        0,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: FloatingActionButton.extended(
                        onPressed: (){
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
                        icon: Icon(Icons.add),
                        label: Text("Create Contact"),
                      ),
                    ),
                  );
                },
              ),
            ),

            //scroll to top button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  onPressed: (){
                    print("pressed");
                    autoScrollController.scrollToIndex(
                      0, 
                      preferPosition: AutoScrollPosition.begin,
                      duration: Duration(milliseconds: 1),
                    );
                  },
                  child: Icon(Icons.laptop),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}