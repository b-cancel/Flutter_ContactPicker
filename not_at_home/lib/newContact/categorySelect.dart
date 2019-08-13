import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:async';

enum LabelType {phone, email, address}
enum Boolean { TRUE, FALSE }

class CategoryData{
  static List<String> phoneLabels = new List<String>();
  static List<String> emailLabels = new List<String>();
  static List<String> addressLabels = new List<String>();

  static init(){
    listInit(LabelType.phone);
    listInit(LabelType.email);
    listInit(LabelType.address);
  }

  static listInit(LabelType labelType) async{
    //calculate all basic params
    String fileName = labelType.toString();
    String localPath = (await getApplicationDocumentsDirectory()).path;
    String filePath = '$localPath/$fileName';
    File fileReference = File(filePath);

    //If needed create the file
    bool fileExists = (FileSystemEntity.typeSync(filePath) != FileSystemEntityType.notFound);
    if(fileExists == false) await createDefault(labelType, fileReference);

    //Use the file data to populate a list
    readFile(labelType, fileReference);
  }

  static createDefault(LabelType labelType, File reference) async{
    //create the file
    reference.create();

    //fill it with defaults
    String defaultString;
    switch(labelType){
      case LabelType.phone:
        defaultString = '["Mobile", "Home", "Work", "Main", "Work Fax", "Home Fax", "Pager", "Other"]';
        break;
      case LabelType.email:
        defaultString = '["Home", "Work", "Other"]';
        break;
      default:
        defaultString = '["Home", "Work", "Other"]'; 
        break;
    }
    defaultString = '{ "types": ' + defaultString + ' }';

    //write to file
    await reference.writeAsString(defaultString);
  }

  static readFile(LabelType labelType, File reference) async{
    String fileString = await reference.readAsString();
    Map jsonMap = json.decode(fileString);
    List<String> list = new List<String>.from(jsonMap[jsonMap.keys.toList()[0]]);
    switch(labelType){
      case LabelType.phone: phoneLabels = list; break;
      case LabelType.email: emailLabels = list; break;
      default: addressLabels = list; break;
    }
  }
}

class CategorySelectionPage extends StatelessWidget {
  CategorySelectionPage({
    @required this.labelType,
  });

  final LabelType labelType;
  final GlobalKey<AnimatedListState> listKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    //create the title AND retreive the list
    String theType = "";
    List<String> items;
    switch(labelType){
      case LabelType.phone: 
        theType = "phone number"; 
        items = CategoryData.phoneLabels;
        break;
      case LabelType.email: 
        theType = "email address"; 
        items = CategoryData.emailLabels;
        break;
      default: 
        theType = "address"; 
        items = CategoryData.addressLabels;
        break;
    }

    //create the widgets
    List<Widget> widgets = new List<Widget>();
    for(int i = 0; i < items.length; i++){
      widgets.add(
        new Item(
          selected: (i == 0) ? true : false,
          label: items[i],
          onTap: (){
            Navigator.pop(context);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          "Select " + theType + " type", 
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: new BorderRadius.only(
                topLeft: Radius.circular(32.0),
                topRight: Radius.circular(32.0),
              ),
            ),
            child: ListView.builder(
              key: listKey,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index){
                return Item(
                  selected: (index == 0) ? true : false,
                  label: items[index],
                  onTap: (){
                    Navigator.pop(context);
                  },
                );
              },
              itemCount: items.length,
            ),
          ),
          Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(32.0),
                bottomRight: Radius.circular(32.0),
              ),
            ),
            child: Item(
              label: "Create custom type",
              onTap: (){
                print("adding custom type");
              },
            ),
          )
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({
    @required this.label,
    @required this.onTap,
    this.selected,
  });

  
  final String label;
  final Function onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    Widget leading;
    if(selected != null){
      leading = IgnorePointer(
        child: Radio(
          value: Boolean.TRUE,
          groupValue: selected ? Boolean.TRUE : Boolean.FALSE,
          onChanged: (var value) {

          },
        ),
      );
    }
    else{
      leading = Icon(
        Icons.add,
        color: Colors.green,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: leading,
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}