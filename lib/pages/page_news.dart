import 'package:flutter/material.dart';

class PageNews extends StatefulWidget {
  PageNewsState createState() => PageNewsState();
}

class PageNewsState extends State<PageNews> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: Container(
          child: Center(
              child: Text(
        'Новини',
        style: TextStyle(fontSize: 50),
      ))),
    );
  }
}
