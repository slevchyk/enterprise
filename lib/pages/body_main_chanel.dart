import 'dart:convert';
import 'dart:io';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/database/channel_dao.dart';
import 'package:enterprise/models/channel.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_channel_detail.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:f_logs/f_logs.dart';
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
  Future<List<Channel>> channelsNews;
  Future<List<Channel>> channelsStatuses;
  Future<List<Channel>> channelsArchived;

  @override
  void initState() {
    super.initState();

    channelsNews = getChannels(CHANNEL_TYPE_MESSAGE);
    channelsArchived = getArchived();
    channelsStatuses = getChannels(CHANNEL_TYPE_STATUS);
  }

  _downloadChannel(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final String _srvIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _srvUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _srvPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String _userID = prefs.get(KEY_USER_ID);

    int _updateID = prefs.getInt(KEY_CHANNEL_UPDATE_ID) ?? 0;

    final String url =
        'http://$_srvIP/api/channel?userid=$_userID&offset=$_updateID';

    final credentials = '$_srvUser:$_srvPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    int countMessages = 0;
    int countStatuses = 0;

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    try{
      Response response = await get(url, headers: headers);

      if (response.statusCode != 200) {
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error",
        );
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Не вдалось отримати дані'),
          backgroundColor: Colors.redAccent,
        ));
        return;
      }

      String body = utf8.decode(response.bodyBytes);

      final jsonData = json.decode(body);

      for (var jsonRow in jsonData) {
        Channel _channel = Channel.fromMap(jsonRow);

        _channel.userID = _userID;
        if (_updateID < jsonRow["update_id"]) {
          _updateID = jsonRow["update_id"];
        }

        await _channel.processDownloads();

        if (_channel.type == CHANNEL_TYPE_MESSAGE) {
          countMessages++;
        } else {
          countStatuses++;
        }
      }
    } catch (e, s){
      FLog.error(
        exception: Exception(e.toString()),
        text: "response error",
        stacktrace: s,
      );
    }
    prefs.setInt(KEY_CHANNEL_UPDATE_ID, _updateID);
  }

  _updateChannel() async {
    await _downloadChannel(context);
    channelsNews = getChannels(CHANNEL_TYPE_MESSAGE);
    channelsArchived = getArchived();
    channelsStatuses = getChannels(CHANNEL_TYPE_STATUS);
    setState(() {});
  }

  Future<List<Channel>> getChannels(String status) async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChannelDAO().getByUserIdType(userID, status);
  }

  Future<List<Channel>> getArchived() async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return ChannelDAO().getArchivedByUserId(userID);
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
            channelsNews = getChannels(CHANNEL_TYPE_MESSAGE);
            channelsArchived = getArchived();
            channelsStatuses = getChannels(CHANNEL_TYPE_STATUS);
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
            channelsNews = getChannels(CHANNEL_TYPE_MESSAGE);
            channelsArchived = getArchived();
            channelsStatuses = getChannels(CHANNEL_TYPE_STATUS);
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
              Tab(text: "Новини"),
              Tab(text: "Статуси"),
              Tab(text: "Архів"),
            ],
          ),
        ),
        drawer: AppDrawer(
          profile: widget.profile,
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshTiming,
              child: Container(
                child: FutureBuilder(
                  future: channelsNews,
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
                        var listChannels = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listChannels.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              Channel channel = listChannels[index];
                              return Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: <Widget>[
                                  new IconSlideAction(
                                    caption: 'Архівувати',
                                    color: Colors.blue,
                                    icon: Icons.archive,
                                    onTap: () {
                                      ChannelDAO().archiveById(
                                          listChannels[index].mobID);
                                      setState(() {
                                        channelsNews =
                                            getChannels(CHANNEL_TYPE_MESSAGE);
                                        channelsArchived = getArchived();
                                        channelsStatuses =
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
                                      ChannelDAO().deleteById(
                                          listChannels[index].mobID);
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
                                        title: Text(
                                          channel.title,
                                          style: TextStyle(
                                            fontWeight:
                                                channel.starredAt == null
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                          ),
                                        ),
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
                  future: channelsStatuses,
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
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: <Widget>[
                                  new IconSlideAction(
                                    caption: 'Архівувати',
                                    color: Colors.blue,
                                    icon: Icons.archive,
                                    onTap: () {
                                      ChannelDAO().archiveById(
                                          listChanneles[index].mobID);
                                      setState(() {
                                        channelsNews =
                                            getChannels(CHANNEL_TYPE_MESSAGE);
                                        channelsArchived = getArchived();
                                        channelsStatuses =
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
                                      ChannelDAO().deleteById(
                                          listChanneles[index].mobID);
                                    },
                                  ),
                                ],
                                child: ListTile(
                                  title: Text(
                                    channel.title,
                                    style: TextStyle(
                                      fontWeight: channel.starredAt == null
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
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
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: <Widget>[
                                  new IconSlideAction(
                                    caption: 'Розархівувати',
                                    color: Colors.blue,
                                    icon: Icons.archive,
                                    onTap: () {
                                      ChannelDAO().unarchiveById(
                                          listChanneles[index].mobID);
                                      setState(() {
                                        channelsNews =
                                            getChannels(CHANNEL_TYPE_MESSAGE);
                                        channelsArchived = getArchived();
                                        channelsStatuses =
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
                                      ChannelDAO().deleteById(
                                          listChanneles[index].mobID);
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
  Widget build(BuildContext context) {
    return Hero(
      tag: 'channel_' + widget.channel.id.toString(),
      child: Material(
//        padding: EdgeInsets.all(16),
        child: PageChanelDetail(channel: widget.channel),
      ),
    );
  }
}
