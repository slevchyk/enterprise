
import 'package:date_format/date_format.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class PayDeskList extends StatelessWidget {
  final Future<List<PayDesk>> payList;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool isReload;
  final bool isPeriod;
  final bool isSort;
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
    this.dateFrom,
    this.dateTo,
    this.isReload = false,
    this.isPeriod = false,
    this.isSort = false,
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
            if(isSort){
              if(dateTo!=null && !isPeriod){
                _payList = _payList.where((element) => DateFormat('yyyy-MM-dd').parse(element.documentDate.toString()).isAtSameMomentAs(dateTo)).toList();
              }
              if(dateFrom!=null && isPeriod){
                _payList = _payList.where((element) {
                  var parse = DateFormat('yyyy-MM-dd').parse(element.documentDate.toString());
                  return parse.isBefore(dateTo) && parse.isAfter(dateFrom) || parse.isAtSameMomentAs(dateTo) || parse.isAtSameMomentAs(dateFrom);
                }).toList();
              }
            }
            if(_payList!=null){
              _payList.sort((first, second) =>
                  second.documentDate.compareTo(first.documentDate));
            }
            return _setEmptyText(_payList) ?
            Container(
              child: Center(
                child: Text(textIfEmpty,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),),) :
            ListView.separated(
              controller: scrollController,
              physics: physics,
              shrinkWrap: shrinkWrap,
              itemCount: _payList == null ? 0 : _payList.length,
              itemBuilder: (BuildContext context, int index) {
                if(index==0){
                  return Column(
                    children: <Widget>[
                      isSort ? isReload ? Container() : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 10),
                        child: Text("За ${isPeriod ? "перiод ${formatDate(dateFrom, [dd, '.', mm, '.', yyyy])} - ${formatDate(dateTo, [dd, '.', mm, '.', yyyy])}" : "${formatDate(dateTo, [dd, '.', mm, '.', yyyy])}"}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ) : Container(),
                      _setSeparatorWithDate(_payList[index].documentDate),
                      _listBuilder(_payList, index, context)
                    ],
                  );
                } else if(_payList[index].payDeskType != 2
                    || !_payList[index].isChecked || _payList[index].isChecked){
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
                showPercent ?
                Text("${_payList[index].percentage.toStringAsFixed(2)} %",
                  style: TextStyle(fontSize: 15, color: _setColor(_payList[index].payDeskType)),) :
                Container() ,
                _payList[index].filesQuantity != null && _payList[index].filesQuantity != 0 && showFileAttach ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(_payList[index].filesQuantity.toString()),
                    Icon(Icons.attach_file, size: 20,),
                  ],) :
                showStatus || !showPercent && _payList[index].payDeskType==2 ?
                SizedBox(height: 20,) :
                Container(),
                showStatus || !showPercent && _payList[index].payDeskType==2 ?
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
        return Colors.red;
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
    if(_details==null){
      return Container();
    }

    return Container(
      child: Text(
        _details,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
    );
  }

  bool _setEmptyText(List<PayDesk> input) {
    if(textIfEmpty != null && input == null || input.isEmpty){
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