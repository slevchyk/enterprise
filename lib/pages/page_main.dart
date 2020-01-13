import 'package:flutter/material.dart';
import 'package:enterprise/main.dart';

class PageMain extends StatefulWidget {
  PageMainState createState() => PageMainState();
}

class PageMainState extends State<PageMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: ,
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.purple,
            child: Container(
                child: Center(
                    child: Text(
              'Головна',
              style: TextStyle(fontSize: 50),
            ))),
          )
        ],
      ),
      bottomNavigationBar: MainBottomNavigationBar("/"),
    );
  }
}
