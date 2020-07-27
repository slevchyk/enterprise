import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/notification_icon.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Profile _profile;

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<PayDesk>> payList;
  ScrollController _scrollController;

  DateTime _now;
  DateTime _firstDayOfMonth;

  bool _isVisible, _isReload, _isPeriod, _isSort;
  int _statusCount;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
    _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
    _profile = widget.profile;
    _load();
    _isVisible = true;
    _isReload = false;
    _isPeriod = true;
    _isSort = true;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      switch (_scrollController.position.userScrollDirection) {
        case ScrollDirection.forward:
          if(!_isVisible){
            setState(() {
              _isVisible = true;
            });
          }
          break;
        case ScrollDirection.reverse:
          if(_isVisible){
            setState(() {
              _isVisible = false;
            });
          }
          break;
        case ScrollDirection.idle:
          if(!_isVisible){
            setState(() {
              _isVisible = true;
            });
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Каса'),
        actions: <Widget>[
          IconWithNotification(
            iconData: Icons.assignment_turned_in,
            notificationCount: _statusCount,
            onTap: (){
              RouteArgs args = RouteArgs(
                profile: _profile,
              );
              Navigator.pushNamed(context, "/paydesk/confirm", arguments: args)
                  .whenComplete(() => _load());
            },
          ),
          IconButton(
            onPressed: () async {
              await PayDesk.sync();
              _load();
            },
            icon: Icon(
              Icons.update,
              size: 28,
              color: Colors.white,
            ),
          ),
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                _showPeriodDialog();
              }
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
          return PayDeskList(
            payList: payList,
            profile: _profile,
            scrollController: _scrollController,
            showStatus: false,
            dateFrom: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
            dateTo: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
            isReload: _isReload,
            isPeriod: _isPeriod,
            isSort: _isSort,
            textIfEmpty: "Iнформацiя за ${_isPeriod ? "перiод \n${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"} \nвiдсутня",
          );
        },),
      ),
      floatingActionButton: Visibility(
        visible: _isVisible,
        child: FloatingActionButton(
          onPressed: () {
            RouteArgs _args = RouteArgs(profile: _profile);
            Navigator.pushNamed(context, "/paydesk/detail", arguments: _args).whenComplete(() => _load());
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future _showPeriodDialog() {
    return showDialog(
        context: context,
        builder: (context) => GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        color: Colors.white
                    ),
                    width: MediaQuery.of(context).size.width/1.3,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20.0),
                      children: <Widget>[
                        Text("Встановити період", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text("Дата вiд (включно)"),
                        ),
                        InkWell(
                          onTap: () async {
                            DateTime picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(_now.year - 1),
                                initialDate: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
                                lastDate: DateTime(_now.year + 1));

                            if (picked != null) {
                              setState(() {
                                _dateFrom.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                              });
                            }
                          },
                          child: TextFormField(
                            controller: _dateFrom,
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Дата по (включно)"),
                        ),
                        InkWell(
                          onTap: () async {
                            DateTime picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(_now.year - 1),
                                initialDate: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
                                lastDate: DateTime(_now.year + 1));

                            if (picked != null) {
                              setState(() {
                                _dateTo.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                              });
                            }
                          },
                          child: TextFormField(
                            controller: _dateTo,
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Container(
                            margin: EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  child: Text("Застосувати період"),
                                  onPressed: () {
                                    setState(() {
                                      _isReload = false;
                                      _isPeriod = true;
                                      _isSort = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Сьогодні"),
                                  onPressed: () {
                                    setState(() {
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_now);
                                      _isReload = false;
                                      _isPeriod = false;
                                      _isSort = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Вчора"),
                                  onPressed: () {
                                    final _yesterday = DateTime(_now.year, _now.month, _now.day-1);
                                    setState(() {
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_yesterday);
                                      _isReload = false;
                                      _isPeriod = false;
                                      _isSort = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Поточний місяць"),
                                  onPressed: (){
                                    setState(() {
                                      _dateFrom.text = DateFormat('dd.MM.yyyy').format(_firstDayOfMonth);
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_now);
                                      _isReload = false;
                                      _isPeriod = true;
                                      _isSort = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Попередній місяць"),
                                  onPressed: (){
                                    final _firstDayOfPreviousMonth = DateTime(_now.year, _now.month-1, 1);
                                    final _lastDayOfPreviousMonth = DateTime(_now.year, _now.month, 0);
                                    setState(() {
                                      _dateFrom.text = DateFormat('dd.MM.yyyy').format(_firstDayOfPreviousMonth);
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_lastDayOfPreviousMonth);
                                      _isReload = false;
                                      _isPeriod = true;
                                      _isSort = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("За весь час"),
                                  onPressed: (){
                                    if(!_isReload){
                                      setState(() {
                                        _isReload = false;
                                        _isSort = false;
                                        _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
                                        _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              )
          ),
        )
    );
  }

  _setCount(Future<List<PayDesk>> input){
    input.then((list) => list.forEach((payDesk) {
      if(payDesk.payDeskType == 2 && !payDesk.isChecked){
        _statusCount++;
      }
    })).then((value) => setState(() {}));
  }

  Future<void> _load() async {
    _statusCount = 0;
    setState(() {
      payList = PayDeskDAO().getUnDeleted();
    });
    _setCount(payList);
  }
}
