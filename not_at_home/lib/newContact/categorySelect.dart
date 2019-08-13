import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:async';

enum LabelType {phone, email, address}
enum Boolean { TRUE, FALSE }

class CategorySelectionPage extends StatefulWidget {
  CategorySelectionPage({
    @required this.labelType,
  });

  final LabelType labelType;

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final List<String> labels = new List<String>();
  
  @override
  void initState() {
    //async init
    init();

    //super init
    super.initState();
  }

  readFile(File reference) async{
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String fileString = await reference.readAsString();
    Map jsonMap = json.decode(fileString);
    //NOTE: encoder.convert(jsonMap) here should work
    //BUT because of some caching issue with the function it cuts off
    //making it never cut off is going to be difficult
    //but I could split the map into 6 parts and print that
    var keys = jsonMap.keys.toList();
    for(int i = 0; i < keys.length; i++){
      var key = keys[i];
      print(key + ": " + encoder.convert(jsonMap[key]));
    }
  }

  init() async{
    //calculate all basic params
    String fileName = widget.labelType.toString();
    String localPath = (await getApplicationDocumentsDirectory()).path;
    String filePath = '$localPath/$fileName';

    //create a reference to the file
    bool fileExists = (FileSystemEntity.typeSync(filePath) != FileSystemEntityType.notFound);
    File fileReference = File(filePath);

    //If needed create the file
    if(fileExists == false){
      //create the file
      fileReference.create();

      //fill it with defaults
      String defaultString;
      switch(widget.labelType){
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
      await fileReference.writeAsString(defaultString);
    }

    //Use the file data to populate a list
    readFile(fileReference);
  }

  @override
  Widget build(BuildContext context) {
    String theType = "";
    switch(widget.labelType){
      case LabelType.phone: 
      theType = "phone number"; break;
      case LabelType.email: 
      theType = "email address"; break;
      default: theType = "address"; break;
    }

    List<Widget> items = [
      new Item(
        selected: true,
        label: "Mobile",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false,
        label: "Home",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false,
        label: "Work",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false,
        label: "Main",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false,
        label: "Work Fax",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false,
        label: "Home Fax",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false, 
        label: "Pager",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        selected: false,
        label: "Other",
        onTap: (){
          Navigator.pop(context);
        },
      ),
      new Item(
        label: "Create custom type",
        onTap: (){
          Navigator.pop(context);
        },
      ),
    ];

    for(int i = 0; i < items.length; i++){
      
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          "Select " + theType + " type", 
        ),
      ),
      body: Card(
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
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