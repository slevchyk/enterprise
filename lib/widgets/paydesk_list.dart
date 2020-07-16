
import 'package:date_format/date_format.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PayDeskList extends StatelessWidget {
  final Future<List<PayDesk>> payList;
  final DateTime dateSort;
  final Profile profile;
  final ScrollController scrollController;
  final String textIfEmpty;
  final bool showStatus;
  final amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');
  final physics;
  final bool shrinkWrap;
  final bool showPercent;
  final bool showFileAttach;

  PayDeskList({
    @required this.payList,
    @required this.profile,
    this.dateSort,
    this.scrollController,
    this.textIfEmpty,
    this.showStatus = true,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.shrinkWrap = false,
    this.showPercent = false,
    this.showFileAttach = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            _payList.sort((first, second) =>
                second.documentDate.compareTo(first.documentDate));
            return _setEmptyText(_payList) ?
            Container(
              child: Center(
                child: Text(textIfEmpty),),) :
            ListView.separated(
              controller: scrollController,
              physics: physics,
              shrinkWrap: shrinkWrap,
              itemCount: _payList == null ? 0 : _payList.length,
              itemBuilder: (BuildContext context, int index) {
                if(index==0){
                  return Column(
                    children: <Widget>[
                      _setSeparatorWithDate(_payList[index].documentDate),
                      _listBuilder(_payList, index, context)
                    ],
                  );
                } else if(_payList[index].payDeskType != 2
                    || _payList[index].isChecked){
                  return _listBuilder(_payList, index, context);
                } else {
                  return Container();
                }
              },
              separatorBuilder: (BuildContext context, int index) {
                if(_payList[index].documentDate.day.compareTo(_payList[index+1].documentDate.day)==1
                    || _payList[index+1].documentDate.day.compareTo(_payList[index].documentDate.day)==1
                ){
                  return _setSeparatorWithDate(_payList[index+1].documentDate);
                } else {
                  return Container();
                }
              },
            );
          default:
            return Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }

  Widget _listBuilder(List<PayDesk> _payList ,int index, BuildContext context){
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return PagePayDeskDetail(
            payDesk: _payList[index],
            profile: profile,
          );
        }));
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _getPayDeskDetailsLine1(_payList[index]),
                    ],
                  ),
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
                showPercent ?
                Text("${_payList[index].percentage.toStringAsFixed(2)} %",
                  style: TextStyle(fontSize: 15, color: _setColor(_payList[index].payDeskType)),) :
                Container() ,
                _payList[index].filesQuantity != null && _payList[index].filesQuantity != 0 && showFileAttach ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(_payList[index].filesQuantity.toString()),
                    Icon(Icons.attach_file, size: 23,),
                  ],) :
                showStatus || _payList[index].payDeskType==2 ?
                SizedBox(height: 23,) :
                Container(),
                showStatus || _payList[index].payDeskType==2 ?
                _getStatus(_payList[index].isChecked) :
                Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _setColor(int typeID){
    PayDeskTypes _type = PayDeskTypes.values[typeID];
    switch (_type) {
      case PayDeskTypes.costs:
        return Colors.red;
        break;
      case PayDeskTypes.income:
        return Colors.green;
        break;
      case PayDeskTypes.transfer:
        return Colors.blue;
        break;
      default:
        return Colors.black;
    }
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
        _details = "${_payDesk.toPayOfficeName}";
        break;
    }

//    if (_details.length > 25) {
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

  bool _setEmptyText(List<PayDesk> input) {
    if(textIfEmpty != null && input.isEmpty){
      return true;
    }
    return false;
  }

  Widget _setSeparatorWithDate(DateTime input){
    String dayName;
    String monthName;
    switch(input.weekday){
      case 1:
        dayName = "Понедiлок";
        break;
      case 2:
        dayName = "Вiвторок";
        break;
      case 3:
        dayName = "Середа";
        break;
      case 4:
        dayName = "Четвер";
        break;
      case 5:
        dayName = "П'ятниця";
        break;
      case 6:
        dayName = "Субота";
        break;
      case 7:
        dayName = "Недiля";
        break;
    }

    switch(input.month){
      case 1:
        monthName = "січня";
        break;
      case 2:
        monthName = "лютого";
        break;
      case 3:
        monthName = "березня";
        break;
      case 4:
        monthName = "квітня";
        break;
      case 5:
        monthName = "травня";
        break;
      case 6:
        monthName = "червня";
        break;
      case 7:
        monthName = "липня";
        break;
      case 8:
        monthName = "серпня";
        break;
      case 9:
        monthName = "вересня";
        break;
      case 10:
        monthName = "жовтня";
        break;
      case 11:
        monthName = "листопада";
        break;
      case 12:
        monthName = "грудня";
        break;

    }
    return Container(
      child: Row(children: <Widget>[
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
        Text("$dayName, ${input.day} $monthName, ${input.year}"),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Divider(
                color: Colors.black,
                height: 36,
              )),
        ),
      ]),
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

    amountFormatter.text = _payDesk.amount.toStringAsFixed(2);

    return Text(
      '${_payDesk.payDeskType == 0 ? '-' : ''} '
          '${amountFormatter.text} '
          '${CURRENCY_SYMBOL[_payDesk.currencyCode] == null ? '' : CURRENCY_SYMBOL[_payDesk.currencyCode]}',
      style: TextStyle(color: textColor, fontSize: 18.0),
      textAlign: TextAlign.right,
    );
  }

  Widget _getStatus(bool paymentStatus){
    switch (paymentStatus){
      case true:
        return Text("Пiдтверженний", style: TextStyle(color: Colors.green, fontSize: 10),);
        break;
      case false:
        return Text("Очікує пiдтвердження", style: TextStyle(color: Colors.red, fontSize: 10),);
        break;
      default:
        return Text("Очікує пiдтвердження", style: TextStyle(color: Colors.red, fontSize: 10),);
    }
  }
}