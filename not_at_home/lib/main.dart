import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//-----Theme Changer Code
class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData);

  ThemeData getTheme() => _themeData;
  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }
}

//-----Theme Changer Widget
void showThemeSwitcher(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
      return SimpleDialog(
        title: const Text('Select Theme'),
        children: <Widget>[
          RadioListTile<Brightness>(
            value: Brightness.light,
            groupValue: Theme.of(context).brightness,
            onChanged: (Brightness value) {
              if(value == Brightness.light){
                _themeChanger.setTheme(ThemeData.light());
              }
            },
            title: const Text('Light'),
          ),
          RadioListTile<Brightness>(
            value: Brightness.dark,
            groupValue: Theme.of(context).brightness,
            onChanged: (Brightness value) {
              if(value == Brightness.dark){
                _themeChanger.setTheme(ThemeData.dark());
              }
            },
            title: const Text('Spooky  👻'),
          ),
        ],
      );
    },
  );
}

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
class StatelessLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      title: 'Contact Picker',
      theme: theme.getTheme(),
      home: PageRequestingContact(),
    );
  }
}

//-----First Page
class PageRequestingContact extends StatefulWidget {
  @override
  _PageRequestingContactState createState() => _PageRequestingContactState();
}

class _PageRequestingContactState extends State<PageRequestingContact> {
  bool isSwitched = true;
  bool forceContactChange = true;

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Requesting Contact"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Click Below To \n\"Select\" or \"Change\" \nthe Contact",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(bottom: 16),
                child: FlatButton(
                  color: Theme.of(context).highlightColor,
                  onPressed: (){
                    print("Select New Contact");
                  },
                  child: Text(
                    "Select New Contact",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        if(value){
                            _themeChanger.setTheme(ThemeData.dark());
                          }
                          else{
                            _themeChanger.setTheme(ThemeData.light());
                          }
                          isSwitched = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      (isSwitched) ?
                      "Dark Mode"
                      : "Light Mode",
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Switch(
                    value: forceContactChange,
                    onChanged: (value) {
                      setState(() {
                        forceContactChange = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      (forceContactChange) ?
                      "Force Change"
                      : "Don't Force Chance",
                    ),
                  ),
                ],
              ),
              FlatButton(
                onPressed: (){
                  showThemeSwitcher(context);
                },
                child: Text("pop up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}