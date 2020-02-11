import 'dart:async';
import 'dart:ui';

import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class PageTurnstile extends StatefulWidget {
  @override
  _PageTurnstileState createState() => _PageTurnstileState();
}

class _PageTurnstileState extends State<PageTurnstile> {
  String _nfcTag = "";
  Stream<NfcData> _nfcStream = FlutterNfcReader.onTagDiscovered();
  NFCAvailability _nfcAvailability;

//  Stream<NDEFMessage> _stream = NFC.readNDEF();

  @override
  void initState() {
    super.initState();

    FlutterNfcReader.checkNFCAvailability().then((value) {
      setState(() {
        _nfcAvailability = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _nfcAvailability == NFCAvailability.available
        ? _page()
        : _nfcNotSupported();
  }

  Widget _nfcNotSupported() {
    return Center(
      child: Text('NFC doesn\'t supported'),
    );
  }

  Widget _page() {
    return Material(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.0),
            child: Image.asset('assets/nfc_scan.png'),
          ),
          StreamBuilder<NfcData>(
            stream: _nfcStream,
            builder: (context, snapshot) {
              if (snapshot != null && snapshot.hasData) {
                _nfcTag = snapshot.data.id.toString();
              }

              int dec = 0;

              if (_nfcTag.isNotEmpty) {
                dec = int.parse(_nfcTag);
              }

              return _turnstile(dec);
            },
          ),
        ],
      ),
    );
  }

  Widget _turnstile(int _nfcTag) {
    Profile _profile;

    ProfileDAO().getByInfoCard(_nfcTag).then((value) {
      if (value != null) {
        _profile = value;
      }
    });
    if (_profile == null) {
      return Center(
        child: Text('Користувача з карткою $_nfcTag не знайдено'),
      );
    }

    return Column(
      children: <Widget>[
        Container(child: _getUserpic(_profile)),
        Text(_profile.firstName + ' ' + _profile.lastName),
        SingleChildScrollView(
          child: Text('Інфокарта: $_nfcTag'),
        ),
        Row(
          children: <Widget>[
            RaisedButton(
              onPressed: () {},
              child: Text('Вхід'),
            ),
            RaisedButton(
              onPressed: () {},
              child: Text('Вихід'),
            ),
          ],
        )
      ],
    );
  }

  Widget _getUserpic(profile) {
    if (profile == null || profile.photo == '') {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        child: Text('фото'),
      );
    } else {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        backgroundImage: ExactAssetImage(profile.photo),
//        child: Image.asset(profile.photo),
      );
    }
  }
}
