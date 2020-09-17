import 'package:enterprise/models/constants.dart';
import 'package:enterprise/widgets/digital_keyboard.dart';
import 'package:enterprise/widgets/input_indicator.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class PageSetPin extends StatefulWidget {
  @override
  _PageSetPinState createState() => _PageSetPinState();
}

class _PageSetPinState extends State<PageSetPin> {
  String _authPinFirst = "";
  String _authPinSecond = "";
  String _title = "Введіь ПІН-код";
  bool _incorrectPin = false;
  bool _confirmPin = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _title,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(
              height: 30.0,
            ),
            InputIndicator(
              size: 4,
              input: _confirmPin ? _authPinSecond : _authPinFirst,
            ),
            Visibility(
              visible: _incorrectPin,
              child: Text(
                'Ви ввели два різні ПІН-коди',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            DigitalKeyboard(
              onPressed: _confirmPin ? handlePinConfirmation : handlePin,
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              padding: EdgeInsets.only(
                left: 80.0,
                right: 80.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      'Відмінити',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  handlePin(String value) async {
    if (value == "<") {
      setState(() {
        if (_authPinFirst.length > 0) {
          _authPinFirst = _authPinFirst.substring(0, _authPinFirst.length - 1);
        }
        _incorrectPin = false;
      });

      return;
    }

    String _pin = _authPinFirst;

    _pin += value;

    setState(() {
      _authPinFirst = _pin;

      if (_pin.length < 4) {
        _authPinFirst = _pin;
        _incorrectPin = false;
      } else {
        _title = "Повторіть ПІН-код";
        _confirmPin = true;
        _incorrectPin = false;
      }
    });

    return;
  }

  handlePinConfirmation(String value) async {
    if (value == "<") {
      setState(() {
        if (_authPinSecond.length > 0) {
          _authPinSecond =
              _authPinSecond.substring(0, _authPinSecond.length - 1);
        }
        _incorrectPin = false;
      });

      return;
    }

    String _pin = _authPinSecond;

    _pin += value;

    if (_pin.length < 4) {
      setState(() {
        _authPinSecond = _pin;
        _incorrectPin = false;
      });

      return;
    }

    if (_authPinFirst == _pin) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(KEY_AUTH_PIN, _authPinFirst);
      Navigator.pop(context);
    } else {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate();
      }

      FLog.error(
        exception: Exception("Incorrect password"),
        text: "incorrect password entered",
      );

      setState(() {
        _title = "Введіь ПІН-код";
        _authPinFirst = "";
        _authPinSecond = "";
        _confirmPin = false;
        _incorrectPin = true;
      });
    }
  }
}
