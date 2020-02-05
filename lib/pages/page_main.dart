import 'package:enterprise/database/core.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/pages/body_main_chanel.dart';
import 'package:enterprise/pages/body_main_timing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contatns.dart';
import '../models/profile.dart';

class PageMain extends StatefulWidget {
  PageMainState createState() => PageMainState();
}

class PageMainState extends State<PageMain> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSettings());
  }

  Profile profile;

  _getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
//      _profile = await DBProvider.db.getProfile(_userID);
      _profile = await ProfileDAO().getByUuid(_userID);
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
            title: Text('головна'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            title: Text('канал'),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  final Profile profile;

  AppDrawer(
    this.profile,
  );

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Widget getUserpic() {
    if (widget.profile == null || widget.profile.photo == '') {
      return CircleAvatar(
        child: Text('фото'),
      );
    } else {
      return CircleAvatar(
        child: Image.asset(widget.profile.photo),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: widget.profile == null
                ? Text('Ім\'я')
                : Text(
                    widget.profile.firstName + ' ' + widget.profile.lastName),
            accountEmail: widget.profile == null
                ? Text('email')
                : Text(widget.profile.email),
            currentAccountPicture: getUserpic(),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Головна'),
            onTap: () {
              Navigator.of(context).pushNamed(
                '/',
                arguments: "",
              );
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.moneyBill),
            title: Text('Каса'),
            onTap: () {
              Navigator.of(context).pushNamed(
                '/paydesk',
                arguments: "",
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Профіль'),
            onTap: () {
              Navigator.of(context).pushNamed(
                '/profile',
                arguments: "",
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Налаштування'),
            onTap: () {
              Navigator.of(context).pushNamed(
                '/settings',
                arguments: "",
              );
            },
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('Про додаток'),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/about',
                    arguments: "",
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
