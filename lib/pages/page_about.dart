import 'package:enterprise/main.dart';
import 'package:flutter/material.dart';

class PageAbout extends StatefulWidget {
  PageAboutState createState() => PageAboutState();
}

class PageAboutState extends State<PageAbout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Text('INTELLECT-CASE'),
      ),
    ));
  }
}
