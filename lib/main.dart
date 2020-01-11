import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html';

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State {
  final _formKey = GlobalKey<FormState>();
  final serverIPController = TextEditingController();
  final serverUserController = TextEditingController();
  final serverPasswordController = TextEditingController();
  final serverDBController = TextEditingController();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Text(
                  'server IP:',
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.left,
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний server IP';
                    },
                    controller: serverIPController),
                new Text(
                  'Server User:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний server User';
                    },
                    controller: serverUserController),
                new Text(
                  'Server Password:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний server Password';
                    },
                    controller: serverPasswordController,
                    obscureText: true),
                new Text(
                  'server Database:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                  validator: (value) {
                    if (value.isEmpty) return 'не вказана server Database';
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
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Виконано запит'),
                        backgroundColor: Colors.green,
                      ));
                    },
                    child: Text('Send'))
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

  _requset() {
//    var data = { 'title' : 'My first post' };
    HttpRequest.request('https://jsonplaceholder.typicode.com/posts',
            method: 'POST',
            sendData: json.encode(data),
            requestHeaders: {'Content-Type': 'application/json; charset=UTF-8'})
        .then((resp) {
      print(resp.responseUrl);
      print(resp.responseText);
    });
  }
}

void main() => runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new Scaffold(
        appBar: new AppBar(title: new Text('Enterprise')),
        body: new MyForm())));
