import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PagePayDeskConfirm extends StatefulWidget {
  final Profile profile;

  PagePayDeskConfirm({
    @required this.profile,
  });

  @override
  _PagePayDeskConfirmState createState() => _PagePayDeskConfirmState();

}

class _PagePayDeskConfirmState extends State<PagePayDeskConfirm>{
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
        title: Text('Пiдтверження'),
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return PayDeskList(
            payList: payList,
            profile: _profile,
            showStatus: false,
            textIfEmpty: "Немає платежiв для пiдтверження",
            callback: _load,
          );
        },
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      payList = PayDeskDAO().getTransfer();
    });

  }
}