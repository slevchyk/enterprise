
import 'dart:collection';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/impl/pay_desk_dao.dart';
import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class PageResults extends StatefulWidget{
  final Profile profile;

  PageResults({
    this.profile
  });

  @override
  _PageResultsState createState() => _PageResultsState();
}

class _PageResultsState extends State<PageResults> with SingleTickerProviderStateMixin {
  Profile _profile;

  final List<Tab> _myTabs = _setTabs();
  TabController _tabController;

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  Future<List<PayDesk>> _payDeskList;
  Future<List<CostItem>> _costItemsList;
  Future<List<IncomeItem>> _incomeItemsList;
  List<PayOffice> _payOfficeList;

  List<PayDesk> _sortedPayDeskList = [];

  ScrollController _scrollController, _dialogScrollController;

  Map<dynamic, PayDesk> _preparedMap;

  double _sum;

  int _currencyCode, _currentIndex, _currentColor;

  bool _isDetail, _isReload, _isPeriod, _isSwitched, _isSortByPayOffice;

  static final _now = DateTime.now();
  final _firstDayOfMonth = DateTime(_now.year, _now.month, 1);

  final _amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  Map<String, int> _sceneMap;

  List<charts.Series<AnalyticData, String>> _seriesList;

  @override
  void initState() {
    super.initState();
    _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
    _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
    _isReload = false;
    _isPeriod = true;
    _isDetail = false;
    _isSwitched = true;
    _isSortByPayOffice = false;
    _currentIndex = 0;
    _currentColor = 255;
    _sceneMap = {
      "видаткiв" : 0,
      "надходжень" : 1,
      "" : 1,
    };
    _load();
    _profile = widget.profile;
    _scrollController = ScrollController();
    _dialogScrollController = ScrollController();
    _tabController = TabController(vsync: this, length: _myTabs.length);
  }

  static List<Tab> _setTabs(){
    List<Tab> _toReturn = [];
    CURRENCY_NAME.values.forEach((element) {
      _toReturn.add(Tab(text: element,));
    });
    return _toReturn.reversed.toList();
  }

  Map<dynamic, PayDesk> _getPrepared(List<PayDesk> payDeskList, List<CostItem> costList,  List<IncomeItem> incomeList,  double sumInput){
    Map<dynamic, PayDesk> toReturn = {};
    switch(_currentIndex){
      case 0:
        costList.forEach((cost) {
          List<PayDesk> _tmp = payDeskList.where((payment) => payment.costItemName==cost.name).toList();
          double sum = _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 255;
          if(_tmp.isEmpty){
            return;
          }
          toReturn.addAll({cost:PayDesk(amount: sum, costItemName: cost.name, percentage: sum/sumInput*100)});
        });
        break;
      case 1:
        incomeList.forEach((income) {
          List<PayDesk> _tmp = payDeskList.where((payment) => payment.incomeItemName==income.name).toList();
          double sum = _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 0;
          if(_tmp.isEmpty){
            return;
          }
          toReturn.addAll({income:PayDesk(amount: sum, costItemName: income.name, percentage: sum/sumInput*100)});
        });
        break;
      case 2:
        double sum = 0;
        incomeList.forEach((income) {
          List<PayDesk> _tmp = payDeskList.where((payment) => payment.incomeItemName==income.name).toList();
          sum = sum + _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
          if(_tmp.isEmpty){
            return;
          }
          toReturn.addAll({const ResultTypes(name: "Надходження", color: Colors.green) : PayDesk(amount: sum, percentage: sum/sumInput*100)});
        });
        sum = 0;
        costList.forEach((cost) {
          List<PayDesk> _tmp = payDeskList.where((payment) => payment.costItemName==cost.name).toList();
          sum = sum +  _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 200;
          if(_tmp.isEmpty){
            return;
          }
          toReturn.addAll({const ResultTypes(name: "Видаток", color: Colors.red) : PayDesk(amount: sum, percentage: sum/sumInput*100)});
        });
        break;
    }
    return toReturn;
  }

  List<charts.Series<AnalyticData, String>> _createSampleData(List<PayDesk> payDeskList, int currency,
      List<CostItem> costList, List<IncomeItem> incomeList, {DateTime first, DateTime second}) {
    if(first!=null && !_isPeriod){
      payDeskList = payDeskList.where((element) => DateFormat('yyyy-MM-dd').parse(element.documentDate.toString()).isAtSameMomentAs(first)).toList();
      _sortedPayDeskList = payDeskList;
      _sum = 0;
    }

    if(second!=null && _isPeriod){
      payDeskList = payDeskList.where((element) {
        var parse = DateFormat('yyyy-MM-dd').parse(element.documentDate.toString());
        return parse.isBefore(first) && parse.isAfter(second) || parse.isAtSameMomentAs(first) || parse.isAtSameMomentAs(second);
      }).toList();
      _sortedPayDeskList = payDeskList;
      _sum = 0;
    }

    if(_isSortByPayOffice){
      List<PayDesk> toReturn = [];
      _payOfficeList.forEach((payOffice) {
        payDeskList.where((payDesk) => payDesk.fromPayOfficeAccID == payOffice.accID && payOffice.isShow)
            .forEach((payDeskOutput) {
          toReturn.add(payDeskOutput);
        });
      });
      payDeskList = toReturn;
      _sortedPayDeskList = payDeskList;
    }

    List<AnalyticData> _data = [];
    _sum =
      payDeskList.fold(0, (previousValue, element) => previousValue + element.amount);
    payDeskList.forEach((payDesk) {
      payDesk.percentage = payDesk.amount/_sum*100;
    });

    _preparedMap = _sort(_getPrepared(payDeskList, costList, incomeList, _sum));

    _preparedMap.forEach((key, value) {
      if(_currentIndex == 2){
        _sum = _preparedMap.values.first.amount-_preparedMap.values.last.amount;
        if(_preparedMap.keys.first.name==_preparedMap.keys.last.name){
          _sum = _preparedMap.values.first.amount;
        }
      }
      _amountFormatter.text = value.amount.toStringAsFixed(2);
      _data.add(AnalyticData(
        amount: value.amount,
        name: key.name,
        color: _currentIndex == 2 ? key.color : _setColor(value),
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
        measureFn: (AnalyticData analyticData, _) => _currentIndex == 2 ? analyticData.amount : analyticData.percent,
        labelAccessorFn: (AnalyticData analyticData, _) => "${analyticData.percent.toStringAsFixed(2).replaceAll(".", ",")} %",
        colorFn: (AnalyticData analyticalData, _) => charts.ColorUtil.fromDartColor(analyticalData.color),
      )
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<dynamic, PayDesk> _sort(Map<dynamic, PayDesk> input){
    var _sortedKeys = input.keys.toList(growable:false)
      ..sort((k1, k2) => input[k2].percentage.compareTo(input[k1].percentage));
    return LinkedHashMap
        .fromIterable(_sortedKeys, key: (k) => k, value: (k) => input[k]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabController.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Аналiтика"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: () {
                  _sortDialog(_payOfficeList);
                },
              ),
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
              _payDeskList,
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
                  return TabBarView(
                    controller: _tabController,
                    children: _myTabs.isEmpty
                        ? <Widget>[]
                        : _myTabs.map((dynamicContent) {
                      List<PayDesk> _toShow = [];
                      CURRENCY_NAME.values.where((currency) => currency==dynamicContent.text);
                      _currencyCode =
                          CURRENCY_NAME.entries.where((element) => element.value==dynamicContent.text).toList().first.key;
                      _toShow = snapshot.data[0];
                      _toShow = _toShow.where((element) => element.currencyCode==_currencyCode).toList();
                      if(_isReload){
                        _seriesList = _createSampleData(_toShow, _currencyCode, snapshot.data[1], snapshot.data[2]);
                      } else {
                        _seriesList = _createSampleData(
                          _toShow,
                          _currencyCode,
                          snapshot.data[1],
                          snapshot.data[2],
                          first: DateFormat('dd.MM.yyyy').parse(_dateTo.text),
                          second: DateFormat('dd.MM.yyyy').parse(_dateFrom.text),
                        );
                        _toShow = _sortedPayDeskList;
                      }
                      _amountFormatter.text = _sum.toStringAsFixed(2);
                      return _seriesList.first.data.isEmpty ?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: Text("Немає iнформацiї по валютi ${dynamicContent.text} ",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          _isReload ? Container() : Container(
                            alignment: Alignment.center,
                            child: Text("за ${_isPeriod ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ) :
                      ListView(
                        controller: _scrollController,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            alignment: Alignment.center,
                            child: Text("Iнформацiя по валютi ${dynamicContent.text} ",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          ),
                          _isReload ? Container() : Container(
                            alignment: Alignment.center,
                            child: Text("за ${_isPeriod ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          ),
                          SizedBox(height: 15,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: _setHeight()/1.5,
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Stack(
                                  children: <Widget>[
                                    _currentIndex == 2 ? AnalyticChartsList().toShowChartsSimple(_seriesList) :
                                    AnalyticChartsList().toShowCharts(_seriesList),
                                    _currentIndex == 2 ? Container() : Container(
                                      child: Center(
                                        child: Text("${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}"
                                          , style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                      ),
                                    ),
                                  ],
                                ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: AnalyticChartsList().showChartsLabels(_currencyCode, _preparedMap, _amountFormatter, _currentColor, _currentIndex)
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
                                    child: Text("Всього ${_sceneMap.keys.elementAt(_currentIndex)}:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: Text("${_currentIndex == 2 ? _preparedMap.values.first.amount >= _preparedMap.values.last.amount && _preparedMap.keys.first.name!="Видаток" ? "" : "-" : ""} "
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
                                payList: Future.value(_toShow),
                                profile: _profile,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                showPercent: true,
                                showFileAttach: false,
                              )
                            ],
                          ) :
                          AnalyticChartsList().showGeneralInformation(_currencyCode, _preparedMap, _amountFormatter, _currentColor, _currentIndex),
                        ],
                      );
                    }).toList(),
                  );
                default:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }
            },
          ),
          bottomNavigationBar: BubbleBottomBar(
            opacity: .2,
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            inkColor: Colors.black12,
            items: <BubbleBottomBarItem>[
              BubbleBottomBarItem(
                  backgroundColor: Colors.red,
                  icon: Icon(Icons.file_upload,
                    color: Colors.black,),
                  activeIcon:
                  Icon(Icons.file_upload,
                    color: Colors.red,),
                  title: Text("ВИДАТКИ")),
              BubbleBottomBarItem(
                  backgroundColor: Colors.green,
                  icon: Icon(Icons.file_download,
                    color: Colors.black,),
                  activeIcon:
                  Icon(Icons.file_download,
                    color: Colors.green,),
                  title: Text("НАДХОДЖЕННЯ")),
              BubbleBottomBarItem(
                  backgroundColor: Colors.blue,
                  icon: Icon(Icons.equalizer,
                    color: Colors.black,),
                  activeIcon:
                  Icon(Icons.equalizer,
                    color: Colors.blue,),
                  title: Text("ПІДСУМКИ")),
            ],
          ),
        )
    );
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
                                initialDate: _now,
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
                                initialDate: _now,
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

  Color _setColor(PayDesk value){
    ///Change chart labels color hue from percentage value of PayDesk
    switch(_currentColor){
      case 255: //set for color 'red' 2.5
        return Color.fromRGBO(_currentColor, 255-int.parse((value.percentage*2.5).toStringAsFixed(0)), 0, 1);
      case 0: //set for color 'green' 1.6
        return Color.fromRGBO(_currentColor, 255-int.parse((value.percentage*1.6).toStringAsFixed(0)), 0, 1);
      default: //default color 'blue'
        return Color.fromRGBO(0, 255-int.parse((value.percentage*1.6).toStringAsFixed(0)), 255, 1);
    }
  }

  void onTabTapped(int index) {
    _currentIndex = index;
    _load();
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

  _sortDialog(List<PayOffice> inputCostItem){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _dialogScrollController
          .jumpTo(_dialogScrollController.position.maxScrollExtent+inputCostItem.length);
    });
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                content: Container(
                  height: inputCostItem.length == 1 ? 115 : inputCostItem.length >3 ? 250 : 160,
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    controller: _dialogScrollController,
                    itemCount: inputCostItem.length+1,
                    itemBuilder: (BuildContext context, int index){
                      if(inputCostItem.length==index){
                        return Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  height: 60,
                                  padding: EdgeInsets.only(left: 25),
                                  alignment: Alignment.center,
                                  child: Text("Обрати всi",textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightGreen),),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 25),
                                  child: Switch(
                                    value: _isSwitched,
                                    onChanged: (value) {
                                      if(!_isSwitched){
                                        setState(() {
                                          _isSwitched = value;
                                          inputCostItem.where((element) => element.isShow ?
                                          element.isShow :
                                          element.isShow = true).toList();
                                          this.setState(() {});
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: 1.5,
                                color: Colors.lightGreen,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 180,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 30),
                                child: Column(
                                  children: <Widget>[
                                    Text(inputCostItem[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 35,
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: <Widget>[
                                    Text("${inputCostItem[index].currencyName}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(right: 25),
                                child: Column(
                                  children: <Widget>[
                                    Switch(
                                      value: inputCostItem[index].isShow,
                                      onChanged: (value) {
                                        setState(() {
                                          if(_isSwitched){
                                            _isSwitched = false;
                                          }
                                          _isSortByPayOffice = true;
                                          _payOfficeList[index].isShow = !_payOfficeList[index].isShow;
                                          if(inputCostItem.where((element) => element.isShow).length==inputCostItem.length){
                                            _isSwitched = true;
                                          }
                                          this.setState(() { });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );},
          );
        }
    );
  }

  _load() async {
    if(_payOfficeList==null){
      _payOfficeList = await ImplPayOfficeDAO().getUnDeleted();
    }
    setState(() {
      _currentIndex == 2 ? _payDeskList = PayDeskDAO().getAllExceptTransfer() : _payDeskList = ImplPayDeskDao().getByType(_sceneMap.values.elementAt(_currentIndex));
      _costItemsList = CostItemDAO().getUnDeleted();
      _incomeItemsList = IncomeItemDAO().getUnDeleted();
    });
  }
}