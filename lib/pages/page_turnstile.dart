import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/timing.dart';
import 'package:enterprise/utils.dart';
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

    FlutterNfcReader.onTagDiscovered().listen((NfcData _nfcData) {
      _getProfileByInfoCard(_nfcData.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _pageTurnstile();
  }

  Widget _pageTurnstile() {
    if (_nfcAvailability == NFCAvailability.available) {
      if (_nfcTag == "") {
        return _pageNfcScan();
      } else {
        return _pageNfcProfile();
      }
    } else {
      return _pageNfcNotSupported();
    }
  }

  Widget _pageNfcNotSupported() {
    return Material(
      child: Center(
        child: Text('NFC doesn\'t supported'),
      ),
    );
  }

  Widget _pageNfcScan() {
    return Material(
      child: Column(
        children: <Widget>[
          Container(
            height: 200.0,
            padding: EdgeInsets.all(15.0),
            child: Image.asset('assets/nfc_scan.png'),
          ),
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
      ),
    );
  }

  Widget _pageNfcProfile() {
    DateTime _beginingDay = Utility.beginningOfDay(DateTime.now());

//    List<Timing> TimingDAO().getTurnstileByDateUserId(date, userID)

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30.0),
            child: _getUserpic(_profile),
          ),
          Text(
            _profile.firstName + ' ' + _profile.lastName,
            style: TextStyle(
              fontSize: 34.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SingleChildScrollView(
            child: Text('Інфокарта: $_nfcTag'),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          _nfcTag = "";
                          _profile = null;
                        });
                      },
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
                      onPressed: () {
                        setState(() {
                          _nfcTag = "";
                          _profile = null;
                        });
                      },
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getProfileByInfoCard(String _tag) async {
    int infoCard = int.parse(_tag);

    Profile _pfl = await ProfileDAO().getByInfoCard(infoCard);
    setState(() {
      _nfcTag = _tag;
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
