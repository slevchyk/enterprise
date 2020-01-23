import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PagePayDesk extends StatefulWidget {
  @override
  _PagePayDeskState createState() => _PagePayDeskState();
}

class _PagePayDeskState extends State<PagePayDesk> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          "Каса",
          style: TextStyle(fontSize: 25.0),
        ),
      ),
    );
  }
}
