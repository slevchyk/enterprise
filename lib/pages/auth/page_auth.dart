import 'dart:ui';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageAuth extends StatefulWidget {
  final Profile profile;

  PageAuth({
    this.profile,
  });

  @override
  _PageAuthState createState() => _PageAuthState();
}

class _PageAuthState extends State<PageAuth> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _didAuthenticate;
  LocalAuthentication _localAuth = LocalAuthentication();
  bool _isPinAuth = false;

  final _pin01Controller = TextEditingController();
  final _pin02Controller = TextEditingController();
  final _pin03Controller = TextEditingController();
  final _pin04Controller = TextEditingController();

  final _focus01 = FocusNode();
  final _focus02 = FocusNode();
  final _focus03 = FocusNode();
  final _focus04 = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authBiometrics());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Visibility(
        visible: _isPinAuth,
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
                    "Введіть пін",
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
                            if (_formKey.currentState.validate()) {
                              _authPin(value);
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
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.fingerprint,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text('біометрична аутентифікація'),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPinAuth = false;
                          });
                          _authBiometrics();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _authBiometrics() async {
    _didAuthenticate = await _localAuth.authenticateWithBiometrics(
        localizedReason: 'Будь ласка аутентифікуйтесь щоб продовжити роботу');

    if (_didAuthenticate) {
      RouteArgs _args = RouteArgs(profile: widget.profile);
      Navigator.of(context).pushNamed("/main", arguments: _args);
    } else {
      setState(() {
        _isPinAuth = true;
      });
      FocusScope.of(context).requestFocus(_focus01);
    }
  }

  void _authPin(String value) async {
    String _enteredAuthPin = _pin01Controller.text +
        _pin02Controller.text +
        _pin03Controller.text +
        _pin04Controller.text;

    final prefs = await SharedPreferences.getInstance();
    String _authPin = prefs.getString(KEY_AUTH_PIN);

    if (_enteredAuthPin == _authPin) {
      RouteArgs _args = RouteArgs(profile: widget.profile);
      Navigator.of(context).pushNamed("/main", arguments: _args);
    }
  }
}
