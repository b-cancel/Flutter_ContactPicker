import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:diacritic/diacritic.dart';

class SearchContact extends StatefulWidget {
  SearchContact({
    @required this.nameToTiles,
  });

  final ValueNotifier<Map<String, List<Widget>>> nameToTiles;

  @override
  _SearchContactState createState() => _SearchContactState();
}

class _SearchContactState extends State<SearchContact> {
  List<Widget> queryResults = new List<Widget>();
  TextEditingController search = new TextEditingController();

  @override
  void initState() {
    search.addListener((){
      query(search.text);
    });

    super.initState();
  }

  query(String searchString) async{
    //make the search string easier to work with
    searchString = removeDiacritics(searchString).toLowerCase().trim();

    //clear the previous query results
    queryResults.clear();

    print("DIFFERENT: " + widget.nameToTiles.value.keys.toList().length.toString());

    //find matching results
    if(searchString.length > 0){
      List<String> keys = widget.nameToTiles.value.keys.toList();
      print("-------------------------Key Count: " + keys.length.toString() + "-------------------------");
      for(int key = 0; key < keys.length; key++){
        String name = keys[key]; //NOTE: already with no diacritics, lowercase, and trimed
        //print("--------------------b4");
        //name = removeDiacritics(name).toLowerCase().trim();
        print(key.toString());
        //If our search String is contained within the name then add all of the match widgets
        //print("--------------------" + name);
        if(name.contains(searchString)){
          List<Widget> allItemsWithKey = widget.nameToTiles.value[name];
          for(int item = 0; item < allItemsWithKey.length; item++){
            queryResults.add(allItemsWithKey[item]);
          }
        }
      }
      print("-------------------------Key Count: " + keys.length.toString() + "-------------------------");
    }

    //show the query results
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          color: Theme.of(context).primaryColorDark,
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  color: Theme.of(context).primaryColor,
                ),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Hero(
                          tag: 'searchToBack',
                          child: Icon(Icons.keyboard_arrow_left),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: TextField(
                          scrollPadding: EdgeInsets.all(0),
                          textInputAction: TextInputAction.search,
                          controller: search,
                          autofocus: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'addToCancel',
                      child: Transform.rotate(
                        angle: - math.pi / 4,
                        child: GestureDetector(
                          onTap: (){
                            search.text = "";
                          },
                          child: Icon(Icons.add)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Theme.of(context).primaryColorDark,
                padding: EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Contacts",
                      ),
                      Text(
                        queryResults.length.toString() + " Found",
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Column(
                        children: queryResults,
                      )
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*
Card(
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: widgetsWithDividers,
                ),
              ),
*/