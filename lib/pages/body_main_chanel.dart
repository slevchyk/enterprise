import 'dart:convert';
import 'dart:io';

import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/models.dart';
import 'package:flutter/cupertino.dart';
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

  _updateChanel() async {
    await _downloadChanel(context);
    chaneles = getChaneles();
    setState(() {});
  }

  Future<List<Chanel>> chaneles;

  void initState() {
    chaneles = getChaneles();
  }

  Future<List<Chanel>> getChaneles() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return DBProvider.db.getUserChanel(userID);
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
          child: FutureBuilder(
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
              var listChaneles = snapshot.data;
              return ListView.separated(
                itemCount: listChaneles.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (BuildContext context, int index) {
                  Chanel chanel = listChaneles[index];
                  return ListTile(
                    title: Text(chanel.title),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      child: Text('1C'),
                    ),
                    subtitle: Text(
                      chanel.news,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              );
          }
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _updateChanel();
        },
        child: Icon(Icons.update),
      ),
    );
  }
}
