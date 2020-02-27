import 'dart:convert';
import 'dart:io';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageLogin extends StatefulWidget {
  @override
  _PageLoginState createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<String> userID;
  final _userPhoneController = TextEditingController();
  final _userPinController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userID = getUserID();
  }

  getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_USER_ID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: userID,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              var _userID = snapshot.data;
              if (_userID != "") {
                Navigator.of(context).pushNamed(
                  '/',
                  arguments: "",
                );
              }
              return Material(
                child: Form(
                    child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _userPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: "Номер телефону",
                          hintText: "номер телефону +380...",
                          icon: Icon(Icons.phone)),
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
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    FlatButton(
                        child: Text('Увійти'),
                        onPressed: () {
                          _getLocalServerSettings(_scaffoldKey);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        )),
                  ],
                )),
              );
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }

  void _getLocalServerSettings(GlobalKey<ScaffoldState> _scaffoldKey) async {
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

      prefs.setString(KEY_SERVER_IP, localSrvIP);
      prefs.setString(KEY_SERVER_USER, localSrvUser);
      prefs.setString(KEY_SERVER_PASSWORD, localSrvPassword);

      Profile _profile = await Profile.downloadByPhonePin(_scaffoldKey);

      if (_profile != null) {
        userID = getUserID();
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
            'Не знайдено користувача сервера ліцензування з такими параметрами'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (response.statusCode == 500) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Помилка сервера сервера ліцензування:\n$body'),
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
