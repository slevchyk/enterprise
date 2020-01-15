import 'package:enterprise/db.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/pages/body_main_chanel.dart';
import 'package:enterprise/pages/body_main_mainl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contatns.dart';
import '../models.dart';

class PageMain extends StatefulWidget {
  PageMainState createState() => PageMainState();
}

class PageMainState extends State<PageMain> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSettings());
  }

  bool isLoadingProfile = true;
  String userID;
  Profile profile;

  _getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
      _profile = await DBProvider.db.getProfile(_userID);
    }

    setState(() {
      userID = _userID;
      profile = _profile;
      isLoadingProfile = false;
    });
  }

  Widget getUserpic() {
    if (isLoadingProfile || profile == null || profile.photo == '') {
      return CircleAvatar(
        child: Text('фото'),
      );
    } else {
      return CircleAvatar(
        child: Image.asset(profile.photo),
      );
    }
  }

  int _currentIndex = 0;

  Widget getBody(index) {
    switch (index) {
      case 0:
        return BodyMain();
      case 1:
        return BodyChanel();
      default:
        return BodyMain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: ,
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: isLoadingProfile
                  ? Text('Ім\'я')
                  : Text(profile.firstName + ' ' + profile.lastName),
              accountEmail:
                  isLoadingProfile ? Text('email') : Text(profile.email),
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
      ),
      body: getBody(_currentIndex),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {},
      ),
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
