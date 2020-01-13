import 'package:enterprise/main.dart';
import 'package:flutter/material.dart';

class PageChanel extends StatefulWidget {
  PageChanelState createState() => PageChanelState();
}

class PageChanelState extends State<PageChanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.purple,
        child: Container(
            child: Center(
                child: Text(
          'Канал',
          style: TextStyle(fontSize: 50),
        ))),
      ),
      bottomNavigationBar: MainBottomNavigationBar("/chanel"),
    );
  }
}
