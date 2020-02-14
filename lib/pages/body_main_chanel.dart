import 'dart:convert';
//import 'dart:html';
import 'dart:io';

import 'package:enterprise/models/contatns.dart';
import 'package:enterprise/database/channel_dao.dart';
import 'package:enterprise/models/channel.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/profile.dart';

class BodyChannel extends StatefulWidget {
  final Profile profile;

  BodyChannel(
    this.profile,
  );

  BodyChannelState createState() => BodyChannelState();
}

class BodyChannelState extends State<BodyChannel> {
  Future<List<Channel>> channels;
  Future<List<Channel>> channelsArchived;
  Future<List<Channel>> channelsStatus;

  @override
  void initState() {
    channels = getChannels(CHANNEL_TYPE_MESSAGE);
    channelsArchived = getArchived();
    channelsStatus = getChannels(CHANNEL_TYPE_STATUS);
  }

  _downloadChannel(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final String _ip = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _user = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _password = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _db = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String _userID = prefs.get(KEY_USER_ID);

    int _maxID = prefs.getInt(KEY_IDMAX) ?? 0;

    final String url =
        'http://$_ip/$_db/hs/m/channel?userid=$_userID&idmax=$_maxID';

    final credentials = '$_user:$_password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    int countnewchanel = 0;
    int countnewstatus = 0;

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

    for (var jsonRow in jsonData["channel"]) {
      Channel channel = Channel.fromMap(jsonRow);
      channel.userID = _userID;
      if (_maxID < jsonRow["IDMax"]) {
        _maxID = jsonRow["IDMax"];
      }
      Channel existChannel = await ChannelDAO().getById(channel.id);

      if (existChannel != null) {
        if (jsonRow["status"] == CHANNEL_TYPE_MESSAGE) {
          countnewchanel = countnewchanel + 1;
        } else {
          countnewstatus = countnewstatus + 1;
        }
        channel.starredAt = existChannel.starredAt;
        channel.deletedAt = existChannel.deletedAt;
        channel.archivedAt = existChannel.archivedAt;
        ChannelDAO().update(channel);
      } else {
        if (jsonRow["status"] == CHANNEL_TYPE_MESSAGE) {
          countnewchanel = countnewchanel + 1;
        } else {
          countnewstatus = countnewstatus + 1;
        }
        ChannelDAO().insert(channel);
      }
    }
    prefs.setInt(KEY_IDMAX, _maxID);
  }

  _updateChannel() async {
    await _downloadChannel(context);
    channels = getChannels(CHANNEL_TYPE_MESSAGE);
    channelsArchived = getArchived();
    channelsStatus = getChannels(CHANNEL_TYPE_STATUS);
    setState(() {});
  }

  Future<List<Channel>> getChannels(String Status) async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChannelDAO().getByUserIdType(userID, Status);
  }

  Future<List<Channel>> getArchived() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChannelDAO().getArchivedByUserId(userID);
  }

  Future<List<Channel>> getStarted() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChannelDAO().getStarredByUserId(userID);
  }

  Widget starSlideAction(Channel channel, int id) {
    Widget iconSlideAction;

    if (channel.starredAt != null) {
      iconSlideAction = new IconSlideAction(
        caption: 'Не Важливі',
        color: Colors.yellow,
        icon: Icons.star,
        onTap: () {
          ChannelDAO().unstarById(id);
          setState(() {
            channels = getChannels(CHANNEL_TYPE_MESSAGE);
            channelsArchived = getArchived();
            channelsStatus = getChannels(CHANNEL_TYPE_STATUS);
          });
        },
      );
    } else {
      iconSlideAction = new IconSlideAction(
        caption: 'Важливі',
        color: Colors.yellow,
        icon: Icons.star_border,
        onTap: () {
          ChannelDAO().starById(id);
          setState(() {
            channels = getChannels(CHANNEL_TYPE_MESSAGE);
            channelsArchived = getArchived();
            channelsStatus = getChannels(CHANNEL_TYPE_STATUS);
          });
        },
      );
    }

    return iconSlideAction;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Канал'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: "Нові"),
              Tab(text: "Статуси"),
              Tab(text: "Архів"),
            ],
          ),
        ),
        drawer: AppDrawer(widget.profile),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshTiming,
              child: Container(
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
                        var listChanneles = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listChanneles.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              Channel channel = listChanneles[index];
                              return Slidable(
                                delegate: new SlidableDrawerDelegate(),
                                actionExtentRatio: 0.25,
                                actions: <Widget>[
                                  new IconSlideAction(
                                    caption: 'Архівувати',
                                    color: Colors.blue,
                                    icon: Icons.archive,
                                    onTap: () {
                                      ChannelDAO()
                                          .archiveById(listChanneles[index].id);
                                      setState(() {
                                        channels =
                                            getChannels(CHANNEL_TYPE_MESSAGE);
                                        channelsArchived = getArchived();
                                        channelsStatus =
                                            getChannels(CHANNEL_TYPE_STATUS);
                                      });
                                    },
                                  ),
                                ],
                                secondaryActions: <Widget>[
                                  starSlideAction(channel, channel.id),
                                  new IconSlideAction(
                                    caption: 'Видалити',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      ChannelDAO()
                                          .deleteById(listChanneles[index].id);
                                    },
                                  ),
                                ],
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChannelHero(channel: channel)),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'channel_' + channel.id.toString(),
//                                    https://github.com/flutter/flutter/issues/34119
                                    child: Material(
                                      child: ListTile(
                                        title: Text(channel.title),
                                        isThreeLine: true,
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          child: Text('1C'),
                                        ),
                                        subtitle: Text(
                                          channel.news,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
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
            ),
            RefreshIndicator(
              onRefresh: _refreshTiming,
              child: Container(
                child: FutureBuilder(
                  future: channelsStatus,
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
                        var listChanneles = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listChanneles.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              Channel channel = listChanneles[index];
                              return Slidable(
                                delegate: new SlidableDrawerDelegate(),
                                actionExtentRatio: 0.25,
                                actions: <Widget>[
                                  new IconSlideAction(
                                    caption: 'Архівувати',
                                    color: Colors.blue,
                                    icon: Icons.archive,
                                    onTap: () {
                                      ChannelDAO()
                                          .archiveById(listChanneles[index].id);
                                      setState(() {
                                        channels =
                                            getChannels(CHANNEL_TYPE_MESSAGE);
                                        channelsArchived = getArchived();
                                        channelsStatus =
                                            getChannels(CHANNEL_TYPE_STATUS);
                                      });
                                    },
                                  ),
                                ],
                                secondaryActions: <Widget>[
                                  starSlideAction(channel, channel.id),
                                  new IconSlideAction(
                                    caption: 'Видалити',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      ChannelDAO()
                                          .deleteById(listChanneles[index].id);
                                    },
                                  ),
                                ],
                                child: ListTile(
                                  title: Text(channel.title),
                                  isThreeLine: true,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: Text('РC'),
                                  ),
                                  subtitle: Text(
                                    channel.news,
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
            ),
            RefreshIndicator(
              onRefresh: _refreshTiming,
              child: Container(
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
                        var listChanneles = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listChanneles.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              Channel channel = listChanneles[index];
                              return Slidable(
                                delegate: new SlidableDrawerDelegate(),
                                actionExtentRatio: 0.25,
                                actions: <Widget>[
                                  new IconSlideAction(
                                    caption: 'Розархівувати',
                                    color: Colors.blue,
                                    icon: Icons.archive,
                                    onTap: () {
                                      ChannelDAO().unarchiveById(
                                          listChanneles[index].id);
                                      setState(() {
                                        channels =
                                            getChannels(CHANNEL_TYPE_MESSAGE);
                                        channelsArchived = getArchived();
                                        channelsStatus =
                                            getChannels(CHANNEL_TYPE_STATUS);
                                      });
                                    },
                                  ),
                                ],
                                secondaryActions: <Widget>[
                                  starSlideAction(channel, channel.id),
                                  new IconSlideAction(
                                    caption: 'Видалити',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      ChannelDAO()
                                          .deleteById(listChanneles[index].id);
                                    },
                                  ),
                                ],
                                child: ListTile(
                                  title: Text(channel.title),
                                  isThreeLine: true,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: Text('1C'),
                                  ),
                                  subtitle: Text(
                                    channel.news,
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
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _updateChannel();
          },
          child: Icon(Icons.update),
        ),
      ),
    );
  }

  Future<void> _refreshTiming() async {
    _updateChannel();
  }
}

class ChannelHero extends StatefulWidget {
  final Channel channel;

  ChannelHero({
    this.channel,
  });

  @override
  _ChannelHeroState createState() => _ChannelHeroState();
}

class _ChannelHeroState extends State<ChannelHero> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'channel_' + widget.channel.id.toString(),
      child: Material(
//        padding: EdgeInsets.all(16),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.channel.title),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(14),
              child: Text(widget.channel.news, style: TextStyle(fontSize: 19)),
            ),
          ),
        ),
      ),
    );
  }
}
