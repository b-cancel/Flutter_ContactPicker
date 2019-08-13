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

void customTypePopUp(
  BuildContext context,
  bool create, 
  ValueNotifier<String> labelString,
  ){
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))
        ),
        title: new Text(
          ((create) ? "Create" : "Rename") + " custom type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        contentPadding: EdgeInsets.only(
          left: 24,
          right: 24
        ),
        content: new AlertContent(
          labelString: labelString,
          //rename set labelString value on init
          create: create,
        ),
      );
    },
  );
}

class CategorySelectionPage extends StatelessWidget {
  CategorySelectionPage({
    @required this.labelType,
    @required this.labelString,
    @required this.create,
  });

  final LabelType labelType;
  final ValueNotifier<String> labelString;
  final bool create;

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

    //check if the label we passed is contained within the defaults
    bool hadDefault = items.contains(labelString.value);
    int theIndexSelected = 0;
    Widget bottomContent;
    if(hadDefault){
      bottomContent = AnItem(
        label: "Create custom type",
        labelString: labelString,
      );

      //determine which default is selected
      theIndexSelected = items.indexOf(labelString.value);
    }
    else{
      bottomContent = AnItem(
        label: labelString.value,
        labelString: labelString,
        selected: true,
        showEdit: true,
      );
    }

    //build the widgets
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
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index){
                //mark the selected index as selected
                bool markSelected;
                if(hadDefault == false) markSelected = false;
                else{
                  markSelected = (index == theIndexSelected) ? true : false;
                }

                //build
                return AnItem(
                  selected: markSelected,
                  label: items[index],
                  labelString: labelString,
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
            child: bottomContent,
          )
        ],
      ),
    );
  }
}

class AlertContent extends StatefulWidget {
  const AlertContent({
    Key key,
    @required this.labelString,
    @required this.create,
  }) : super(key: key);

  final ValueNotifier<String> labelString;
  final bool create;

  @override
  _AlertContentState createState() => _AlertContentState();
}

class _AlertContentState extends State<AlertContent> {
  TextEditingController customType = new TextEditingController();
  bool canCreate = false;

  @override
  void initState() {
    if(widget.create == false){
      customType.text = widget.labelString.value;
    }

    //enable the create button when possible
    customType.addListener((){
      canCreate = (customType.text.length != 0);
      setState(() {
        
      });
    });

    //super init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: customType,
            textInputAction: TextInputAction.done,
          ),
          Row(
            children: <Widget>[
              new PopUpButton(
                onTapped: (){
                  Navigator.pop(context);
                }, 
                text: "Cancel",
              ),
              Center(
                child: Container(
                  width: 2,
                  height: 26,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              new PopUpButton(
                onTapped: canCreate ? (){
                  //save string
                  widget.labelString.value = customType.text;
                  //pop the pop up
                  Navigator.pop(context);
                  //pop the select type window
                  Navigator.pop(context);
                }
                : null, 
                text: "Create",
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PopUpButton extends StatelessWidget {
  const PopUpButton({
    Key key,
    @required this.onTapped,
    @required this.text,
  }) : super(key: key);

  final Function onTapped;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapped,
          child: Container(
            padding: EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColorLight.withOpacity(
                  (onTapped == null) ? 0.5 : 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnItem extends StatelessWidget {
  const AnItem({
    @required this.label,
    @required this.labelString,
    this.selected,
    this.showEdit: false,
  });

  
  final String label;
  final ValueNotifier<String> labelString;
  final bool selected;
  final bool showEdit;

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
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: (){
                if(selected == null){ //create pop up
                  customTypePopUp(
                    context,
                    true,
                    labelString,
                  );
                }
                else{ //select item
                  labelString.value = label;
                  Navigator.pop(context);
                }
              },
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          showEdit ? InkWell(
            onTap: (){
              customTypePopUp(
                context,
                false,
                labelString,
              );
            },
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
          : Container(),
        ],
      ),
    );
  }
}