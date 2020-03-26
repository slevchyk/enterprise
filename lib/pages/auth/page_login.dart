import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageSignInOut extends StatefulWidget {
  @override
  _PageSignInOutState createState() => _PageSignInOutState();
}

class _PageSignInOutState extends State<PageSignInOut> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userPhoneController = TextEditingController();
  final _userPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Widget signInOutDebug() {
    if (this.isInDebugMode) {
      return FlatButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/main");
        },
        child: Text('Продовжити. debug'),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                child: Image.asset("assets/logo_512.png"),
                minRadius: 25,
                maxRadius: 50,
                backgroundColor: Colors.white,
              ),
              TextFormField(
                controller: _userPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Номер телефону",
                    hintText: "+380...",
                    icon: Icon(Icons.phone)),
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[+0-9]"))
                ],
                validator: (value) {
                  if (value.isEmpty) {
                    return "ви не вказали номер телефону";
                  } else if (value.length != 13) {
                    return "невірний формат";
                  }

                  return null;
                },
              ),
              TextFormField(
                  controller: _userPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "PIN",
                    hintText: "пін код карти перепустки",
                    icon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "ви не вказали секретний pin";
                    }

                    return null;
                  }),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Увійти'),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _getLocalServerSettingsProfile(_scaffoldKey);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  signInOutDebug(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getLocalServerSettingsProfile(
      GlobalKey<ScaffoldState> _scaffoldKey) async {
    Map<String, String> requestMap = {
      "phone": _userPhoneController.text,
      "pin": _userPinController.text
    };

    String requestJSON = json.encode(requestMap);

    final mainSrvIP = SERVER_IP;
    final mainSrvUsername = SERVER_USER;
    final mainSrvPassword = SERVER_PASSWORD;

    final credentials = '$mainSrvUsername:$mainSrvPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    String url = 'http://$mainSrvIP/api/getdbsettings';
    Response response = await post(url, headers: headers, body: requestJSON);

    String body = response.body;

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJSON = json.decode(body);

      final String localSrvIP = responseJSON["srv_ip"];
      final String localSrvUser = responseJSON["srv_user"];
      final String localSrvPassword = responseJSON["srv_password"];

      final prefs = await SharedPreferences.getInstance();

      prefs.setString(KEY_USER_PHONE, _userPhoneController.text);
      prefs.setString(KEY_USER_PIN, _userPinController.text);

      prefs.setString(KEY_SERVER_IP, localSrvIP);
      prefs.setString(KEY_SERVER_USER, localSrvUser);
      prefs.setString(KEY_SERVER_PASSWORD, localSrvPassword);

      Profile _profile = await Profile.downloadByPhonePin(_scaffoldKey);

      if (_profile != null) {
        if (_profile.userID != "") {
          RouteArgs args = RouteArgs(profile: _profile);

          prefs.setString(KEY_USER_ID, _profile.userID);
          Navigator.of(context).pushNamed(
            '/',
            arguments: args,
          );
        }
      }

      return;
    }

    if (response.statusCode == 400) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Невірні параметри сервера ліцензування\n$body'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (response.statusCode == 401) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Помилка сервера сервера ліцензування:\n$body'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (response.statusCode == 404) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'Не знайдено обілковий запис сервера ліцензування з такими параметрами'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (response.statusCode == 500) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Помилка сервера ліцензування:\n$body'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Не вдалось отримати налаштування сервера ліцензування'),
      backgroundColor: Colors.redAccent,
    ));
  }
}

singInOutDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ви дійсно бажаєте вийти?"),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ні"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Так"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString(KEY_USER_ID, "");
                Navigator.of(context).pushNamed("/sign_in_out");
              },
            )
          ],
        );
      });
}
