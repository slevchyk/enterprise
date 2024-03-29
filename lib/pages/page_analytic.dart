import 'dart:collection';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/currency_dao.dart';
import 'package:enterprise/database/impl/pay_desk_dao.dart';
import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/analytic_data.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/result_types.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:enterprise/widgets/charts_list.dart';
import 'package:enterprise/widgets/paydesk_list.dart';
import 'package:enterprise/widgets/period_dialog.dart';
import 'package:enterprise/widgets/sort_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class PageResults extends StatefulWidget {
  final Profile profile;

  PageResults({this.profile});

  @override
  _PageResultsState createState() => _PageResultsState();
}

class _PageResultsState extends State<PageResults>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Profile _profile;

  // final List<Tab> _myTabs = _setTabs();
  List<Tab> _myTabs;
  TabController _tabController;

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  Future<List<PayDesk>> _payDeskList;
  Future<List<CostItem>> _costItemsList;
  Future<List<IncomeItem>> _incomeItemsList;

  List<PayOffice> _payOfficeList;
  List<PayDesk> _sortedPayDeskList = [];

  ScrollController _scrollController;
  ScrollController _scrollControllerPayOffice;

  Map<dynamic, PayDesk> _preparedMap;
  Map<SortControllers, bool> _controllersMap;

  double _sum;

  int _currencyCode, _currentIndex, _currentColor;

  bool _isDetail;

  DateTime _now;
  DateTime _firstDayOfMonth;

  final _amountFormatter =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  Map<String, int> _sceneMap;

  List<charts.Series<AnalyticData, String>> _seriesList;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _dateFrom.text = formatDate(_firstDayOfMonth, [dd, '.', mm, '.', yyyy]);
    _dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
    _isDetail = false;
    _currentIndex = 0;
    _currentColor = 255;
    _controllersMap = PeriodDialog.setControllersMap();
    _sceneMap = {
      "видаткiв": 0,
      "надходжень": 1,
      "": 1,
    };
    _load();
    _profile = widget.profile;
    _scrollController = ScrollController();
    _scrollControllerPayOffice = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initState());
  }

  _initState() async {
    _myTabs = await _getTabs();
    _tabController = TabController(vsync: this, length: _myTabs.length);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabController?.length ?? 0,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Аналiтика"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: () async {
                  SortWidget.sortPayOffice(_payOfficeList,
                      _scrollControllerPayOffice, _callBack, context);
                },
              ),
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    PeriodDialog.showPeriodDialog(
                            context, _dateFrom, _dateTo, _controllersMap)
                        .whenComplete(() => setState(() {}));
                  }),
              IconButton(
                onPressed: () async {
                  _load(action: true);
                },
                icon: Icon(
                  Icons.sync,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: FutureBuilder(
            future: Future.wait([
              _payDeskList,
              _costItemsList,
              _incomeItemsList,
            ]),
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
                  if (!snapshot.hasData) {
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
                            CURRENCY_NAME.values.where(
                                (currency) => currency == dynamicContent.text);
                            _currencyCode = CURRENCY_NAME.entries
                                .where((element) =>
                                    element.value == dynamicContent.text)
                                .toList()
                                .first
                                .key;
                            _toShow = snapshot.data[0];
                            _toShow = _toShow
                                .where((element) =>
                                    element.currencyCode == _currencyCode)
                                .toList();
                            _seriesList = _createSampleData(
                              _toShow,
                              _currencyCode,
                              snapshot.data[1],
                              snapshot.data[2],
                              first:
                                  DateFormat('dd.MM.yyyy').parse(_dateTo.text),
                              second: DateFormat('dd.MM.yyyy')
                                  .parse(_dateFrom.text),
                            );
                            if (_sortedPayDeskList.length != 0) {
                              _toShow = _sortedPayDeskList;
                            }
                            _amountFormatter.text = _sum.toStringAsFixed(2);
                            return _seriesList.first.data.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Center(
                                          child: Text(
                                              "Нема iнформацiї по валютi ${dynamicContent.text} ",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "за ${_controllersMap[SortControllers.period] ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView(
                                    controller: _scrollController,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top: 20),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Iнформацiя по валютi ${dynamicContent.text} ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "за ${_controllersMap[SortControllers.period] ? "перiод ${_dateFrom.text} - ${_dateTo.text}" : "${_dateTo.text}"}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: _setHeight() / 1.5,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Stack(
                                            children: <Widget>[
                                              _currentIndex == 2
                                                  ? AnalyticChartsList()
                                                      .toShowChartsSimple(
                                                          _seriesList)
                                                  : AnalyticChartsList()
                                                      .toShowCharts(
                                                          _seriesList),
                                              _currentIndex == 2
                                                  ? Container()
                                                  : Container(
                                                      child: Center(
                                                        child: Text(
                                                          "${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(top: 15),
                                          child: AnalyticChartsList()
                                              .showChartsLabels(
                                                  _currencyCode,
                                                  _preparedMap,
                                                  _amountFormatter,
                                                  _currentColor,
                                                  _currentIndex)),
                                      Container(
                                        height: 50,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Card(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: Text(
                                                  "Всього ${_sceneMap.keys.elementAt(_currentIndex)}:",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: Text(
                                                  "${_currentIndex == 2 ? _preparedMap.values.first.amount >= _preparedMap.values.last.amount && _preparedMap.keys.first.name != "Видаток" ? "" : "-" : ""} "
                                                  "${_amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Card(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child:
                                                    Text("Детальна iнформацiя"),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: Switch(
                                                  value: _isDetail,
                                                  onChanged: (value) {
                                                    _isDetail = value;
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      _isDetail
                                          ? Wrap(
                                              children: <Widget>[
                                                PayDeskList(
                                                  showStatus: false,
                                                  payList:
                                                      Future.value(_toShow),
                                                  profile: _profile,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  showPercent: true,
                                                  showFileAttach: false,
                                                )
                                              ],
                                            )
                                          : AnalyticChartsList()
                                              .showGeneralInformation(
                                                  _currencyCode,
                                                  _preparedMap,
                                                  _amountFormatter,
                                                  _currentColor,
                                                  _currentIndex),
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
            onTap: _onTabTapped,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            inkColor: Colors.black12,
            items: <BubbleBottomBarItem>[
              BubbleBottomBarItem(
                  backgroundColor: Colors.red,
                  icon: Icon(
                    Icons.file_upload,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.file_upload,
                    color: Colors.red,
                  ),
                  title: Text("ВИДАТКИ")),
              BubbleBottomBarItem(
                  backgroundColor: Colors.green,
                  icon: Icon(
                    Icons.file_download,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.file_download,
                    color: Colors.green,
                  ),
                  title: Text("НАДХОДЖЕННЯ")),
              BubbleBottomBarItem(
                  backgroundColor: Colors.blue,
                  icon: Icon(
                    Icons.equalizer,
                    color: Colors.black,
                  ),
                  activeIcon: Icon(
                    Icons.equalizer,
                    color: Colors.blue,
                  ),
                  title: Text("ПІДСУМКИ")),
            ],
          ),
        ));
  }

  // static List<Tab> _setTabs() {
  //   List<Tab> _toReturn = [];
  //   CURRENCY_NAME.values.forEach((element) {
  //     _toReturn.add(Tab(
  //       text: element,
  //     ));
  //   });
  //   return _toReturn.reversed.toList();
  // }

  Future<List<Tab>> _getTabs() async {
    List<Tab> _toReturn = [];

    List<Currency> _currencyList = await CurrencyDAO().getUnDeleted();
    _currencyList.forEach((element) {
      _toReturn.add(Tab(
        text: element.name,
      ));
    });
    return _toReturn.reversed.toList();
  }

  List<charts.Series<AnalyticData, String>> _createSampleData(
      List<PayDesk> payDeskList,
      int currency,
      List<CostItem> costList,
      List<IncomeItem> incomeList,
      {DateTime first,
      DateTime second}) {
    if (first != null && !_controllersMap[SortControllers.period]) {
      payDeskList = payDeskList
          .where((element) => DateFormat('yyyy-MM-dd')
              .parse(element.documentDate.toString())
              .isAtSameMomentAs(first))
          .toList();
      _sortedPayDeskList = payDeskList;
      _sum = 0;
    }

    if (second != null && _controllersMap[SortControllers.period]) {
      payDeskList = payDeskList.where((element) {
        var parse =
            DateFormat('yyyy-MM-dd').parse(element.documentDate.toString());
        return parse.isBefore(first) && parse.isAfter(second) ||
            parse.isAtSameMomentAs(first) ||
            parse.isAtSameMomentAs(second);
      }).toList();
      _sortedPayDeskList = payDeskList;
      _sum = 0;
    }

    if (_payOfficeList != null) {
      var where =
          _payOfficeList?.where((payOffice) => payOffice.isShow == false);
      if (where != null) {
        List<PayDesk> toReturn = [];
        _payOfficeList.forEach((payOffice) {
          payDeskList
              .where((payDesk) =>
                  payDesk.fromPayOfficeAccID == payOffice.accID &&
                  payOffice.isShow)
              .forEach((payDeskOutput) {
            toReturn.add(payDeskOutput);
          });
        });
        payDeskList = toReturn;
        _sortedPayDeskList = payDeskList;
      }
    }

    List<AnalyticData> _data = [];
    _sum = payDeskList.fold(
        0, (previousValue, element) => previousValue + element.amount);
    payDeskList.forEach((payDesk) {
      payDesk.percentage = payDesk.amount / _sum * 100;
    });

    _preparedMap = _sort(_getPrepared(payDeskList, costList, incomeList, _sum));

    _preparedMap.forEach((key, value) {
      if (_currentIndex == 2) {
        _sum =
            _preparedMap.values.first.amount - _preparedMap.values.last.amount;
        if (_preparedMap.keys.first.name == _preparedMap.keys.last.name) {
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
        measureFn: (AnalyticData analyticData, _) =>
            _currentIndex == 2 ? analyticData.amount : analyticData.percent,
        labelAccessorFn: (AnalyticData analyticData, _) =>
            "${analyticData.percent.toStringAsFixed(2).replaceAll(".", ",")} %",
        colorFn: (AnalyticData analyticalData, _) =>
            charts.ColorUtil.fromDartColor(analyticalData.color),
      )
    ];
  }

  Map<dynamic, PayDesk> _getPrepared(List<PayDesk> payDeskList,
      List<CostItem> costList, List<IncomeItem> incomeList, double sumInput) {
    Map<dynamic, PayDesk> toReturn = {};
    switch (_currentIndex) {
      case 0:
        costList.forEach((cost) {
          List<PayDesk> _tmp = payDeskList
              .where((payment) => payment.costItemName == cost.name)
              .toList();
          double sum = _tmp.fold(
              0, (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 255;
          if (_tmp.isEmpty) {
            return;
          }
          toReturn.addAll({
            cost: PayDesk(
                amount: sum,
                costItemName: cost.name,
                percentage: sum / sumInput * 100)
          });
        });
        break;
      case 1:
        incomeList.forEach((income) {
          List<PayDesk> _tmp = payDeskList
              .where((payment) => payment.incomeItemName == income.name)
              .toList();
          double sum = _tmp.fold(
              0, (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 0;
          if (_tmp.isEmpty) {
            return;
          }
          toReturn.addAll({
            income: PayDesk(
                amount: sum,
                costItemName: income.name,
                percentage: sum / sumInput * 100)
          });
        });
        break;
      case 2:
        double sum = 0;
        incomeList.forEach((income) {
          List<PayDesk> _tmp = payDeskList
              .where((payment) => payment.incomeItemName == income.name)
              .toList();
          sum = sum +
              _tmp.fold(0,
                  (previousValue, payment) => previousValue + payment.amount);
          if (_tmp.isEmpty) {
            return;
          }
          toReturn.addAll({
            const ResultTypes(name: "Надходження", color: Colors.green):
                PayDesk(amount: sum, percentage: sum / sumInput * 100)
          });
        });
        sum = 0;
        costList.forEach((cost) {
          List<PayDesk> _tmp = payDeskList
              .where((payment) => payment.costItemName == cost.name)
              .toList();
          sum = sum +
              _tmp.fold(0,
                  (previousValue, payment) => previousValue + payment.amount);
          _currentColor = 200;
          if (_tmp.isEmpty) {
            return;
          }
          toReturn.addAll({
            const ResultTypes(name: "Видаток", color: Colors.red):
                PayDesk(amount: sum, percentage: sum / sumInput * 100)
          });
        });
        break;
    }
    return toReturn;
  }

  Map<dynamic, PayDesk> _sort(Map<dynamic, PayDesk> input) {
    var _sortedKeys = input.keys.toList(growable: false)
      ..sort((k1, k2) => input[k2].percentage.compareTo(input[k1].percentage));
    return LinkedHashMap.fromIterable(_sortedKeys,
        key: (k) => k, value: (k) => input[k]);
  }

  Color _setColor(PayDesk value) {
    ///Change chart labels color hue from percentage value of PayDesk
    switch (_currentColor) {
      case 255: //set for color 'red' 2.5
        return Color.fromRGBO(_currentColor,
            255 - int.parse((value.percentage * 2.5).toStringAsFixed(0)), 0, 1);
      case 0: //set for color 'green' 1.6
        return Color.fromRGBO(_currentColor,
            255 - int.parse((value.percentage * 1.6).toStringAsFixed(0)), 0, 1);
      default: //default color 'blue'
        return Color.fromRGBO(
            0,
            255 - int.parse((value.percentage * 1.6).toStringAsFixed(0)),
            255,
            1);
    }
  }

  double _setHeight() {
    switch (MediaQuery.of(context).orientation) {
      case Orientation.portrait:
        return MediaQuery.of(context).size.width / 1.1;
      case Orientation.landscape:
        return MediaQuery.of(context).size.height;
      default:
        return 350;
    }
  }

  void _callBack() {
    setState(() {});
  }

  void _onTabTapped(int index) {
    _currentIndex = index;
    _load();
  }

  Future<void> _load({bool action}) async {
    if (action != null && action) {
      await UserGrants.sync(scaffoldKey: _scaffoldKey);
    }
    if (_payOfficeList == null) {
      _payOfficeList = await ImplPayOfficeDAO().getUnDeleted();
    }
    setState(() {
      _currentIndex == 2
          ? _payDeskList = PayDeskDAO().getAllExceptTransfer()
          : _payDeskList = ImplPayDeskDao()
              .getByType(_sceneMap.values.elementAt(_currentIndex));
      _costItemsList = CostItemDAO().getUnDeleted();
      _incomeItemsList = IncomeItemDAO().getUnDeleted();
    });
  }
}
