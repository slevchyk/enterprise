import 'package:enterprise/main.dart';
import 'package:flutter/material.dart';

class BodyChanel extends StatefulWidget {
  BodyChanelState createState() => BodyChanelState();
}

class BodyChanelState extends State<BodyChanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: Container(
          child: Center(
              child: Text(
        'Канал',
        style: TextStyle(fontSize: 50),
      ))),
    );
  }
}
