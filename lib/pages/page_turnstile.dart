import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageTurnstile extends StatefulWidget {
  @override
  _PageTurnstileState createState() => _PageTurnstileState();
}

class _PageTurnstileState extends State<PageTurnstile> {
  String _nfcTag = "";
  Stream<NfcData> _nfcStream = FlutterNfcReader.onTagDiscovered();
  NFCAvailability _nfcAvailability;
  Profile _profile;

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
          _nfcTag == ""
              ? Container(
                  height: _nfcTag == "" ? 200.0 : 0.0,
                  padding: EdgeInsets.all(15.0),
                  child: Image.asset('assets/nfc_scan.png'),
                )
              : SizedBox(),
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

              _getProfileByInfoCard(dec);

              return _turnstile();
            },
          ),
        ],
      ),
    );
  }

  _getProfileByInfoCard(int infoCard) async {
    Profile _pfl = await ProfileDAO().getByInfoCard(infoCard);
    setState(() {
      _profile = _pfl;
    });
  }

  Future _autoLogout() async {
    return new Future.delayed(const Duration(seconds: 10), () {
      if (_profile != null) {
        setState(() {
          _nfcTag = "";
          _profile = null;
        });
      }
    });
  }

  Widget _turnstile() {
    if (_nfcTag == "") {
      return Column(
        children: <Widget>[
          Icon(
            Icons.keyboard_arrow_up,
            size: 100.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'ПРИКЛАДІТЬ ВАШУ КАРТКУ ТУТ',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (_profile == null) {
      return Center(
        child: Text('Користувача з карткою $_nfcTag не знайдено'),
      );
    }

//    _autoLogout();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(child: _getUserpic(_profile)),
        Text(_profile.firstName + ' ' + _profile.lastName),
        SingleChildScrollView(
          child: Text('Інфокарта: $_nfcTag'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              onPressed: () {},
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.doorOpen,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('Вхід'),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {},
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.doorClosed,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('Вихід'),
                ],
              ),
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
      );
    }
  }
}
