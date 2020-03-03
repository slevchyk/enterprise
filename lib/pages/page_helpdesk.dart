import 'package:enterprise/database/profile_dao.dart';
import 'package:flutter/material.dart';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/profile.dart';

class PageHelpdesk extends StatefulWidget {
  @override
  _PageHelpdeskState createState() => _PageHelpdeskState();
}

class _PageHelpdeskState extends State<PageHelpdesk> {
  Profile profile;
  Future<List<Helpdesk>> helpdeskprocessed;
  Future<List<Helpdesk>> helpdeskunprocessed;
  @override
  void initState() {
    super.initState();
    getprofileByUuid();
    helpdeskprocessed = getHelpdesk(HELPDESK_STATUS_PROCESSED);
    helpdeskunprocessed = getHelpdesk(HELPDESK_STATUS_UNPROCESSED);
  }

  Future<List<Helpdesk>> getHelpdesk(String Status) async {
    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";
    return HelpdeskDAO().getByUserIdType(userID, Status);
  }

  getprofileByUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(KEY_USER_ID) ?? "";
    profile = await ProfileDAO().getByUserId(userID);
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
          profile: profile,
        ),
        body: TabBarView(
          children: [
            Container(
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
                      var listChanneles = snapshot.data;
                      return Center(
                        child: ListView.separated(
                          itemCount: listChanneles.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            Helpdesk helpdesk = listChanneles[index];
                            return SingleChildScrollView(
                              child: ListTile(
                                title: Text(
                                  helpdesk.title,
                                  //   style: TextStyle(
                                  //     fontWeight: helpdesk.starredAt == null
                                  //         ? FontWeight.normal
                                  //         : FontWeight.bold,
                                  //  ),
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
                      var listChanneles = snapshot.data;
                      return Center(
                        child: ListView.separated(
                          itemCount: listChanneles.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            Helpdesk helpdesk = listChanneles[index];
                            return SingleChildScrollView(
                              child: ListTile(
                                title: Text(
                                  helpdesk.title,
                                  //  style: TextStyle(
                                  //    fontWeight: helpdesk.starredAt == null
                                  //        ? FontWeight.normal
                                  //        : FontWeight.bold,
                                  //  ),
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
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(
              '/helpdeskdetail',
              arguments: "",
            );
          },
        ),
      ),
    );
  }
}
