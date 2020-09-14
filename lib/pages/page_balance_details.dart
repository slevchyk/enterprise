import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/models/analytic_data.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/result_types.dart';
import 'package:enterprise/widgets/charts_list.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:enterprise/widgets/period_dialog.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class PageBalanceDetails extends StatefulWidget{

  final Profile profile;
  final List<PayDesk> inputListPayDesk;
  final int currencyCode;
  final PayOffice payOffice;

  PageBalanceDetails({
    this.profile,
    this.inputListPayDesk,
    this.currencyCode,
    this.payOffice,
  });

  _PageBalanceDetailsState createState() => _PageBalanceDetailsState();

}

class _PageBalanceDetailsState extends State<PageBalanceDetails>{
  Profile _profile;

  final _amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  final _amountFormatterBalance =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  List<charts.Series<AnalyticData, String>> _seriesList;
  Map<dynamic, PayDesk> _preparedMap;

  Map<SortControllers, bool> _controllersMap;

  PayOffice _payOffice;

  bool _isDetail;

  int _currencyCode;
  double _sum, _sumCost, _sumIncome;

  List<PayDesk> _inputListPayDesk;
  List<PayDesk> _sortedPayDeskList;

  Future<List<CostItem>> _costItemsList;
  Future<List<IncomeItem>> _incomeItemsList;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _inputListPayDesk = widget.inputListPayDesk;
    _currencyCode = widget.currencyCode;
    _payOffice = widget.payOffice;
    _controllersMap = PeriodDialog.setControllersMap();
    _load();
    _isDetail = false;
  }

  void _infoDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        insetPadding: MediaQuery.of(context).orientation == Orientation.landscape
            ? EdgeInsets.only(top: 90, bottom: 90)
            : EdgeInsets.only(top: 270, bottom: 270),
        content: ListTile(
          title: Container(
            height: 65,
            child: Column(
              children: <Widget>[
                Text(
                  "Інформація по гаманцю",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  _payOffice.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Гаманець оновлено: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                _payOffice.updatedAt == null ? "Iнформацiя вiдсутня" : formatDate(_payOffice.updatedAt, [
                  dd, '.', mm, '.', yyyy,
                  ' ', HH, ':', nn, ':', ss,
                ]),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Гаразд'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iнформацiя по гаманцю \n${_payOffice.name}", overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                PeriodDialog.showPeriodDialog(context, _dateFrom, _dateTo, _controllersMap)
                    .whenComplete(() => setState(() {}));
              }
          ),
          IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                _infoDialog();
              })
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          _costItemsList,
          _incomeItemsList,
        ]),
          builder: (BuildContext context, AsyncSnapshot snapshot){
          switch(snapshot.connectionState) {
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
              if(!snapshot.hasData){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if(_controllersMap[SortControllers.reload]){
                _seriesList = _createSampleData(_inputListPayDesk, snapshot.data[0], snapshot.data[1], _currencyCode);
              } else {
                _seriesList = _createSampleData(
                  _inputListPayDesk,
                  snapshot.data[0],
                  snapshot.data[1],
                  _currencyCode,
                  first: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
                  second: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
                );
              }
              _amountFormatter.text = (_sumIncome - _sumCost).toStringAsFixed(2);
              _amountFormatterBalance.text = _payOffice.amount.toStringAsFixed(2);
              return _seriesList.first.data.isEmpty ?
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text("Нема iнформацiї по \n${_payOffice.name}", textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  _controllersMap[SortControllers.reload] ? Container() : Container(
                    alignment: Alignment.center,
                    child: Text("за ${_controllersMap[SortControllers.period] ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                ],
              ) : ListView(
                children: <Widget>[
                  SizedBox(height: 15,),
                  _controllersMap[SortControllers.reload] ? Container() : Container(
                    alignment: Alignment.center,
                    child: Text("Iнформацiя за ${_controllersMap[SortControllers.period] ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: 25,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: _setHeight()/1.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Stack(
                        children: <Widget>[
                          AnalyticChartsList().toShowCharts(_seriesList),
                          Container(
                            child: Center(
                              child: Text("${_sumIncome >= _sumCost && _preparedMap.keys.first.name!="Видаток" ? "" : "-" }"
                                  "${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}"
                                , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: (_sumIncome - _sumCost) > 0 ? Colors.green : Colors.red),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 15),
                      child: AnalyticChartsList().showChartsLabels(_currencyCode, _preparedMap, _amountFormatter, null, 3)
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text("Всього:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text("${_sumIncome >= _sumCost && _preparedMap.keys.first.name!="Видаток" ? "" : "-" }"
                                "${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}"
                              , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: (_sumIncome - _sumCost) > 0 ? Colors.green : Colors.red),),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text("Баланс:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                                "${_payOffice.amount.isNegative ? "-" : ""} ${_amountFormatterBalance.text} ${CURRENCY_SYMBOL[_currencyCode]}"
                              , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _payOffice.amount > 0 ? Colors.green : Colors.red),),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text("Детальна iнформацiя"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Switch(
                              value: _isDetail,
                              onChanged: (value) {
                                _isDetail = value;
                                setState(() {
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _isDetail ? Wrap(
                    children: <Widget>[
                      PayDeskList(
                        showStatus: false,
                        payList: Future.value(_sortedPayDeskList),
                        profile: _profile,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        showPercent: true,
                        showFileAttach: false,
                      )
                    ],
                  ) :
                  AnalyticChartsList().showGeneralInformation(_currencyCode, _preparedMap, _amountFormatter, null, 0),
                ],
              );
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
    }
      ),
    );
  }

  List<charts.Series<AnalyticData, String>> _createSampleData(List<PayDesk> payDeskList, List<CostItem> costList,  List<IncomeItem> incomeList, int currency, {DateTime first, DateTime second}) {
    if(first!=null && !_controllersMap[SortControllers.period]){
      payDeskList = payDeskList.where((element) => DateFormat('yyyy-MM-dd').parse(element.documentDate.toString()).isAtSameMomentAs(first)).toList();
      _sum = 0;
    }

    if(second!=null && _controllersMap[SortControllers.period]){
      payDeskList = payDeskList.where((element) {
        var parse = DateFormat('yyyy-MM-dd').parse(element.documentDate.toString());
        return parse.isBefore(first) && parse.isAfter(second) || parse.isAtSameMomentAs(first) || parse.isAtSameMomentAs(second);
      }).toList();
      _sum = 0;
    }

    List<AnalyticData> _data = [];
    _sum =
        payDeskList.fold(0, (previousValue, element) => previousValue + element.amount);
    payDeskList.forEach((payDesk) {
      payDesk.percentage = payDesk.amount/_sum*100;
    });

    _preparedMap = _sort(_getPrepared(payDeskList, costList, incomeList, _sum));

    _sortedPayDeskList = payDeskList;

    _preparedMap.forEach((key, value) {
      _amountFormatter.text = value.amount.toStringAsFixed(2);
      _data.add(AnalyticData(
        amount: value.amount,
        name: key.name,
        color: _setColor(value, key.color == Colors.red ? 255 : 0),
        percent: value.percentage,
        sum: _sum,
      ));
    });
    return [
      charts.Series(
        data: _data,
        id: 'analytical',
        domainFn: (AnalyticData analyticData, _) {
          _amountFormatter.text = analyticData.amount.toStringAsFixed(2);
          return "${analyticData.name}\n ${(_amountFormatter.text)} ${CURRENCY_SYMBOL[currency]}";
        },
        measureFn: (AnalyticData analyticData, _) => analyticData.percent,
        labelAccessorFn: (AnalyticData analyticData, _) => "${analyticData.percent.toStringAsFixed(2).replaceAll(".", ",")} %",
        colorFn: (AnalyticData analyticalData, _) => charts.ColorUtil.fromDartColor(analyticalData.color),
      )
    ];
  }

  Map<dynamic, PayDesk> _getPrepared(List<PayDesk> payDeskList, List<CostItem> costList,  List<IncomeItem> incomeList, double sumInput){
    Map<dynamic, PayDesk> toReturn = {};
    List<PayDesk> _tmp = payDeskList.where((payment) => payment.payDeskType==2).toList();
    if(_tmp.length!=0){
      double sum = _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
      toReturn.addAll({ResultTypes(name: "Перемiщення коштiв", color: Colors.red) : PayDesk(amount: sum, percentage: sum/sumInput*100)});
    }
    costList.forEach((cost) {
      List<PayDesk> _tmp = payDeskList.where((payment) => payment.costItemName==cost.name).toList();
      double sum = _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
      if(_tmp.isEmpty){
        return;
      }
      toReturn.addAll({ResultTypes(name: cost.name, color: Colors.red) : PayDesk(amount: sum, costItemName: cost.name, percentage: sum/sumInput*100)});
    });
    incomeList.forEach((income) {
      List<PayDesk> _tmp = payDeskList.where((payment) => payment.incomeItemName==income.name).toList();
      double sum = _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
      if(_tmp.isEmpty){
        return;
      }
      toReturn.addAll({ResultTypes(name: income.name, color: Colors.green) : PayDesk(amount: sum, costItemName: income.name, percentage: sum/sumInput*100)});
    });
    _setSum(toReturn);
    return toReturn;
  }

  Map<dynamic, PayDesk> _sort(Map<dynamic, PayDesk> input){
    var _sortedKeys = input.keys.toList(growable:false)
      ..sort((k1, k2) => input[k2].percentage.compareTo(input[k1].percentage));
    return LinkedHashMap
        .fromIterable(_sortedKeys, key: (k) => k, value: (k) => input[k]);
  }

  Future<void> _load() async {
    setState(() {
      _costItemsList = CostItemDAO().getUnDeleted();
      _incomeItemsList = IncomeItemDAO().getUnDeleted();
    });
  }

  Color _setColor(PayDesk value, int currentColor){
    ///Change chart labels color hue from percentage value of PayDesk
    switch(currentColor){
      case 255: //set for color 'red' 2.5
        return Color.fromRGBO(currentColor, 255-int.parse((value.percentage*2.5).toStringAsFixed(0)), 0, 1);
      case 0: //set for color 'green' 1.6
        return Color.fromRGBO(currentColor, 255-int.parse((value.percentage*1.6).toStringAsFixed(0)), 0, 1);
      default: //default color 'blue'
        return Color.fromRGBO(0, 255-int.parse((value.percentage*1.6).toStringAsFixed(0)), 255, 1);
    }
  }

  double _setHeight() {
    switch(MediaQuery.of(context).orientation){
      case Orientation.portrait:
        return MediaQuery.of(context).size.width/1.1;
      case Orientation.landscape:
        return MediaQuery.of(context).size.height;
      default:
        return 350;
    }
  }

  void _setSum(Map<dynamic, PayDesk> input){
    _sumCost = 0;
    _sumIncome = 0;
    input.forEach((key, value) {
      if(key.color==Colors.red){
        _sumCost = _sumCost + value.amount;
      } else {
        _sumIncome = _sumIncome + value.amount;
      }
    });
  }

}