import 'package:flutter/material.dart';

class PageOrders extends StatefulWidget {
  @override
  _PageOrdersState createState() => _PageOrdersState();
}

class _PageOrdersState extends State<PageOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          FlatButton(
            child: Text("Номенклатура"),
            onPressed: () {
              Navigator.of(context).pushNamed("/warehouse/goods/list");
            },
          )
        ],
      ),
    );
  }
}
