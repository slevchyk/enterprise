import 'dart:convert';
import 'dart:io';

import 'package:enterprise/contatns.dart';
import 'package:enterprise/database/core.dart';
import 'package:enterprise/models.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

    final String url = 'http://$_ip/$_db/hs/m/chanel?userid=$_userID';

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
  Future<List<Chanel>> chaneles_archive;
  Future<List<Chanel>> chaneles_star;
  Future<List<Chanel>> chaneles_delete;

  void initState() {
    chaneles = getChaneles();
    chaneles_archive = getArchive();
    chaneles_star = getStarted();
    chaneles_delete = getDelete();
  }

  Future<List<Chanel>> getChaneles() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return DBProvider.db.getUserChanel(userID);
  }

  Future<List<Chanel>> getStarted() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return DBProvider.db.getStarted(userID);
  }

  Future<List<Chanel>> getDelete() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return DBProvider.db.getDelete(userID);
  }

  Future<List<Chanel>> getArchive() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return DBProvider.db.getArchive(userID);
  }

  Widget starUnstarSlideAction(Chanel chanel, int id) {
    Widget iconSlideAction;

    if (chanel.star != null) {
      iconSlideAction = new IconSlideAction(
        caption: 'Не Важливі',
        color: Colors.yellow,
        icon: Icons.star,
        onTap: () => {
          setState(() {
            DBProvider.db.updateChanelNew(id);
            chaneles = getChaneles();
            chaneles_archive = getArchive();
          })
        },
      );
    } else {
      iconSlideAction = new IconSlideAction(
        caption: 'Важливі',
        color: Colors.yellow,
        icon: Icons.star_border,
        onTap: () => {
          setState(() {
            DBProvider.db.updateChanelStar(id);
            chaneles = getChaneles();
            chaneles_archive = getArchive();
          })
        },
      );
    }

    return iconSlideAction;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Канал'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: "New"),
              Tab(text: "Archive"),
            ],
          ),
        ),
        drawer: AppDrawer(widget.profile),
        body: TabBarView(
          children: [
            Container(
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
                      return Center(
                        child: ListView.separated(
                          itemCount: listChaneles.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            Chanel chanel = listChaneles[index];
                            return Slidable(
                              delegate: new SlidableDrawerDelegate(),
                              actionExtentRatio: 0.25,
                              actions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Архівувати',
                                  color: Colors.blue,
                                  icon: Icons.archive,
                                  onTap: () {
                                    DBProvider.db.updateChanelArchive(
                                        listChaneles[index].id);
                                    setState(() {
                                      chaneles = getChaneles();
                                      chaneles_archive = getArchive();
                                    });
                                  },
                                ),
                              ],
                              secondaryActions: <Widget>[
                                starUnstarSlideAction(
                                    chanel, listChaneles[index].id),
                                new IconSlideAction(
                                  caption: 'Видалити',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () => {
                                    setState(() {
                                      DBProvider.db.updateChanelDelete(
                                          listChaneles[index].id);
                                    })
                                  },
                                ),
                              ],
                              child: ListTile(
                                title: Text(chanel.title),
                                isThreeLine: true,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text('1C'),
                                ),
                                subtitle: Text(
                                  chanel.news,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                  }
                  ;
                },
              ),
            ),
            Container(
              child: FutureBuilder(
                future: chaneles_archive,
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
                      return Center(
                        child: ListView.separated(
                          itemCount: listChaneles.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            Chanel chanel = listChaneles[index];
                            return Slidable(
                              delegate: new SlidableDrawerDelegate(),
                              actionExtentRatio: 0.25,
                              actions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Розархівувати',
                                  color: Colors.blue,
                                  icon: Icons.archive,
                                  onTap: () {
                                    DBProvider.db.updateChanelUnread(
                                        listChaneles[index].id);
                                    setState(() {
                                      chaneles = getChaneles();
                                      chaneles_archive = getArchive();
                                    });
                                  },
                                ),
                              ],
                              secondaryActions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Важливі',
                                  color: Colors.yellow,
                                  icon: Icons.star_border,
                                  onTap: () => {
                                    setState(() {
                                      DBProvider.db.updateChanelStar(
                                          listChaneles[index].id);
                                      chaneles = getChaneles();
                                      chaneles_archive = getArchive();
                                    })
                                  },
                                ),
                                new IconSlideAction(
                                  caption: 'Видалити',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () => {
                                    setState(() {
                                      DBProvider.db.updateChanelDelete(
                                          listChaneles[index].id);
                                    })
                                  },
                                ),
                              ],
                              child: ListTile(
                                title: Text(chanel.title),
                                isThreeLine: true,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text('1C'),
                                ),
                                subtitle: Text(
                                  chanel.news,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                  }
                  ;
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _updateChanel();
          },
          child: Icon(Icons.update),
        ),
      ),
    );
  }
}
