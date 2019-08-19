import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

ThemeData ourDark = ThemeData.dark();
ThemeData ourLight = ThemeData.light();

/*
//set changes on theme
//Color.fromRGBO(255, 255, 255, 1); //O always set to 1
//Color.fromARGB(255, 255, 255, 255); //A always set to 255
//Color(0xAARRGGBB) //with a hex code //AA is always FF

//setup for light theme
ourLight = ThemeData.light().copyWith(
  primaryColor: Colors.blue,
);
*/

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
                _themeChanger.setTheme(ourLight);
              }
            },
            title: const Text('Light'),
          ),
          RadioListTile<Brightness>(
            value: Brightness.dark,
            groupValue: Theme.of(context).brightness,
            onChanged: (Brightness value) {
              if(value == Brightness.dark){
                _themeChanger.setTheme(ourDark);
              }
            },
            title: const Text('Spooky  👻'),
          ),
        ],
      );
    },
  );
}