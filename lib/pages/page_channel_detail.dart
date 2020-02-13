import 'package:enterprise/models/channel.dart';
import 'package:flutter/material.dart';

class PageChanelDetail extends StatefulWidget {
  final Channel channel;

  PageChanelDetail({
    this.channel,
  });

  @override
  _PageChanelDetailState createState() => _PageChanelDetailState();
}

class _PageChanelDetailState extends State<PageChanelDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(14),
          child: Text(widget.channel.news, style: TextStyle(fontSize: 19)),
        ),
      ),
    );
  }
}
