import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'newContact.dart';
import 'dart:math' as math;

class SelectContactUX extends StatelessWidget {
  SelectContactUX({
    @required this.contactWidgets,
    @required this.backFromNewContact,
  });

  final List<Widget> contactWidgets;
  final ValueNotifier<bool> backFromNewContact;

  ValueNotifier<bool> showNewContact = new ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    TextStyle questionStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotification) {
              //do your logic
              if(scrollNotification is ScrollUpdateNotification){
                Offset change = scrollNotification.dragDetails?.delta;

                if(change != null){
                  //stop slow scrolling from making any changes
                  double absoluteChange = math.sqrt(math.pow(change.dy, 2));
                  if(absoluteChange > 2.5){
                    bool prev = showNewContact.value;
                    showNewContact.value = (change.dy > 0);
                    print(showNewContact.value.toString());
                  }
                }
              }

              return true;
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  //true so that we get the safe area added on top
                  primary: true,

                  //Pinned MUST be True for ease of use
                  pinned: true, //show the user then can search regardless of where they are on the list
                  //Floating MUST be true so for ease of use
                  floating: true, //show scroll bar as soon as user starts scrolling up
                  //Snap is TRUE so that our flexible space result looks as best as it can
                  snap: true,
                  
                  //Lets the user know what they are select a contact for
                  expandedHeight: MediaQuery.of(context).size.height / 2,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Container(
                      padding: EdgeInsets.fromLTRB(
                        0, 
                        //random height / 4 + 16 actual padding
                        (MediaQuery.of(context).size.height / 4) + 16, 
                        0, 
                        //random 16 + 16 actual padding
                        16 + 16.0, 
                      ),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Prompt The User\n",
                                style: questionStyle,
                              ),
                              TextSpan(
                                text: "For A Contact",
                                style: questionStyle,
                              )
                            ]
                          ),
                        ),
                      )
                    ),
                    centerTitle: true,
                    collapseMode: CollapseMode.none,
                  ),

                  //Lets the user know they can search
                  bottom: PreferredSize(
                    preferredSize: Size(
                      MediaQuery.of(context).size.width,
                      (20 + 16.0 + 4.0),
                    ),
                    child: Container(
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
                SliverList(
                  delegate: SliverChildListDelegate(
                    contactWidgets,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: showNewContact,
              builder: (context, child){
                return Opacity(
                  opacity: (showNewContact.value) ? 1 : 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: FloatingActionButton.extended(
                      onPressed: (){
                        backFromNewContact.value = true;
                        Navigator.push(
                          context, PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: NewContact(),
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
        ],
      ),
    );
  }
}