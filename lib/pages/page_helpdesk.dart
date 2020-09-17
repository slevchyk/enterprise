import 'dart:async';

import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_helpdesk_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/profile.dart';

class PageHelpDesk extends StatefulWidget {
  final Profile profile;

  PageHelpDesk({
    this.profile,
  });

  @override
  _PageHelpDeskState createState() => _PageHelpDeskState();
}

class _PageHelpDeskState extends State<PageHelpDesk> {
  Profile _profile;
  Future<List<HelpDesk>> helpDeskProcessed;
  Future<List<HelpDesk>> helpDeskUnprocessed;

  @override
  void initState() {
    super.initState();
    //getprofileByUuid();
    _profile = widget.profile;
    _updateHelpDesk();
  }

  Future<void> _updateHelpDesk() async {
    setState(() {
      helpDeskProcessed = getHelpDesk(HELP_DESK_STATUS_PROCESSED);
      helpDeskUnprocessed = getHelpDesk(HELP_DESK_STATUS_UNPROCESSED);
    });
  }

  Future<List<HelpDesk>> getHelpDesk(String status) async {
//    final prefs = await SharedPreferences.getInstance();
//
//    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return HelpdeskDAO().getByUserIdType(_profile.userID, status);
  }

//  getProfileByUuid() async {
//    final prefs = await SharedPreferences.getInstance();
//    String userID = prefs.getString(KEY_USER_ID) ?? "";
//    _profile = await ProfileDAO().getByUserId(userID);
//  }

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
          actions: <Widget>[
            FlatButton(
              onPressed: () async {
                await HelpDesk.sync();
                _updateHelpDesk();
              },
              child: Icon(
                Icons.update,
                color: Colors.white,
              ),
            )
          ],
        ),
        // Enable menu
        // drawer: AppDrawer(
        //   profile: _profile,
        // ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _updateHelpDesk,
              child: Container(
                child: FutureBuilder(
                  future: helpDeskProcessed,
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
                        var listHelpDesks = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listHelpDesks.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              HelpDesk helpDesk = listHelpDesks[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return PageHelpdeskDetail(
                                        helpdesk: helpDesk,
                                        profile: _profile,
                                      );
                                    })).whenComplete(() => _updateHelpDesk());
                                  },
                                  child: ListTile(
                                    title: Text(
                                      helpDesk.title,
                                    ),
                                    isThreeLine: true,
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(helpDesk.mobID.toString()),
                                    ),
                                    subtitle: Text(
                                      helpDesk.body,
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
              onRefresh: _updateHelpDesk,
              child: Container(
                child: FutureBuilder(
                  future: helpDeskUnprocessed,
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
                        var listHelpDesks = snapshot.data;
                        return Center(
                          child: ListView.separated(
                            itemCount: listHelpDesks.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              HelpDesk helpDesk = listHelpDesks[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return PageHelpdeskDetail(
                                        helpdesk: helpDesk,
                                        profile: _profile,
                                      );
                                    })).whenComplete(() => _updateHelpDesk());
                                  },
                                  child: ListTile(
                                    title: Text(
                                      helpDesk.title,
                                    ),
                                    isThreeLine: true,
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(helpDesk.mobID.toString()),
                                    ),
                                    subtitle: Text(
                                      helpDesk.body,
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
            Navigator.of(context)
                .pushNamed(
                  '/helpdeskdetail',
                  arguments: _args,
                )
                .whenComplete(() => _updateHelpDesk());
          },
        ),
      ),
    );
  }

//  Future<void> _refreshPayDesk() async {
//    _updateHelpDesk();
//  }
}
