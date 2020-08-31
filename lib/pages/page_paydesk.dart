import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:enterprise/widgets/notification_icon.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:enterprise/widgets/period_dialog.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
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

  Map<SortControllers, bool> _controllersMap;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<PayDesk>> payList;
  ScrollController _scrollController;

  DateTime _now;
  DateTime _firstDayOfMonth;

  bool _isVisible, _isSort;
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
    _controllersMap = PeriodDialog.setControllersMap();
    _isVisible = true;
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
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                PeriodDialog.showPeriodDialog(context, _dateFrom, _dateTo, _controllersMap).whenComplete(() => setState((){}));
                // _showPeriodDialog();
              }
          ),
          IconButton(
            onPressed: () async {
              await PayDesk.downloadAll();
              _load();
            },
            icon: Icon(
              Icons.sync,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await PayDesk.downloadAll();
          _load();
        },
        child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
          return PayDeskList(
            payList: payList,
            profile: _profile,
            scrollController: _scrollController,
            showStatus: false,
            dateFrom: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
            dateTo: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
            isReload: _controllersMap[SortControllers.reload],
            isPeriod: _controllersMap[SortControllers.period],
            isSort: _isSort,
            textIfEmpty: "Iнформацiя за ${_controllersMap[SortControllers.period] ? "перiод \n${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"} \nвiдсутня",
          );
        },),
      ),
      floatingActionButton: Visibility(
        visible: _isVisible,
        child: FloatingActionButton(
          backgroundColor: Colors.lightGreen,
          onPressed: () {
            RouteArgs _args = RouteArgs(profile: _profile, type: PayDeskTypes.costs);
            Navigator.pushNamed(context, "/paydesk/detail", arguments: _args).whenComplete(() => _load());
          },
          child: Icon(Icons.add),
        ),
      ),
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
    payList = PayDeskDAO().getUnDeleted();
    if((await payList).length==0){
      ShowSnackBar.show(_scaffoldKey, "Отримання даних", Colors.blueAccent);
      if(await PayDesk.downloadAll()) {
        payList = PayDeskDAO().getUnDeleted();
      }
    }
    await UserGrants.sync(scaffoldKey: _scaffoldKey);
    _setCount(payList);
    setState(() {});
  }
}
