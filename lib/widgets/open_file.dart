import 'package:flutter/material.dart';
import 'dart:async';

import 'package:open_file/open_file.dart';

class OpenFileTest extends StatefulWidget {
  @override
  _OpenFileTestState createState() => new _OpenFileTestState();
}

class _OpenFileTestState extends State<OpenFileTest> {
  String _openResult = 'Unknown';

  Future<void> openFile() async {

//    final filePath = '/storage/emulated/0/update.apk';
    final filePath = '/sdcard/Download/HTML a download Attribute.html';
//    final filePath = '/sdcard/Download/sample.pdf';
    final result = await OpenFile.open(filePath);

    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('open result: $_openResult\n'),
            FlatButton(
              child: Text('Tap to open file'),
              onPressed: openFile,
            ),
          ],
        ),
      ),
    );
  }
}