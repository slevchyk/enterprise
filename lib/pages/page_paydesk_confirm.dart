import 'package:date_format/date_format.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

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
      body: FutureBuilder(
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
              return _payList.length==0 ?
              Container(
                child: Center(
                  child: Text("Немає платежiв для пiдтверження"),),) :
              ListView.builder(
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
                        title: _payList[index].payDeskType == 2
                            ? _getPayDeskDetailsTransfer(_payList[index], context)
                            : _getPayDeskDetailsLine2(_payList[index], context),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                _setIcon(_payList[index].payDeskType),
                                _getPayDeskDetailsLine1(_payList[index], context),
                              ],
                            ),
                            Text('${formatDate(
                              _payList[index].documentDate,
                              [dd, '.', mm, '.', yy, ' ', HH, ':', nn],
                            )}'),
                          ],
                        ),
                        trailing: Container(
                          width: MediaQuery.of(context).size.width/2.9,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _getAmount(_payList[index]),
                              _payList[index].filesQuantity != null && _payList[index].filesQuantity != 0 ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(_payList[index].filesQuantity.toString()),
                                  Icon(Icons.attach_file, size: 23,),
                                ],) :
                              SizedBox(height: 23,),
                              _getStatus(_payList[index].isChecked),
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
    );
  }

  Widget _getPayDeskDetailsLine1(PayDesk _payDesk, BuildContext context) {
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
        _details = "${_payDesk.toPayOfficeName}";
        break;
    }

//    if (_details.length > 25) {
//      _details = _details.substring(0, 24) + '...';
//    }

    return Container(
      width: MediaQuery.of(context).orientation==Orientation.portrait ? 150 : 400,
      child: Text(
        _details,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
    );
  }

  Widget _getPayDeskDetailsLine2(PayDesk _payDesk, BuildContext context) {
    String _details;
    PayDeskTypes _payDeskType;

    _payDeskType = PayDeskTypes.values[_payDesk.payDeskType];
    switch (_payDeskType) {
      case PayDeskTypes.costs:
        _details = _payDesk.costItemName;
        break;
      case PayDeskTypes.income:
        _details = _payDesk.incomeItemName;
        break;
      case PayDeskTypes.transfer:
        _details = _payDesk.toPayOfficeName;
        break;
    }

//    if (_details.length > 25 && MediaQuery.of(context).orientation==Orientation.portrait) {
//      _details = _details.substring(0, 24) + '...';
//    }

    return Container(
      child: Text(
        _details,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
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
    final amountFormatter =
    MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

    amountFormatter.text = _payDesk.amount.toStringAsFixed(2);

    return Text(
      '${_payDesk.payDeskType == 0 ? '-' : ''} '
          '${amountFormatter.text} '
          '${CURRENCY_SYMBOL[_payDesk.currencyCode] == null ? '' : CURRENCY_SYMBOL[_payDesk.currencyCode]}',
      style: TextStyle(color: textColor, fontSize: 18.0,), maxLines: 2,
      textAlign: TextAlign.right,
    );
  }

  _getStatus(bool paymentStatus){
    switch (paymentStatus){
      case true:
        return Text("Пiдтверженний", style: TextStyle(color: Colors.green, fontSize: 10),);
        break;
      case false:
        return Text("Очікує пiдтвердження", style: TextStyle(color: Colors.red, fontSize: 10),);
        break;
    }
  }

  Future<void> _load() async {
    setState(() {
      payList = PayDeskDAO().getTransfer();
    });

  }

  Widget _getPayDeskDetailsTransfer(PayDesk payDesk, BuildContext context){
    String _details = "";
    PayDeskTypes _payDeskType;

    _payDeskType = PayDeskTypes.values[payDesk.payDeskType];
    if(_payDeskType==PayDeskTypes.transfer){
      _details = "${payDesk.fromPayOfficeName}";
      return Text(
        _details,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      );
    }
    return Container();
  }

}