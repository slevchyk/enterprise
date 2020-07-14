
import 'dart:collection';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
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

  static List<Tab> _setTabs(){
    List<Tab> _toReturn = [];
    CURRENCY_NAME.values.forEach((element) {
      _toReturn.add(Tab(text: element,));
    });
    return _toReturn.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentColor = 255;
    _isDetail = false;
    _sceneMap = {
      "видаткiв" : 0,
      "надходжень" : 1,
      "пiдсумки" : 5,
    };
    _load();
    _profile = widget.profile;
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: _myTabs.length);
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
      _amountFormatter.text = value.amount.toStringAsFixed(2);
      _data.add(AnalyticData(
        amount: _amountFormatter.text,
        name: key.name,
        color: _setColor(value),
        percent: value.percentage,
        sum: _sum,
      ));
    });
    _data.sort((k1, k2) => k2.amount.compareTo(k1.amount));
    return [
      charts.Series(
        data: _data,
        id: 'analytical',
        domainFn: (AnalyticData analyticData, _) => "${analyticData.name}\n ${analyticData.amount} ${CURRENCY_SYMBOL[currency]}",
        measureFn: (AnalyticData analyticData, _) => analyticData.percent,
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

  _load() async {
    setState(() {
      _payDeskList = PayDeskDAO().getByType(_sceneMap.values.elementAt(_currentIndex));
      _costItemsList = CostItemDAO().getUnDeleted();
      _incomeItemsList = IncomeItemDAO().getUnDeleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabController.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Аналiтика"),
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
//                        padding: EdgeInsets.only(bottom: 28),
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
                                    _toShowCharts(),
                                    Container(
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
                                    child: Text("${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}"
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
//            elevation: 8,
//            fabLocation: BubbleBottomBarFabLocation.end, //new
//            hasNotch: true, //new
//            hasInk: true ,//new, gives a cute ink effect
            inkColor: Colors.black12, //optional, uses theme color if not specified
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
//          bottomNavigationBar: BottomNavigationBar(
//            iconSize: 0,
//            onTap: onTabTapped, // new
//            currentIndex: _currentIndex,
//            unselectedItemColor: Colors.black,
//            selectedItemColor: Colors.lightGreen,
//            selectedLabelStyle: TextStyle(
//                fontWeight: FontWeight.bold
//            ),
//            items: [
//              BottomNavigationBarItem(
//                icon: Icon(Icons.donut_small),
//                title: Text('ВИДАТКИ'),
//              ),
//              BottomNavigationBarItem(
//                icon: Icon(Icons.input),
//                title: Text('НАДХОДЖЕННЯ'),
//              ),
//              BottomNavigationBarItem(
//                  icon: Icon(Icons.account_balance),
//                  title: Text('ПІДСУМКИ')
//              )
//            ],
//          ),
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
                          style: TextStyle(color: _currentIndex ==0? Colors.red : Colors.green[800]),),
//                          style: TextStyle(color: _setColor(_sortedMap.values.elementAt(index)),)),
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
                      progressColor: _setColor(_sortedMap.values.elementAt(index)),
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

  Widget _showChartsLabels(int currency) {
    var _temp = _preparedMap;
    var _sortedKeys = _temp.keys.toList(growable:false)
      ..sort((k1, k2) => _temp[k2].percentage.compareTo(_temp[k1].percentage));
    LinkedHashMap _sortedMap = new LinkedHashMap
        .fromIterable(_sortedKeys, key: (k) => k, value: (k) => _temp[k]);
//    Map<dynamic, PayDesk> _tmp = _preparedMap;
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
                    color: _setColor(_sortedMap.values.elementAt(index)),
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
}

class AnalyticData{
  final double percent;
  final String name;
  final String amount;
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