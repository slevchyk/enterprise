import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';

class PageSettings extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() => PageSettingsState();
  PageSettingsState createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings> {
  final _formKey = GlobalKey<FormState>();
  final serverIPController = TextEditingController();
  final serverUserController = TextEditingController();
  final serverPasswordController = TextEditingController();
  final serverDBController = TextEditingController();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
            key: _formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  'server IP:',
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.left,
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний: IP';
                    },
                    controller: serverIPController),
                new Text(
                  'server User:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний: User';
                    },
                    controller: serverUserController),
                new Text(
                  'server Password:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний: Password';
                    },
                    controller: serverPasswordController,
                    obscureText: true),
                new Text(
                  'server Database:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                  validator: (value) {
                    if (value.isEmpty) return 'не вказана: Database';
                  },
                  controller: serverDBController,
                ),
                new SizedBox(height: 20.0),
                new RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) _save();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Налаштування збережено'),
                      backgroundColor: Colors.green,
                    ));
                  },
                  child: Text('Save'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
                new FlatButton(
                  onPressed: () {
                    _makePostRequest();
                  },
                  child: Text('Send'),
                  color: Colors.blueGrey,
                )
              ],
            )));
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    serverIPController.text = prefs.getString("serverIP") ?? "";
    serverUserController.text = prefs.getString("serverUser") ?? "";
    serverPasswordController.text = prefs.getString("serverPassword") ?? "";
    serverDBController.text = prefs.getString("serverDB") ?? "";
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("serverIP", serverIPController.text);
    prefs.setString("serverUser", serverUserController.text);
    prefs.setString("serverPassword", serverPasswordController.text);
    prefs.setString("serverDB", serverDBController.text);
  }

  _makePostRequest() async {
    // set up POST request arguments
    String url = 'http://' +
        serverIPController.text +
        '/' +
        serverDBController.text +
        '/hs/m/time';

    final username = serverUserController.text;
    final password = serverPasswordController.text;
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
