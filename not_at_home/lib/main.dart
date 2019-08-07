import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

//-----Start App
void main() => runApp(MyApp());

//-----Entry Point
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatelessLink();
  }
}

//-----Statless Link Required Between Entry Point And App
class StatelessLink extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nested Picker Link',
      home: Test(),
    );
  }
}

//-----Test Widget
class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    double toolBarSize = 50;

    Widget toolBar = Container(
      width: MediaQuery.of(context).size.width,
      height: toolBarSize,
      color: Colors.blue,
      child: Text("tool bar"),
    );

    Widget banner = Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      color: Colors.orange,
      child: Text("banner"),
    );

    Widget aSection = SliverStickyHeader(
      header: Container(
        color: Colors.pink,
        width: MediaQuery.of(context).size.width,
        height: 35,
        child: Text("section"),
      ),
      sliver: new SliverList(
        delegate: new SliverChildListDelegate([
          Container(
            color: Colors.yellow,
            width: MediaQuery.of(context).size.width,
            height: 500,
          ),
        ]),
      ),
    );

    List<Widget> sections = new List<Widget>();
    sections.add(aSection);
    sections.add(aSection);
    sections.add(aSection);

    sections = new List.from([
      SliverToBoxAdapter(
        child: banner,
      ),
      SliverAppBar(
        pinned: true, //avoid strange padding
        floating: true, //avoid strange padding
        expandedHeight: 0, //avoid strange padding
        bottom: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            toolBarSize,
          ),
          child: toolBar,
        ),
      ),
    ])..addAll(sections);

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: CustomScrollView(
          slivers: sections,
        ),
      ),
    );
  }
}

/*import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:not_at_home/request.dart';
import 'selectContact/selectContactLogic.dart';
import 'package:not_at_home/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'helper.dart';

//IF true -> first forces you to select a contact and then lets you change it
//ELSE -> takes you directly into testing the toolkit in all other cases
bool testFirstPage = true;

//-----Start App
void main() => runApp(MyApp());

//-----Entry Point
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      //by default start off in dark mode
      builder: (_) => ThemeChanger(ThemeData.dark()),
      child: StatelessLink(),
    );
  }
}

//-----Statless Link Required Between Entry Point And App
class StatelessLink extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    getThemeColors(Theme.of(context));
    return MaterialApp(
      routes: {
        ContactDisplayHelper.routeName: (context) => ContactDisplayHelper(),
      },   
      title: 'Contact Picker',
      theme: theme.getTheme(),
      home: InitRouter(),
    );
  }
}

//-----Router to select contact or the page that will select them for testing purposes
//NOTE: if anyone reading this can find a cleaner way to do this that would be great
//I did it this way because I need to be able to push the ContactDisplay page with its name
//otherwise when I select a contact ill pop everything since the onSelect function in SelectContact
//is also expecting the route name of the page requesting the contact
class InitRouter extends StatefulWidget {
  InitRouter({Key key}) : super(key: key);

  _InitRouterState createState() => _InitRouterState();
}

class _InitRouterState extends State<InitRouter> {
  @override
  void initState() {
    //after build completes
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(testFirstPage){
        //we start the app by making the user select a contact
        Navigator.pushReplacement(
          context, 
          PageTransition(
            type: PageTransitionType.fade,
            duration: Duration(seconds: 0),
            //since this is how the app starts the user MUST select a contact
            child: SelectContact(
              userPrompt: ["Prompt The User", "For A Contact"],
              selectContactBackUp: SelectContactBackUp.systemContactPicker,
              routeName: ContactDisplayHelper.routeName,
              forceSelection: true,
            ),
          ),
        );
      }
      else{
        Navigator.pushNamedAndRemoveUntil(
          context, 
          ContactDisplayHelper.routeName,
          (r) => false,
          arguments: ContactDisplayArgs(
            new Contact(),
          ),
        );
      }
    });
    
    //super init state
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
*/