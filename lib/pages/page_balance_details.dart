import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/models/analytic_data.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/result_types.dart';
import 'package:enterprise/widgets/charts_list.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class PageBalanceDetails extends StatefulWidget{

  final Profile profile;
  final List<PayDesk> inputListPayDesk;
  final int currencyCode;
  final String name;

  PageBalanceDetails({
    this.profile,
    this.inputListPayDesk,
    this.currencyCode,
    this.name,
  });

  _PageBalanceDetailsState createState() => _PageBalanceDetailsState();

}

class _PageBalanceDetailsState extends State<PageBalanceDetails>{
  Profile _profile;

  final _amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  List<charts.Series<AnalyticData, String>> _seriesList;
  Map<dynamic, PayDesk> _preparedMap;

  String _name;

  bool _isDetail, _isReload, _isPeriod;

  int _currencyCode;
  double _sum, _sumCost, _sumIncome;

  DateTime _now;
  DateTime _firstDayOfMonth;

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
    _name = widget.name;
    _load();
    _now = DateTime.now();
    _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
    _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
    _isDetail = false;
    _isReload = true;
    _isPeriod = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iнформацiя по гаманцю \n$_name", overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.center,),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                _showPeriodDialog();
              }
          ),
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
              if(_isReload){
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
              return _seriesList.first.data.isEmpty ?
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text("Нема iнформацiї по \n$_name", textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  _isReload ? Container() : Container(
                    alignment: Alignment.center,
                    child: Text("за ${_isPeriod ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                ],
              ) : ListView(
                children: <Widget>[
                  SizedBox(height: 15,),
                  _isReload ? Container() : Container(
                    alignment: Alignment.center,
                    child: Text("за ${_isPeriod ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                                , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
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
                            child: Text("Всього:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text("${_sumIncome >= _sumCost && _preparedMap.keys.first.name!="Видаток" ? "" : "-" }"
                                "${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}"
                              , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
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
    if(first!=null && !_isPeriod){
      payDeskList = payDeskList.where((element) => DateFormat('yyyy-MM-dd').parse(element.documentDate.toString()).isAtSameMomentAs(first)).toList();
      _sum = 0;
    }

    if(second!=null && _isPeriod){
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

  Future _showPeriodDialog() {
    return showDialog(
        context: context,
        builder: (context) => GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        color: Colors.white
                    ),
                    width: MediaQuery.of(context).size.width/1.3,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20.0),
                      children: <Widget>[
                        Text("Встановити період", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text("Дата вiд (включно)"),
                        ),
                        InkWell(
                          onTap: () async {
                            DateTime picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(_now.year - 1),
                                initialDate: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
                                lastDate: DateTime(_now.year + 1));

                            if (picked != null) {
                              setState(() {
                                _dateFrom.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                              });
                            }
                          },
                          child: TextFormField(
                            controller: _dateFrom,
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Дата по (включно)"),
                        ),
                        InkWell(
                          onTap: () async {
                            DateTime picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(_now.year - 1),
                                initialDate: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
                                lastDate: DateTime(_now.year + 1));

                            if (picked != null) {
                              setState(() {
                                _dateTo.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                              });
                            }
                          },
                          child: TextFormField(
                            controller: _dateTo,
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Container(
                            margin: EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  child: Text("Застосувати період"),
                                  onPressed: () {
                                    setState(() {
                                      _isReload = false;
                                      _isPeriod = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Сьогодні"),
                                  onPressed: () {
                                    setState(() {
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_now);
                                      _isReload = false;
                                      _isPeriod = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Вчора"),
                                  onPressed: () {
                                    final _yesterday = DateTime(_now.year, _now.month, _now.day-1);
                                    setState(() {
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_yesterday);
                                      _isReload = false;
                                      _isPeriod = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Поточний місяць"),
                                  onPressed: (){
                                    setState(() {
                                      _dateFrom.text = DateFormat('dd.MM.yyyy').format(_firstDayOfMonth);
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_now);
                                      _isReload = false;
                                      _isPeriod = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Попередній місяць"),
                                  onPressed: (){
                                    final _firstDayOfPreviousMonth = DateTime(_now.year, _now.month-1, 1);
                                    final _lastDayOfPreviousMonth = DateTime(_now.year, _now.month, 0);
                                    setState(() {
                                      _dateFrom.text = DateFormat('dd.MM.yyyy').format(_firstDayOfPreviousMonth);
                                      _dateTo.text = DateFormat('dd.MM.yyyy').format(_lastDayOfPreviousMonth);
                                      _isReload = false;
                                      _isPeriod = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("За весь час"),
                                  onPressed: (){
                                    if(!_isReload){
                                      setState(() {
                                        _isReload = true;
                                        _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
                                        _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              )
          ),
        )
    );
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