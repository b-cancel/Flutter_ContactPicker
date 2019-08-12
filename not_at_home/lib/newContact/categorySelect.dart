import 'package:flutter/material.dart';

enum LabelType {phone, email, address}
enum Boolean { TRUE, FALSE }

class CategorySelectionPage extends StatelessWidget {
  CategorySelectionPage({
    @required this.labelType,
  });

  final LabelType labelType;
  Boolean boolean = Boolean.TRUE;

  @override
  Widget build(BuildContext context) {
    String theType = "";
    switch(labelType){
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