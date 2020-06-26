import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Future<List<CostItem>> _costItemList;
  Future<List<IncomeItem>> _incomeItemList;
  Future<List<PayOffice>> _payOfficesList;
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return PagePayDeskDetail(
                            payDesk: _payList[index],
                            profile: _profile,
                          );
                        })).whenComplete(() => _load());
                      },
                      child: Card(
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(PAY_DESK_TYPES_ALIAS[PayDeskTypes.values[_payList[index].payDeskType]]), //
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  _setIcon(_payList[index].payDeskType),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('${formatDate(
                                        _payList[index].createdAt,
                                        [dd, '.', mm, '.', yy, ' ', HH, ':', nn],
                                      )}'),
                                      _getPayDeskDetailsLine1(_payList[index]),
                                      _getPayDeskDetailsLine2(_payList[index]),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                _getAmount(_payList[index]),
                                Visibility(
                                  visible: _payList[index].filesQuantity != null && _payList[index].filesQuantity != 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(_payList[index].filesQuantity.toString()),
                                      Icon(Icons.attach_file),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
            Navigator.pushNamed(context, "/paydesk/detail", arguments: _args).whenComplete(() => _load());
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _getPayDeskDetailsLine1(PayDesk _payDesk) {
    String _details = "";
    PayDeskTypes _payDeskType;

    _payDeskType = PayDeskTypes.values[_payDesk.payDeskType];
    switch (_payDeskType) {
      case PayDeskTypes.costs:
        _details = "З ${_payDesk.fromPayOfficeName}";
        break;
      case PayDeskTypes.income:
        _details = "До ${_payDesk.fromPayOfficeName}";
        break;
      case PayDeskTypes.transfer:
        _details = "З ${_payDesk.fromPayOfficeName}";
        break;
    }

    if (_details.length > 25) {
      _details = _details.substring(0, 24) + '...';
    }

    return Container(
      child: Text(
        _details,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
    );
  }

  Widget _getPayDeskDetailsLine2(PayDesk _payDesk) {
    String _details = "";
    PayDeskTypes _payDeskType;

    _payDeskType = PayDeskTypes.values[_payDesk.payDeskType];
    switch (_payDeskType) {
      case PayDeskTypes.costs:
        _details = "По ${_payDesk.costItemName}";
        break;
      case PayDeskTypes.income:
        _details = "По ${_payDesk.incomeItemName}";
        break;
      case PayDeskTypes.transfer:
        _details = "До: ${_payDesk.toPayOfficeName}";
        break;
    }

    if (_details.length > 25) {
      _details = _details.substring(0, 24) + '...';
    }

    return Container(
      child: Text(
        _details,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
    );
  }

//  Widget _setText(PayDesk payDesk, bool isFront) {
//    int typeID = payDesk.payDeskType;
//    if (typeID == 2) {
//      Purse where;
//      isFront
//          ? where = _purseList.where((element) => element.mobID == payDesk.purseID).toList().first
//          : where = _purseList.where((element) => element.mobID == payDesk.toWhomID).toList().first;
//      if (where.name.length <= 12) {
//        return Text('${where.name}');
//      }
//      return Text('${where.name.substring(0, 10)}...'
//          '${where.name.substring(where.name.length - 1)}');
//    } else {
//      var where;
//      isFront
//          ? where = _purseList.where((element) => element.mobID == payDesk.purseID).toList().first
//          : where = _expenseList.where((element) => element.mobID == payDesk.toWhomID).toList().first;
//      if (where.name.length <= 12) {
//        return Text('${where.name}');
//      }
//      return Text('${where.name.substring(0, 15)}');
//    }
//  }

  Widget _getAmount(PayDesk _payDesk) {
    PayDeskTypes _type = PayDeskTypes.values[_payDesk.payDeskType];
    Color textColor;
    switch (_type) {
      case PayDeskTypes.costs:
        textColor = Colors.red;
        break;
      case PayDeskTypes.income:
        textColor = Colors.green;
        break;
      case PayDeskTypes.transfer:
        textColor = Colors.black;
        break;
      default:
        textColor = Colors.black;
    }
    var flutterMoneyFormatter = FlutterMoneyFormatter(
        amount: _payDesk.amount,
        settings: MoneyFormatterSettings(
          thousandSeparator: ' ',
          decimalSeparator: ',',
          fractionDigits: 2,
        ));

    return Text(
      '${_payDesk.payDeskType == 0 ? '-' : ''} '
      '${flutterMoneyFormatter.output.nonSymbol} '
      '${CURRENCY_SYMBOL[_payDesk.currencyCode] == null ? '' : CURRENCY_SYMBOL[_payDesk.currencyCode]}',
      style: TextStyle(color: textColor, fontSize: 18.0),
      textAlign: TextAlign.right,
    );
  }

  Widget _setIcon(int typeID) {
    PayDeskTypes _type = PayDeskTypes.values[typeID];
    switch (_type) {
      case PayDeskTypes.costs:
        return Icon(
          Icons.call_received,
          color: Colors.red,
        );
        break;
      case PayDeskTypes.income:
        return Icon(
          Icons.call_made,
          color: Colors.green,
        );
        break;
      case PayDeskTypes.transfer:
        return Icon(
          Icons.arrow_forward,
          color: Colors.blue,
        );
        break;
      default:
        return Icon(Icons.error);
    }
  }

  Future<void> _load() async {
    setState(() {
      payList = PayDeskDAO().getUnDeleted();
    });
  }
}
