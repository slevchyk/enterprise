import 'dart:async';

import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/notification_icon.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  ScrollController _scrollController;
  bool _isVisible;
  int _statusCount;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _load();
    _isVisible = true;
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
          print(_isVisible);
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
          IconButton(
            onPressed: () async {
              FocusScope.of(this.context).unfocus();
              DateTime picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year - 1),
                  initialDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1));
              if (picked != null){
                RouteArgs args = RouteArgs(
                  profile: _profile,
                  dateSort: picked,
                );
                Navigator.pushNamed(context, "/paydesk/sort", arguments: args);
              }
            },
            icon: Icon(
              Icons.calendar_today,
              size: 23,
              color: Colors.white,
            ),
          ),
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: PayDeskList(
          payList: payList,
          profile: _profile,
          scrollController: _scrollController,
          showStatus: false,
        ),
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
