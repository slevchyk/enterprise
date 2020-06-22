import 'dart:async';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/expense_dao.dart';
import 'package:enterprise/database/paydesk_dao.dart';
import 'package:enterprise/database/purse_dao.dart';
import 'package:enterprise/models/expense.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/purse.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

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
  List<Purse> _purseList;
  List<Expense> _expenseList;
  ScrollController _scrollController;
  bool _isVisible;

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
          setState(() {
            _isVisible = true;
          });
          break;
        case ScrollDirection.reverse:
          setState(() {
            _isVisible = false;
          });
          break;
        case ScrollDirection.idle:
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
          FlatButton(
            onPressed: () async {
              await PayDesk.sync();
              await Expense.sync();
              await Purse.sync();
              _load();
            },
            child: Icon(
              Icons.update,
              color: Colors.white,
            ),
          )
        ],
      ),
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
                List<PayDesk> _payList = snapshot.data;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _payList == null ? 0 : _payList.length,
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
                          title: _payList[index].paymentType == 2
                              ? Text("Переміщення")
                              : _setText(_payList[index], false),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  _setText(_payList[index], true),
                                  _setIcon(_payList[index].paymentType),
                                  _payList[index].paymentType == 2
                                      ? _payList[index].amount <= 100000000
                                      ? _setText(_payList[index], false)
                                      : Container()
                                      : Container(),
                                ],
                              ),
                              Text('${formatDate(
                                _payList[index].createdAt,
                                [dd, '.', mm, '.', yy, ' ', HH, ':', nn],
                              )}'),
                            ],
                          ),
                          trailing: _payList[index].filesQuantity == null ||
                              _payList[index].filesQuantity == 0
                              ? Column(
                            children: <Widget>[
                              _getAmount(_payList[index].paymentType,
                                  _payList[index].amount),
                            ],
                          ) : Column(
                            children: <Widget>[
                              Container(
                                width: 120,
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.attach_file),
                                    _getAmount(_payList[index].paymentType,
                                        _payList[index].amount),
                                  ],
                                ),
                              ),
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
      floatingActionButton: Visibility(
        visible: _isVisible,
        child: FloatingActionButton(
          heroTag: "tag",
          onPressed: () {
            RouteArgs _args = RouteArgs(profile: _profile);
            Navigator.pushNamed(context, "/paydesk/detail", arguments: _args)
                .whenComplete(() => _load());
          }, child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _setText(PayDesk payDesk, bool isFront){
   int typeID = payDesk.paymentType;
   if(typeID == 2){
     Purse where;
     isFront ?
     where = _purseList.where((element) =>
     element.mobID == payDesk.purseID).toList().first
         : where = _purseList.where((element) =>
     element.mobID == payDesk.toWhomID).toList().first;
     if(where.name.length<=12){
       return Text('${where.name}');
     }
     return Text('${where.name.substring(0, 10)}...'
         '${where.name.substring(where.name.length-1)}');
   } else {
     var where;
     isFront ?
     where = _purseList.where((element) =>
     element.mobID == payDesk.purseID).toList().first
         : where = _expenseList.where((element) =>
     element.mobID == payDesk.toWhomID).toList().first;
     if(where.name.length<=12){
       return Text('${where.name}');
     }
     return Text('${where.name.substring(0, 15)}');
   }
  }

  Widget _getAmount(int typeID, double amount){
    Types _type = Types.values[typeID];
    Color textColor;
    switch(_type){
      case Types.expense:
        textColor = Colors.red;
        break;
      case Types.receiving:
        textColor = Colors.green;
        break;
      case Types.transfer:
        textColor = Colors.black;
        break;
      default:
        textColor = Colors.black;
    }
    var flutterMoneyFormatter = FlutterMoneyFormatter(
        amount: amount,
        settings: MoneyFormatterSettings(
          thousandSeparator: ' ',
          decimalSeparator: ',',
          fractionDigits: 2,
        ));

    return Text('${typeID == 0 ? '-': ''} '
        '${flutterMoneyFormatter.output.nonSymbol} '
        '${String.fromCharCode(0x000020B4)}', style: TextStyle(
        color: textColor, fontSize: 20.0),);
  }

  Widget _setIcon(int typeID){
    Types _type = Types.values[typeID];
    switch(_type){
      case Types.expense:
        return Icon(Icons.call_received, color: Colors.red,);
        break;
      case Types.receiving:
        return Icon(Icons.call_made, color: Colors.green,);
        break;
      case Types.transfer:
        return Icon(Icons.arrow_forward, color: Colors.blue,);
        break;
      default:
        return Icon(Icons.error);
    }
  }

  Future<void> _load() async {
    _purseList = await PurseDAO().getAll();
    _expenseList = await ExpenseDAO().getAll();
    setState(() {
      payList = PayDeskDAO().getUnDeleted();
    });
  }
}