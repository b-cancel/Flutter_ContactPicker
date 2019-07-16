import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Using Contact"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text(
            "App Using The Contact",
            style: TextStyle(
              fontSize: 32,
            ),
          ),
        ),
      ),
    );
  }
}