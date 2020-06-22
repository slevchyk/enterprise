import 'dart:async';
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/timing.dart';
import 'package:enterprise/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageTurnstile extends StatefulWidget {
  @override
  _PageTurnstileState createState() => _PageTurnstileState();
}

class _PageTurnstileState extends State<PageTurnstile> {
  NFCAvailability _nfcAvailability;
  String _nfcTag = "";
  Profile _profile;
  List<Timing> _timingTurnstile = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([]);

    FlutterNfcReader.checkNFCAvailability().then((value) {
      setState(() {
        _nfcAvailability = value;
      });
    });

    FlutterNfcReader.onTagDiscovered().listen((NfcData _nfcData) {
      _getDataByInfoCard(_nfcData.id);
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
    } else if(_nfcAvailability == NFCAvailability.disabled) {
      return _pageNfcDisabled();
    } else {
      return _pageNfcNotSupported();
    }
  }

  Widget _pageNfcDisabled() {
    return Material(
      child: Center(
        child: Text('На Вашому телефонi вимкнено NFC'),
      ),
    );
  }

  Widget _pageNfcNotSupported() {
    return Material(
      child: Center(
        child: Text('Ваш телефон не підтримує NFC'),
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

  void _startWorkDay() async {
    DateTime _dateNow = DateTime.now();

    Timing timing = Timing(
      date: Utility.beginningOfDay(_dateNow),
      userID: _profile.userID,
      status: TIMING_STATUS_WORKDAY,
      startedAt: _dateNow,
      isTurnstile: true,
    );

    await TimingDAO().insert(timing);

    setState(() {
      _nfcTag = "";
      _profile = null;
    });

    Timing.syncTurnstile();
  }

  void _endWorkDay() async {
    DateTime _dateNow = DateTime.now();

    List<Timing> listTiming = await TimingDAO().getOpenWorkdayByDateUserId(
        Utility.beginningOfDay(_dateNow), _profile.userID);
    for (var timing in listTiming) {
      timing.endedAt = _dateNow;
      await TimingDAO().updateByMobID(timing);
    }

    setState(() {
      _nfcTag = "";
      _profile = null;
    });

    Timing.syncTurnstile();
  }

  Widget _turnstileHistory() {
    List<DataRow> dataRows = [];

    for (var timing in _timingTurnstile) {
      dataRows.add(DataRow(cells: <DataCell>[
        DataCell(GestureDetector(
          child: Row(
            children: <Widget>[
              Text(timingAlias[timing.status]),
            ],
          ),
        )),
        DataCell(Text(timing.startedAt != null
            ? formatDate(timing.startedAt, [HH, ':', nn, ':', ss])
            : "")),
        DataCell(Text(timing.endedAt != null
            ? formatDate(timing.endedAt, [HH, ':', nn, ':', ss])
            : "")),
      ]));
    }

    return DataTable(
      columns: [
        DataColumn(
          label: Text('Статус'),
        ),
        DataColumn(
          label: Text('Початок'),
        ),
        DataColumn(
          label: Text('Кінець'),
        )
      ],
      rows: dataRows,
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _pageNfcProfile() {
    bool _isLoggedIn = false;
    DateTime _dateNow = DateTime.now();

    if (_timingTurnstile.length > 0) {
      Timing _currentTiming = _timingTurnstile[0];
      if (_currentTiming.endedAt == null) {
        _isLoggedIn = true;
      }
    }

    Duration _workingDuration = Duration(seconds: 0);
    for (var _timing in _timingTurnstile) {
      if (_timing.endedAt == null) {
        _workingDuration += _dateNow.difference(_timing.startedAt);
      } else {
        _workingDuration += _timing.endedAt.difference(_timing.startedAt);
      }
    }

    String _currentStatus = _isLoggedIn ? "працюю" : "не працюю";

    return SafeArea(
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              child: _getUserPic(_profile),
            ),
            Text(
              _profile.firstName + ' ' + _profile.lastName,
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Cтатус',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 26.0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          _currentStatus,
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Сьогодні',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          formatDate(_dateNow, [dd, '-', mm, '-', yyyy]),
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Час на роботі',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          _printDuration(_workingDuration),
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: _turnstileHistory(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: FractionalOffset.center,
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 140.0,
                        child: RaisedButton(
                          onPressed: _isLoggedIn ? null : _startWorkDay,
                          padding: EdgeInsets.all(10.0),
                          color: Theme.of(context).accentColor,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.doorOpen,
                                size: 28.0,
                              ),
                              Expanded(
                                child: Text(
                                  'ВХІД',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 140.0,
                        child: RaisedButton(
                          onPressed: _isLoggedIn ? _endWorkDay : null,
                          padding: EdgeInsets.all(10.0),
                          color: Theme.of(context).accentColor,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.doorClosed,
                                size: 28.0,
                              ),
                              Expanded(
                                child: Text(
                                  'ВИХІД',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 48.0,
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              _nfcTag = "";
                              _profile = null;
                            });
                          },
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.close,
                            size: 28.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getDataByInfoCard(String _tag) async {
    int infoCard = int.parse(_tag);

    Profile _pfl = await ProfileDAO().getByInfoCard(infoCard);

    if (_pfl == null) {
      _pfl = await Profile.downloadByInfoCard(_tag);
    }

    DateTime _beginingDay = Utility.beginningOfDay(DateTime.now());

    List<Timing> _tmngTurnstile = [];
    if (_pfl != null) {
      _tmngTurnstile =
          await TimingDAO().getTurnstileByDateUserId(_beginingDay, _pfl.userID);
    }

    setState(() {
      _nfcTag = _tag;
      _profile = _pfl;
      _timingTurnstile = _tmngTurnstile;
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

  Widget _getUserPic(profile) {
    if (profile == null || profile.photoName == '') {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        child: Text('фото'),
      );
    } else {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        backgroundImage: ExactAssetImage(profile.photoName),
      );
    }
  }
}
