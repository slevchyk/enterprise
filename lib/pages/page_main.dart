import 'package:flutter/material.dart';

class PageMain extends StatefulWidget {
  PageMainState createState() => PageMainState();
}

class PageMainState extends State<PageMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Container(
          child: Center(
              child: Text(
        'Головна',
        style: TextStyle(fontSize: 50),
      ))),
    );
  }
}
