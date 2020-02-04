import 'dart:io';

//import 'package:flutter/cupertino.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/database/core.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';

class PageSettings extends StatefulWidget {
  PageSettingsState createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _userPhoneController = TextEditingController();
  final _userPinController = TextEditingController();
  final _serverIPController = TextEditingController();
  final _serverUserController = TextEditingController();
  final _serverPasswordController = TextEditingController();
  final _serverDBController = TextEditingController();

  bool _readOnly = true;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _readSettings());
  }

//  Choice _selectedChoice = choices[0]; // The app's "state".

  void _select(Choice choice) {
    switch (choice.title) {
      case "Edit":
        setState(() {
          _readOnly = !_readOnly;
        });

        break;
      case "Save":
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
        }
        {}
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Налаштування'),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Обліковий запис:',
                    style:
                        TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                  ),
                  TextFormField(
                    controller: _userPhoneController,
                    readOnly: _readOnly,
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
                  Text(
                    'Connection:',
                    style:
                        TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                  ),
                  TextFormField(
                    controller: _serverIPController,
                    decoration: InputDecoration(
                        labelText: "IP",
                        hintText: "1C server IP",
                        icon: Icon(Icons.computer)),
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний: IP';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _serverDBController,
                    decoration: InputDecoration(
                      labelText: "database",
                      hintText: "1C server database",
                      icon: SizedBox(
                        width: 24.0,
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'не вказана: Database';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _serverUserController,
                    decoration: InputDecoration(
                        labelText: "user",
                        hintText: "1C server user",
                        icon: SizedBox(
                          width: 24.0,
                        )),
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний: User';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _serverPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "password",
                      hintText: "1C server password",
                      icon: SizedBox(
                        width: 24.0,
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний: Password';
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Save',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _saveSettings();
                        setState(() {
                          _readOnly = true;
                        });
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Налаштування збережено'),
                          backgroundColor: Colors.green,
                        ));
                      }
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      _makePostRequest();
                    },
                    child: Text('Send'),
                    color: Colors.blueGrey,
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        _readOnly = !_readOnly;
                      });
                    },
                    child: Text('Edit'),
                    color: Colors.blueGrey,
                  ),
                  Wrap(
                    children: [
                      FlatButton(
                        onPressed: () {
                          _clearProfile();
                        },
                        child: Text('clear profile'),
                        color: Colors.blueGrey,
                      ),
                      FlatButton(
                        onPressed: () {
                          _clearTiming();
                        },
                        child: Text('clear timing'),
                        color: Colors.blueGrey,
                      ),
                      FlatButton(
                        onPressed: () {
                          _deleteDB();
                        },
                        child: Text('delete db'),
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }

  _readSettings() async {
    final prefs = await SharedPreferences.getInstance();

    //account
    _userPhoneController.text = prefs.getString(KEY_USER_PHONE) ?? "";
    _userPinController.text = prefs.getString(KEY_USER_PIN) ?? "";

    //connection
    _serverIPController.text = prefs.getString(KEY_SERVER_IP) ?? "";
    _serverDBController.text = prefs.getString(KEY_SERVER_DATABASE) ?? "";
    _serverUserController.text = prefs.getString(KEY_SERVER_USER) ?? "";
    _serverPasswordController.text = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    //account
    prefs.setString(KEY_USER_PHONE, _userPhoneController.text);
    prefs.setString(KEY_USER_PIN, _userPinController.text);

    //connection
    prefs.setString(KEY_SERVER_IP, _serverIPController.text);
    prefs.setString(KEY_SERVER_DATABASE, _serverDBController.text);
    prefs.setString(KEY_SERVER_USER, _serverUserController.text);
    prefs.setString(KEY_SERVER_PASSWORD, _serverPasswordController.text);

    Profile profile = await Profile.download(_scaffoldKey);
    if (profile != null) {
      prefs.setString(KEY_USER_ID, profile.uuid);
    }
  }

  _makePostRequest() async {
    // set up POST request arguments
    String url = 'http://' +
        _serverIPController.text +
        '/' +
        _serverDBController.text +
        '/hs/m/time';

    final username = _serverUserController.text;
    final password = _serverPasswordController.text;
    final credentials = '$username:$password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    // make POST request
    Response response = await post(url, headers: headers);

    // check the status code for the result
    int statusCode = response.statusCode;
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(statusCode.toString()),
      backgroundColor: Colors.green,
    ));
  }

  _clearProfile() async {
    ProfileDAO().deleteAll();
  }

  _clearTiming() async {
    TimingDAO().deleteAll();
  }

  _deleteDB() async {
    DBProvider.db.deleteDB();
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(
    title: 'Edit',
    icon: Icons.edit,
  ),
  const Choice(
    title: 'Save',
    icon: Icons.save,
  ),
];
