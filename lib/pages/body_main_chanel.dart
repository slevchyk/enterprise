import 'dart:convert';
import 'dart:io';

import 'package:enterprise/contatns.dart';
import 'package:enterprise/database/chanel_dao.dart';
import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/chanel.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/profile.dart';

class BodyChanel extends StatefulWidget {
  final Profile profile;

  BodyChanel(
    this.profile,
  );

  BodyChanelState createState() => BodyChanelState();
}

class BodyChanelState extends State<BodyChanel> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWidgetState());
  }

  Future<List<Channel>> channels;
  Future<List<Channel>> channelsArchived;
  Future<List<Channel>> channelsDeleted;

  void _initWidgetState() {
    channels = getChaneles();
    channelsArchived = getArchive();
    channelsDeleted = getDelete();
  }

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
      Channel chanel = Channel.fromMap(jsonRow);
      chanel.userID = _userID;

      Channel existChanel = await ChanelDAO().getById(chanel.id);

      if (existChanel != null) {
        ChanelDAO().update(chanel);
      } else {
        ChanelDAO().insert(chanel);
      }
    }
  }

  _updateChanel() async {
    await _downloadChanel(context);
    channels = getChaneles();
    setState(() {});
  }

  Future<List<Channel>> getChaneles() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChanelDAO().getByUserId(userID);
  }

  Future<List<Channel>> getDelete() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChanelDAO().getDeletedByUSerId(userID);
  }

  Future<List<Channel>> getArchive() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChanelDAO().getArchivedByUserId(userID);
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
                future: channels,
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
                            Channel chanel = listChaneles[index];
                            return Slidable(
                              delegate: new SlidableDrawerDelegate(),
                              actionExtentRatio: 0.25,
                              actions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Архівувати',
                                  color: Colors.blue,
                                  icon: Icons.archive,
                                  onTap: () {
                                    ChanelDAO()
                                        .archiveById(listChaneles[index].id);
                                    setState(() {
                                      channels = getChaneles();
                                      channelsArchived = getArchive();
                                    });
                                  },
                                ),
                              ],
                              secondaryActions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Важливі',
                                  color: Colors.yellow,
                                  icon: Icons.star_border,
                                  onTap: () {
                                    ChanelDAO()
                                        .starById(listChaneles[index].id);
                                  },
                                ),
                                new IconSlideAction(
                                  caption: 'Видалити',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    ChanelDAO()
                                        .deleteById(listChaneles[index].id);
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
                    default:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              ),
            ),
            Container(
              child: FutureBuilder(
                future: channelsArchived,
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
                            Channel chanel = listChaneles[index];
                            return Slidable(
                              delegate: new SlidableDrawerDelegate(),
                              actionExtentRatio: 0.25,
                              actions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Розархівувати',
                                  color: Colors.blue,
                                  icon: Icons.archive,
                                  onTap: () {
                                    ChanelDAO()
                                        .unarchiveById(listChaneles[index].id);
                                    setState(() {
                                      channels = getChaneles();
                                      channelsArchived = getArchive();
                                    });
                                  },
                                ),
                              ],
                              secondaryActions: <Widget>[
                                new IconSlideAction(
                                  caption: 'Важливі',
                                  color: Colors.yellow,
                                  icon: Icons.star_border,
                                  onTap: () {
                                    ChanelDAO()
                                        .starById(listChaneles[index].id);
                                  },
                                ),
                                new IconSlideAction(
                                  caption: 'Видалити',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    ChanelDAO()
                                        .deleteById(listChaneles[index].id);
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
                    default:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  }
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
