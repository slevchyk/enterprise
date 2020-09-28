import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:enterprise/widgets/notification_icon.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:enterprise/widgets/period_dialog.dart';
import 'package:enterprise/widgets/sort_widget.dart';
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

  List<PayOffice> _listPayOffice;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<PayDesk>> _payList;
  Future<List<PayDesk>> _payListToShow;

  ScrollController _scrollController;
  ScrollController _scrollControllerPayOffice;

  DateTime _now;
  DateTime _firstDayOfMonth;

  bool _isVisible;
  int _statusCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => UserGrants.sync(scaffoldKey: _scaffoldKey).whenComplete(() => _load(action: false)));
    _now = DateTime.now();
    _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
    _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
    _profile = widget.profile;
    _payList = PayDeskDAO().getUnDeleted();
    _load(action: false);
    _controllersMap = PeriodDialog.setControllersMap();
    _isVisible = true;
    _scrollController = ScrollController();
    _scrollControllerPayOffice = ScrollController();
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
            icon: Icon(Icons.sort),
            onPressed: () {
              SortWidget.sortPayOffice(_listPayOffice, _scrollControllerPayOffice, _callBack ,context);
            },
          ),
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                PeriodDialog.showPeriodDialog(context, _dateFrom, _dateTo, _controllersMap).whenComplete(() => setState((){}));
              }
          ),
          IconButton(
            onPressed: () {
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
        onRefresh: _load,
        child: OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
          return PayDeskList(
            payList: _payListToShow,
            profile: _profile,
            scrollController: _scrollController,
            showStatus: false,
            dateFrom: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
            dateTo: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
            isReload: _controllersMap[SortControllers.reload],
            isPeriod: _controllersMap[SortControllers.period],
            isSort: true,
            textIfEmpty: "Iнформацiя за ${_controllersMap[SortControllers.period] ? "перiод \n${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"} \nвiдсутня",
            callback: _load,
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

  Future<List<PayDesk>> _sort() async {
    List<PayDesk> _input = await _payList;
    List<PayDesk> _toReturn = [];
    if(_listPayOffice.where((payOffice) => payOffice.isVisible && payOffice.isShow).length!=0){
      _input.forEach((payDesk) {
        var where = _listPayOffice.where((payOffice) => payOffice.isVisible && payOffice.isShow);
        if(where!=null){
          if(where.first.accID == payDesk.fromPayOfficeAccID){
            _toReturn.add(payDesk);
          }
        }
      });
    } else {
      _toReturn = [];
    }
    return _toReturn;
  }

  Future<void> _load({bool action}) async {
    _statusCount = (await PayDeskDAO().getTransfer()).length;
    _listPayOffice = await ImplPayOfficeDAO().getUnDeleted();
    if(action==null){
      await UserGrants.sync(scaffoldKey: _scaffoldKey);
      _payList = PayDeskDAO().getUnDeleted();
    } else {
      _payList = PayDeskDAO().getUnDeleted();
    }
    _payListToShow = _payList;
    setState(() {});
  }

  void _callBack(){
    _payListToShow = _sort();
    setState(() {});
  }

}
