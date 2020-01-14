import 'dart:io';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';

class PageSettings extends StatefulWidget {
  PageSettingsState createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings> {
  final _formKey = GlobalKey<FormState>();
  final _userIDController = TextEditingController();
  final _userPINController = TextEditingController();
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
        ;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Account:',
                    style:
                        TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                  ),
                  TextFormField(
                    controller: _userIDController,
                    readOnly: _readOnly,
                    decoration: InputDecoration(
                        labelText: "ID",
                        hintText: "1C user ID",
                        icon: Icon(Icons.person)),
                  ),
                  TextFormField(
                    controller: _userPINController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "PIN",
                        hintText: "1C user PIN",
                        icon: SizedBox(
                          width: 24.0,
                        )),
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
                  )
                ],
              ))
        ],
      ),
    );
  }

  _readSettings() async {
    final prefs = await SharedPreferences.getInstance();

    //account
    _userIDController.text = prefs.getString("userID") ?? "";
    _userPINController.text = prefs.getString("userPIN") ?? "";

    //connection
    _serverIPController.text = prefs.getString("serverIP") ?? "";
    _serverUserController.text = prefs.getString("serverUser") ?? "";
    _serverPasswordController.text = prefs.getString("serverPassword") ?? "";
    _serverDBController.text = prefs.getString("serverDB") ?? "";
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    //account
    prefs.setString("userID", _userIDController.text);
    prefs.setString("userPIN", _userPINController.text);

    //connection
    prefs.setString("serverIP", _serverIPController.text);
    prefs.setString("serverUser", _serverUserController.text);
    prefs.setString("serverPassword", _serverPasswordController.text);
    prefs.setString("serverDB", _serverDBController.text);
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

//      String json = '{"title": "Hello", "body": "body text", "userId": 1}';

    // make POST request
//      Response response = await post(url, headers: headers, body: json);
    Response response = await post(url, headers: headers);
    // check the status code for the result
    int statusCode = response.statusCode;
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(statusCode.toString()),
      backgroundColor: Colors.green,
    ));
    // this API passes back the id of the new item added to the body
    String body = response.body;
    // {
    //   "title": "Hello",
    //   "body": "body text",
    //   "userId": 1,
    //   "id": 101
    // }
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
