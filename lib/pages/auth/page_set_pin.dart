import 'package:enterprise/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageSetPin extends StatefulWidget {
  @override
  _PageSetPinState createState() => _PageSetPinState();
}

class _PageSetPinState extends State<PageSetPin> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _authPinFirst = "";
  String _authPinSecond = "";
  String _title =
      "Для активаці біометричної аутентифікації спочатку потрібно встановити пін";

  final _pin01Controller = TextEditingController();
  final _pin02Controller = TextEditingController();
  final _pin03Controller = TextEditingController();
  final _pin04Controller = TextEditingController();

  final _focus01 = FocusNode();
  final _focus02 = FocusNode();
  final _focus03 = FocusNode();
  final _focus04 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: 60.0,
              right: 60.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        controller: _pin01Controller,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        focusNode: _focus01,
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context).requestFocus(_focus02);
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                        ],
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.isEmpty) return '';
                          return null;
                        },
                      ),
                      width: 40.0,
                    ),
                    Container(
                      child: TextFormField(
                        controller: _pin02Controller,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                        focusNode: _focus02,
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context).requestFocus(_focus03);
                          } else {
                            FocusScope.of(context).requestFocus(_focus01);
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                        ],
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.isEmpty) return '';
                          return null;
                        },
                      ),
                      width: 40.0,
                    ),
                    Container(
                      child: TextFormField(
                        controller: _pin03Controller,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                        focusNode: _focus03,
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context).requestFocus(_focus04);
                          } else {
                            FocusScope.of(context).requestFocus(_focus02);
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                        ],
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.isEmpty) return '';
                          return null;
                        },
                      ),
                      width: 40.0,
                    ),
                    Container(
                      child: TextFormField(
                        controller: _pin04Controller,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                        focusNode: _focus04,
                        onChanged: (value) {
                          _handlePin(value);
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                        ],
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.isEmpty) return '';
                          return null;
                        },
                      ),
                      width: 40.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Відмінити'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePin(String value) async {
    if (value.length == 1) {
      if (_authPinFirst == "") {
        _authPinFirst = _pin01Controller.text +
            _pin02Controller.text +
            _pin03Controller.text +
            _pin04Controller.text;

        _pin01Controller.clear();
        _pin02Controller.clear();
        _pin03Controller.clear();
        _pin04Controller.clear();

        setState(() {
          _title = "Повторіть пін ще раз";
        });

        FocusScope.of(context).requestFocus(_focus01);
      } else {
        _authPinSecond = _pin01Controller.text +
            _pin02Controller.text +
            _pin03Controller.text +
            _pin04Controller.text;

        _pin01Controller.clear();
        _pin02Controller.clear();
        _pin03Controller.clear();
        _pin04Controller.clear();

        if (_authPinFirst == _authPinSecond) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(KEY_AUTH_PIN, _authPinFirst);
          Navigator.pop(context);
        } else {
          _pin01Controller.clear();
          _pin02Controller.clear();
          _pin03Controller.clear();
          _pin04Controller.clear();

          setState(() {
            _authPinFirst = "";
            _authPinSecond = "";
            _title = "Ви введи два різні піни. Почнемо спочатку.";
          });

          FocusScope.of(context).requestFocus(_focus01);
        }
      }
    } else {
      FocusScope.of(context).requestFocus(_focus03);
    }
  }
}
