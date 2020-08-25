import 'dart:ui';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/digital_keyboard.dart';
import 'package:enterprise/widgets/input_indicator.dart';
import 'package:enterprise/widgets/user_photo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class PageAuth extends StatefulWidget {
  final Profile profile;

  PageAuth({
    this.profile,
  });

  @override
  _PageAuthState createState() => _PageAuthState();
}

class _PageAuthState extends State<PageAuth> {
  bool _didAuthenticate;
  LocalAuthentication _localAuth = LocalAuthentication();
  bool _isPinAuth = false;
  String _enteredPin = "";
  bool _incorrectPin = false;
  bool _isBiometricProtectionEnabled = false;

  final iosStrings = const IOSAuthMessages(
      cancelButton: 'ввести ПІН-код',
      goToSettingsButton: 'налаштування',
      goToSettingsDescription: 'Будь ласка налаштуйте Touch ID.',
      lockOut: 'Будь ласка увімкніть Touch ID');

  final androidStrings = const AndroidAuthMessages(
    cancelButton: 'ввести ПІН-код',
    goToSettingsButton: 'налаштування',
    goToSettingsDescription: 'Будь ласка налаштуйте Fingerprint.',
    signInTitle: 'Відскануйте, щоб увійти',
    fingerprintHint: '',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initStateAsync());

    _isPinAuth = false;
    _incorrectPin = false;
    _enteredPin = "";
  }

  initStateAsync() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricProtectionEnabled =
          prefs.getBool(KEY_IS_BIOMETRIC_PROTECTION_ENABLED) ?? false;
      if (!_isBiometricProtectionEnabled) {
        _isPinAuth = true;
      }
    });

    if (_isBiometricProtectionEnabled) {
      _authBiometrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Visibility(
        visible: _isPinAuth,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: 150,
                height: 150,
                child: UserPhoto(
                  profile: widget.profile,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.profile?.firstName,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    widget.profile?.lastName,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InputIndicator(
                      size: 4,
                      input: _enteredPin,
                      filledColor: Theme.of(context).accentColor,
                      emptyColor: Theme.of(context).primaryColor,
                    ),
//                    _pinIndicator(4, _enteredPin),
                    SizedBox(
                      height: 5.0,
                    ),
                    Visibility(
                      visible: _incorrectPin,
                      child: Text(
                        'Ви ввели невірний ПІН-код',
                        style: TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    DigitalKeyboard(
                      onPressed: _authPin,
                    ),
                    Row(
                      mainAxisAlignment: _isBiometricProtectionEnabled
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: <Widget>[
                        Visibility(
                          visible: _isBiometricProtectionEnabled,
                          child: FlatButton(
                            child: Icon(
                              Icons.fingerprint,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPinAuth = false;
                              });
                              _authBiometrics();
                            },
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            "Забули ПІН-код?",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString(KEY_AUTH_PIN, "");
                            prefs.setString(KEY_USER_ID, "");
                            prefs.setBool(KEY_IS_PROTECTION_ENABLED, false);

                            Navigator.of(context).pushNamed("/");
                          },
                        )
                      ],
                    ), //
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _authBiometrics() async {
    _didAuthenticate = await _localAuth.authenticateWithBiometrics(
        localizedReason: '',
        iOSAuthStrings: iosStrings,
        androidAuthStrings: androidStrings,
        useErrorDialogs: false);

    if (_didAuthenticate) {
      RouteArgs _args = RouteArgs(profile: widget.profile);
      Navigator.of(context).pushReplacementNamed("/home", arguments: _args);
    } else {
      setState(() {
        _isPinAuth = true;
      });
    }
  }

  void _authPin(String value) async {
    if (value == "<") {
      setState(() {
        if (_enteredPin.length > 0) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
        _incorrectPin = false;
      });

      return;
    }

    String _pin = _enteredPin;

    _pin += value;

    if (_pin.length < 4) {
      setState(() {
        _enteredPin = _pin;
        _incorrectPin = false;
      });

      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String _authPin = prefs.getString(KEY_AUTH_PIN);

    if (_pin == _authPin) {
      RouteArgs _args = RouteArgs(profile: widget.profile);
      Navigator.of(context).pushReplacementNamed("/home", arguments: _args);
    } else {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate();
      }

      setState(() {
        _enteredPin = "";
        _incorrectPin = true;
      });
    }
  }
}
