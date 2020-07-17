
import 'dart:collection';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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

  Future<List<PayDesk>> _payDeskList;
  Future<List<CostItem>> _costItemsList;
  Future<List<IncomeItem>> _incomeItemsList;

  ScrollController _scrollController;

  Map<dynamic, PayDesk> _preparedMap;

  double _sum;

  int _currencyCode, _currentIndex, _currentColor;
  bool _isDetail;

  final _amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  Map<String, int> _sceneMap;

  List<charts.Series<AnalyticData, String>> _seriesList;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentColor = 255;
    _isDetail = false;
    _sceneMap = {
      "видаткiв" : 0,
      "надходжень" : 1,
      "" : 1,
    };
    _load();
    _profile = widget.profile;
    _scrollController = ScrollController();
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
          toReturn.addAll({const Types(name: "Надходження") : PayDesk(amount: sum, percentage: sum/sumInput*100)});
        });
        sum = 0;
        costList.forEach((cost) {
          List<PayDesk> _tmp = payDeskList.where((payment) => payment.costItemName==cost.name).toList();
          sum = sum +  _tmp.fold(0, (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 200;
          if(_tmp.isEmpty){
            return;
          }
          toReturn.addAll({const Types(name: "Видаток") : PayDesk(amount: sum, percentage: sum/sumInput*100)});
        });
        break;
    }
    return toReturn;
  }

  List<charts.Series<AnalyticData, String>> _createSampleData(List<PayDesk> payDeskList, int currency,
      List<CostItem> costList, List<IncomeItem> incomeList) {
    List<AnalyticData> _data = [];
    _sum =
      payDeskList.fold(0, (previousValue, element) => previousValue + element.amount);
    payDeskList.forEach((payDesk) {
      payDesk.percentage = payDesk.amount/_sum*100;
    });

    _preparedMap = _getPrepared(payDeskList, costList, incomeList, _sum);

    _preparedMap.forEach((key, value) {
      _currentIndex == 2 ? _sum = _preparedMap.values.first.amount-_preparedMap.values.last.amount : _sum = _sum;
      _amountFormatter.text = value.amount.toStringAsFixed(2);
      _data.add(AnalyticData(
        amount: value.amount,
        name: key.name,
        color: _setColor(value, type: key),
        percent: value.percentage,
        sum: _sum,
      ));
    });
    _data.sort((k1, k2) => k2.amount.compareTo(k1.amount));
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

  Future _showPeriodDialog(){
    final _dateFrom = TextEditingController();
    final _dateTo = TextEditingController();
    _dateFrom.text = formatDate(DateTime.now(), [dd, '.', mm, '.', yyyy]);
    _dateTo.text = formatDate(DateTime.now(), [dd, '.', mm, '.', yyyy]);
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
                                firstDate: DateTime(DateTime.now().year - 1),
                                initialDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1));

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
                                firstDate: DateTime(DateTime.now().year - 1),
                                initialDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1));

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
                                  onPressed: (){},
                                ),
                                FlatButton(
                                  child: Text("Сьогодні"),
                                  onPressed: (){},
                                ),
                                FlatButton(
                                  child: Text("Вчора"),
                                  onPressed: (){},
                                ),
                                FlatButton(
                                  child: Text("Поточний місяць"),
                                  onPressed: (){},
                                ),
                                FlatButton(
                                  child: Text("Попередній місяць"),
                                  onPressed: (){},
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabController.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Аналiтика"),
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
                      if(CURRENCY_NAME.values.contains(dynamicContent.text)){
                        _toShow = snapshot.data[0];
                        _currencyCode =
                            CURRENCY_NAME.entries.where((element) => element.value==dynamicContent.text).toList().first.key;
                        _toShow = _toShow.where((element) => element.currencyCode==_currencyCode).toList();
                        _seriesList = _createSampleData(_toShow, _currencyCode, snapshot.data[1], snapshot.data[2]);
                        _amountFormatter.text = _sum.toStringAsFixed(2);
                      }
                      return _seriesList.first.data.isEmpty ?
                      Container(
                        child: Center(
                          child: Text("Немає iнформацiї по валютi ${dynamicContent.text}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ) :
                      ListView(
                        controller: _scrollController,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 20, bottom: 15),
                            alignment: Alignment.center,
                            child: Text("Iнформацiя по валютi ${dynamicContent.text}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: _setHeight()/1.5,
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Stack(
                                  children: <Widget>[
                                    _currentIndex == 2 ? _toShowChartsSimple() :
                                    _toShowCharts(),
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
                            child: _showChartsLabels(_currencyCode)
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
                                    child: Text("${_currentIndex == 2 ? _preparedMap.values.first.amount >= _preparedMap.values.last.amount ? "" : "-" : ""} ${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}"
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
                          _showGeneralInformation(_currencyCode),
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

  Widget _toShowCharts(){
    return charts.PieChart(
      _seriesList,
      layoutConfig: charts.LayoutConfig(
          leftMarginSpec: charts.MarginSpec.fromPercent(),
          topMarginSpec: charts.MarginSpec.fromPercent(),
          rightMarginSpec: charts.MarginSpec.fromPercent(),
          bottomMarginSpec: charts.MarginSpec.fromPercent()
      ),
      animate: true,
      defaultRenderer: charts.ArcRendererConfig(
          arcWidth: 15,
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              outsideLabelStyleSpec: charts.TextStyleSpec(
                fontSize: 14,
              ),
              labelPosition: charts.ArcLabelPosition.outside,
            )
          ]
      ),
    );
  }

  Widget _toShowChartsSimple(){
   return charts.BarChart(
     _seriesList,
     animate: true,
   );
  }

  Widget _showGeneralInformation(int currency){
    var _temp = _preparedMap;
    var _sortedKeys = _temp.keys.toList(growable:false)
      ..sort((k1, k2) => _temp[k2].percentage.compareTo(_temp[k1].percentage));
    LinkedHashMap _sortedMap = new LinkedHashMap
        .fromIterable(_sortedKeys, key: (k) => k, value: (k) => _temp[k]);
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _sortedMap.length,
        itemBuilder: (BuildContext context, int index) {
          _amountFormatter.text = _sortedMap.values.elementAt(index).amount.toStringAsFixed(2);
          return Card(
            child: Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(_sortedMap.keys.elementAt(index).name),
                    trailing: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text("${_amountFormatter.text} ${CURRENCY_SYMBOL[currency]}" ),
                          SizedBox(height: 5,),
                          Text("${_sortedMap.values.elementAt(index).percentage.toStringAsFixed(2).replaceAll(".", ",")} %",
                          style: TextStyle(color: _currentIndex == 2 ? _setColor(_sortedMap.values.elementAt(index), type: _sortedMap.keys.elementAt(index)) : _currentIndex == 0 ? Colors.red : Colors.green[800]),),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, bottom: 15,),
                    child: LinearPercentIndicator(
                      animation: true,
                      animationDuration: 1000,
                      lineHeight: 10,
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      percent: _sortedMap.values.elementAt(index).percentage/100,
                      progressColor: _setColor(_sortedMap.values.elementAt(index), type: _sortedMap.keys.elementAt(index)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _showChartsLabels(int currency) {
    var _temp = _preparedMap;
    var _sortedKeys = _temp.keys.toList(growable:false)
      ..sort((k1, k2) => _temp[k2].percentage.compareTo(_temp[k1].percentage));
    LinkedHashMap _sortedMap = new LinkedHashMap
        .fromIterable(_sortedKeys, key: (k) => k, value: (k) => _temp[k]);
    return ListView.builder(
      itemCount: _sortedMap.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        _amountFormatter.text = _sortedMap.values.elementAt(index).amount.toStringAsFixed(2);
        return Container(
          child: ListTile(
            title: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 15),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _setColor(_sortedMap.values.elementAt(index), type: _sortedMap.keys.elementAt(index)),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width/1.2,
                  child: Text(
                    "${_sortedMap.keys.elementAt(index).name} ${_amountFormatter.text} ${CURRENCY_SYMBOL[currency]}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _setColor(PayDesk value, {var type}){
    ///Change chart labels color hue from percentage value of PayDesk
    if(type!=null){
      if(type.runtimeType==Types && type.name == "Видаток"){
        return Colors.red;
      } else if (type.name == "Надходження"){
        return Colors.green;
      }
    }
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

  _load() async {
    setState(() {
      _currentIndex == 2 ? _payDeskList = PayDeskDAO().getAllExceptTransfer() : _payDeskList = PayDeskDAO().getByType(_sceneMap.values.elementAt(_currentIndex));
      _costItemsList = CostItemDAO().getUnDeleted();
      _incomeItemsList = IncomeItemDAO().getUnDeleted();
    });
  }
}

class AnalyticData{
  final double percent;
  final String name;
  final double amount;
  final double sum;
  final Color color;

  AnalyticData({
    this.percent,
    this.name,
    this.amount,
    this.sum,
    this.color,
  });
}

class Types{
  final String name;

  const Types({
    this.name
  });
}