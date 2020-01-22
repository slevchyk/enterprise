import 'dart:convert';
import 'dart:io';

import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class BodyChanel extends StatefulWidget {
  final Profile profile;

  BodyChanel(
    this.profile,
  );

  BodyChanelState createState() => BodyChanelState();
}

class BodyChanelState extends State<BodyChanel> {
  _downloadChanel(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final String _ip = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _user = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _password = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _db = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String _userID = prefs.get(KEY_USER_ID);

    final String url = 'http://$_ip/$_db/hs/m/chanel?infocard=$_userID';

    final credentials = '$_user:$_password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    Response response = await get(url, headers: headers);

    int statusCode = response.statusCode;

    if (statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Не вдалось отримати дані'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    String body = utf8.decode(response.bodyBytes);

    final jsonData = json.decode(body);

    for (var jsonRow in jsonData["chanel"]) {
      Chanel chanel = Chanel.fromMap(jsonRow);
      chanel.userID = _userID;

      Chanel existChanel = await DBProvider.db.getChanel(chanel.id);

      if (existChanel != null) {
        DBProvider.db.updateChanel(chanel);
      } else {
        DBProvider.db.newChanel(chanel);
      }
    }
  }

  Future<List<Chanel>> chaneles;

  void initState() {
    chaneles = getStatuses();
  }

  Future<List<Chanel>> getStatuses() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return DBProvider.db.getUserChanel(userID);
  }

  Widget listView(List<Chanel> listChaneles) {
//    List<DataRow> dataRows = [];

    if (listChaneles == null)
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

    List<ListTile> listTile = [];

    for (var _chanele in listChaneles) {
      ListTile tile = new ListTile(
        isThreeLine: true,
        title: Text(_chanele.title),
        subtitle: Text(_chanele.news),
        leading: CircleAvatar(
          child: Text('1c'),
        ),
      );
      listTile.add(tile);
    }

    return ListView(
      children: listTile.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Канал'),
      ),
//      drawer: AppDrawer(widget.profile),
      body: Container(
//        color: Colors.blueGrey,
        child: Column(children: [
          FutureBuilder(
              future: chaneles,
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
                    return listView(snapshot.data);
                }
              }),
//          RaisedButton(
//            onPressed: () {
//              _downloadChanel(context);
//            },
//            child: Text('Download'),
//          ),
        ]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _downloadChanel(context);
        },
        child: Text('Download'),
      ),
    );
  }
}

//ListView.separated(
//
//itemCount: 10,
//separatorBuilder: (context, index) => Divider(),
//itemBuilder: (BuildContext context, int index) {
//return ListTile(
//title: Text('Title $index'),
//isThreeLine: true,
//leading: CircleAvatar(
//child: Text('1C'),
//),
//subtitle: Text(
//'Another text text text text text text text text text text text'),
//);
//}),
