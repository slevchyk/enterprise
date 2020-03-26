import 'dart:async';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/paydesk_dao.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class PagePayDesk extends StatefulWidget {
  final Profile profile;

  PagePayDesk({
    this.profile,
  });

  @override
  _PagePayDeskState createState() => _PagePayDeskState();
}

class _PagePayDeskState extends State<PagePayDesk> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Profile _profile;
  Future<List<PayDesk>> payList;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Каса'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              await PayDesk.sync();
              _load();
            },
            child: Icon(
              Icons.update,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Scaffold(
        body: RefreshIndicator(
          onRefresh: _load,
          child: FutureBuilder(
            future: payList,
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
                  var _payList = snapshot.data;
                  return ListView.builder(
                    itemCount: _payList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return PagePayDeskDetail(
                              payDesk: _payList[index],
                              profile: _profile,
                            );
                          })).whenComplete(() => _load());
                        },
                        child: Card(
                          child: ListTile(
                            isThreeLine: true,
                            leading: CircleAvatar(
                                child: Text(_payList[index].mobID.toString())),
                            title: Text('Призначення: '
                                '${_payList[index].payment}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Сума:  '
                                    '${_payList[index].amount.toStringAsFixed(2)} '
                                    '${String.fromCharCode(0x000020B4)}'),
                                _payList[index].documentNumber == 0
                                    ? Text('Номер не вказаний')
                                    : Text(
                                        '№: ${_payList[index].documentNumber}'),
                                _payList[index].documentDate == null
                                    ? Text('Дата не вказана')
                                    : Text('Від ${formatDate(
                                        _payList[index].documentDate,
                                        [dd, '-', mm, '-', yyyy],
                                      )}'),
                              ],
                            ),
                            trailing: _payList[index].filesQuantity == null ||
                                    _payList[index].filesQuantity == 0
                                ? SizedBox()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.attach_file),
                                      Text(_payList[index]
                                          .filesQuantity
                                          .toString()),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                default:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            RouteArgs _args = RouteArgs(profile: _profile);
            Navigator.pushNamed(context, "/paydesk/detail", arguments: _args)
                .whenComplete(() => _load());
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      payList = PayDeskDAO().getUnDeleted();
    });
  }
}
