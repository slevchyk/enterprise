import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/pages/page_helpdesk_detail.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:enterprise/pages/page_main.dart';
import 'dart:async';
import 'package:enterprise/models/models.dart';
import 'package:flutter/rendering.dart';
import '../models/profile.dart';

class PageHelpdesk extends StatefulWidget {
  final Profile profile;

  PageHelpdesk({
    this.profile,
  });

  @override
  _PageHelpdeskState createState() => _PageHelpdeskState();
}

class _PageHelpdeskState extends State<PageHelpdesk> {
  Profile _profile;
  Future<List<Helpdesk>> helpdeskprocessed;
  Future<List<Helpdesk>> helpdeskunprocessed;

  @override
  void initState() {
    super.initState();
    getprofileByUuid();
    helpdeskprocessed = getHelpdesk(HELPDESK_STATUS_PROCESSED);
    helpdeskunprocessed = getHelpdesk(HELPDESK_STATUS_UNPROCESSED);
  }

  _updateHelpdesk() async {
    helpdeskprocessed = getHelpdesk(HELPDESK_STATUS_PROCESSED);
    helpdeskunprocessed = getHelpdesk(HELPDESK_STATUS_UNPROCESSED);
    setState(() {});
  }

  Future<List<Helpdesk>> getHelpdesk(String Status) async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return HelpdeskDAO().getByUserIdType(userID, Status);
  }

  getprofileByUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(KEY_USER_ID) ?? "";
    _profile = await ProfileDAO().getByUserId(userID);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Help desk'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: "Неопрацьовані"),
              Tab(text: "Опрацьовані"),
            ],
          ),
        ),
        drawer: AppDrawer(
          profile: _profile,
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshTiming,
              child: Container(
                child: FutureBuilder(
                  future: helpdeskprocessed,
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
                        var listHelpdesks = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listHelpdesks.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              Helpdesk helpdesk = listHelpdesks[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PageHelpdeskDetail(
                                                  helpdesk: helpdesk)),
                                    );
                                  },
                                  child: ListTile(
                                    title: Text(
                                      helpdesk.title,
                                    ),
                                    isThreeLine: true,
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text('HD'),
                                    ),
                                    subtitle: Text(
                                      helpdesk.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                  future: helpdeskunprocessed,
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
                        var listHelpdesks = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listHelpdesks.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              Helpdesk helpdesk = listHelpdesks[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PageHelpdeskDetail(
                                                  helpdesk: helpdesk)),
                                    );
                                  },
                                  child: ListTile(
                                    title: Text(
                                      helpdesk.title,
                                    ),
                                    isThreeLine: true,
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text('HD'),
                                    ),
                                    subtitle: Text(
                                      helpdesk.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            RouteArgs _args = RouteArgs(profile: _profile);
            Navigator.of(context).pushNamed(
              '/helpdeskdetail',
              arguments: _args,
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshTiming() async {
    _updateHelpdesk();
  }
}
