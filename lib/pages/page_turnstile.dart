import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class PageTurnstile extends StatefulWidget {
  @override
  _PageTurnstileState createState() => _PageTurnstileState();
}

class _PageTurnstileState extends State<PageTurnstile> {
  bool _supportsNFC = false;
  Stream<NDEFMessage> _stream = NFC.readNDEF(once: false);
  String _nfcTag = "";

  @override
  void initState() {
    super.initState();
    // Check if the device supports NFC reading
    NFC.isNDEFSupported.then((bool isSupported) {
      setState(() {
        _supportsNFC = isSupported;
      });

      if (isSupported) {
        _stream.listen((NDEFMessage message) {
          setState(() {
            _nfcTag = message.data;
          });
          print("records: ${message.records.length}");
        });
      }
    });
  }
//  bool _supportsNFC = false;
//  bool _reading = false;
//  StreamSubscription<NDEFMessage> _stream;
//
//  @override
//  void initState() {
//    super.initState();
//    // Check if the device supports NFC reading
//    NFC.isNDEFSupported.then((bool isSupported) {
//      setState(() {
//        _supportsNFC = isSupported;
//      });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return _supportsNFC ? _page() : _nfcNotSupported();
//    if (!_supportsNFC) {
//      return RaisedButton(
//        child: const Text("You device does not support NFC"),
//        onPressed: null,
//      );
//    }
//
//    return RaisedButton(
//        child: Text(_reading ? "Stop reading" : "Start reading"),
//        onPressed: () {
//          if (_reading) {
//            _stream?.cancel();
//            setState(() {
//              _reading = false;
//            });
//          } else {
//            setState(() {
//              _reading = true;
//              // Start reading using NFC.readNDEF()
//              _stream = NFC
//                  .readNDEF(
//                once: true,
//                throwOnUserCancel: false,
//              )
//                  .listen((NDEFMessage message) {
//                print("read NDEF message: ${message.payload}");
//              }, onError: (e) {
//                // Check error handling guide below
//              });
//            });
//          }
//        });
  }

  Widget _nfcNotSupported() {
    return Center(
      child: Text('NFC doesn\'t supported'),
    );
  }

  Widget _page() {
    return Container(
      child: Text('NFC tag: $_nfcTag'),
    );
  }
}
