import 'package:flutter/material.dart';
import 'dart:math' as math;

class SearchContact extends StatelessWidget {
  SearchContact({
    @required this.onSelect,
  });

  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          color: Theme.of(context).primaryColorDark,
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
                        child: TextFormField(
                          scrollPadding: EdgeInsets.all(0),
                          textInputAction: TextInputAction.search,
                          autofocus: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            border: InputBorder.none,
                          ),
                          initialValue: "init",
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'addToCancel',
                      child: Transform.rotate(
                        angle: - math.pi / 4,
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
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
                              "74 Found",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Container(
                        height: 750,
                        width: MediaQuery.of(context).size.width,
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