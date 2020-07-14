import 'package:date_format/date_format.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PagePayDeskSort extends StatefulWidget {
  final Profile profile;
  final DateTime dateSort;

  PagePayDeskSort({
    this.profile,
    this.dateSort,
  });

  @override
  _PagePayDeskSortState createState() => _PagePayDeskSortState();
}

class _PagePayDeskSortState extends State<PagePayDeskSort>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<PayDesk>> _payList;
  Profile _profile;
  DateTime _dateSort;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _dateSort = widget.dateSort;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Пошук по датi: ${formatDate(
          _dateSort,
          [dd, '.', mm, '.', yyyy],
        )}"),
      ),
      body: PayDeskList(
        profile: _profile,
        payList: _payList,
        dateSort: _dateSort,
        showStatus: false,
        textIfEmpty: "Платежiв за датою ${formatDate(
          _dateSort,
          [dd, '.', mm, '.', yyyy],
        )} не знайдено",
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _payList = PayDeskDAO().getByDate(formatDate(
        _dateSort,
        [yyyy, '-', mm, '-', dd],
      ));
    });
  }

}