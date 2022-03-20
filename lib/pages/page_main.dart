import 'dart:io';

import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/channel.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/auth/page_login.dart';
import 'package:enterprise/pages/body_main_chanel.dart';
import 'package:enterprise/pages/body_main_timing.dart';
import 'package:enterprise/widgets/user_photo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/constants.dart';
import '../models/profile.dart';

class PageMain extends StatefulWidget {
  final Profile profile;

  PageMain({
    this.profile,
  });

  PageMainState createState() => PageMainState();
}

class PageMainState extends State<PageMain> {
  FirebaseMessaging _fcm = FirebaseMessaging();
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  Profile profile;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSettings());

    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      _onMessage(_globalKey, message);
    }, onResume: (Map<String, dynamic> message) async {
      _onResume(message);
    }, onLaunch: (Map<String, dynamic> message) async {
      _onLaunch(message);
    });

    _fcm.requestNotificationPermissions();
  }

  _getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
      _profile = await ProfileDAO().getByUserId(_userID);
    }

    setState(() {
      profile = _profile;
    });
  }

  int _currentIndex = 0;

  Widget getBody(index) {
    switch (index) {
      case 0:
        return BodyMain(profile);
      case 1:
        return BodyChannel(profile);
      default:
        return BodyMain(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: getBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "головна",
              activeIcon: Icon(
                Icons.home,
                color: Theme.of(context).accentColor,
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.rss_feed),
              label: "канал",
              activeIcon: Icon(
                Icons.rss_feed,
                color: Theme.of(context).accentColor,
              )),
        ],
      ),
    );
  }

  _onMessage(GlobalKey<ScaffoldState> _globalKey, Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final String userID = prefs.get(KEY_USER_ID);

    Map<dynamic, dynamic> _data = message['data'];

    if (_data['notification_type'] == "channel") {
      Channel channel = Channel(
        id: int.parse(_data['id']),
        userID: userID,
        type: _data['type'],
        title: _data['title'],
        news: _data['news'],
      );

      channel.processDownloads();

      showDialog(
        context: _globalKey.currentContext,
        builder: (context) => AlertDialog(
          content: ListTile(
            title: Text(_data['title']),
            subtitle: Text(_data['news']),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Закрити'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('Переглянути'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/channel/detail", arguments: channel);
              },
            ),
          ],
        ),
      );
    }
  }

  _onResume(Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final String userID = prefs.get(KEY_USER_ID);

    Map<dynamic, dynamic> _data = message['data'];

    if (_data['notification_type'] == "channel") {
      Channel channel = Channel(
        id: int.parse(_data['id']),
        userID: userID,
        type: _data['type'],
        title: _data['title'],
        news: _data['news'],
      );

      channel.processDownloads();

      Navigator.of(context).pushNamed(
        "/channel/detail",
        arguments: channel,
      );
    }
  }

  _onLaunch(Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final String userID = prefs.get(KEY_USER_ID);

    Map<dynamic, dynamic> _data = message['data'];

    if (_data['notification_type'] == "channel") {
      Channel channel = Channel(
        id: int.parse(_data['id']),
        userID: userID,
        type: _data['type'],
        title: _data['title'],
        news: _data['news'],
      );

      channel.processDownloads();

      Navigator.of(context).pushNamed(
        "/channel/detail",
        arguments: channel,
      );
    }
  }
}

class AppDrawer extends StatefulWidget {
  final Profile profile;

  AppDrawer({
    this.profile,
  });

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
//  String userID;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: widget.profile == null
                  ? Text('Ім\'я')
                  : Text(widget.profile.firstName + ' ' + widget.profile.lastName),
              accountEmail: widget.profile == null ? Text('email') : Text(widget.profile.email),
              currentAccountPicture: UserPhoto(
                profile: widget.profile,
              ),
            ),

            for (var menuElement in menuList.keys)
              Column(
                children: <Widget>[
                  ListTile(
                    leading: menuElement.path == "/exit"
                        ? widget.profile?.userID == ""
                            ? Icon(FontAwesomeIcons.signInAlt)
                            : Icon(FontAwesomeIcons.signOutAlt)
                        : Icon(menuElement.icon),
                    title: Text(menuElement.path == "/exit"
                        ? widget.profile?.userID == "" ? 'Увійти' : 'Вийти'
                        : menuElement.name),
                    onTap: () {
                      if (menuElement.path == "/exit") {
                        singInOutDialog(context);
                      } else {
                        RouteArgs args = RouteArgs(profile: widget.profile);
                        Navigator.of(context).pushNamed(
                          '${menuElement.path}',
                          arguments: args,
                        ).whenComplete(() => menuElement.isClearCache ? _clearTemp() : null);
                      }
                    },
                  ),
                  menuElement.isDivider ? Divider() : SizedBox(),
                ],
              ),

          ],
        ),
      ),
    );
  }

  void _clearTemp() async {
    var appDir = (await getTemporaryDirectory()).path;
    new Directory(appDir).delete(recursive: true);
  }
}
