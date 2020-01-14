import 'package:enterprise/main.dart';
import 'package:flutter/material.dart';

class BodyMain extends StatefulWidget {
  BodyMainState createState() => BodyMainState();
}

class BodyMainState extends State<BodyMain> {
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
