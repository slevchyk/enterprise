import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';

import '../models.dart';

class BodyChanel extends StatefulWidget {
  final Profile profile;

  BodyChanel(
    this.profile,
  );

  BodyChanelState createState() => BodyChanelState();
}

class BodyChanelState extends State<BodyChanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Канал'),
      ),
      drawer: AppDrawer(widget.profile),
      body: Container(
        color: Colors.purple,
        child: Center(
            child: Text(
          'Канал',
          style: TextStyle(fontSize: 50),
        )),
      ),
    );
  }
}
