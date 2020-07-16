import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/timing.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:enterprise/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

class BodyMain extends StatefulWidget {
  final Profile profile;

  BodyMain(
    this.profile,
  );

  BodyMainState createState() => BodyMainState();
}

class BodyMainState extends State<BodyMain> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        profile: widget.profile,
      ),
      body: TimingMain(_scaffoldKey),
    );
  }
}

class TimingMain extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  TimingMain(
    this.parentScaffoldKey,
  );

  @override
  _TimingMainState createState() => _TimingMainState();
}

class _TimingMainState extends State<TimingMain> {
  String currentTimeStatus = '';
  String userID;
  Future<List<Timing>> statuses;
  Future<List<charts.Series<ChartData, String>>> listChartData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWidgetState());
  }

  void _initWidgetState() async {
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";

    _setCurrentStatus(_userID);
    statuses = _getTiming(_userID);
    listChartData = _createChartData(statuses);

    setState(() {
      userID = _userID;
    });
  }

  Future<List<Timing>> _getTiming(String userID) async {
    final dateTimeNow = DateTime.now();
    final beginningDay = Utility.beginningOfDay(dateTimeNow);

    return await TimingDAO().getUndeletedByDateUserId(beginningDay, userID);
  }

  Future<List<charts.Series<ChartData, String>>> _createChartData(Future<List<Timing>> listTiming) async {
    List<Timing> _listTiming = await listTiming;
    List<ChartData> _chartData = [];
    double timingHours = 0.0;

    for (var _timing in _listTiming) {
      if (_timing.status == TIMING_STATUS_WORKDAY) {
        continue;
      }

      DateTime endDate = _timing.endedAt;
      if (endDate == null) {
        endDate = DateTime.now();
      }

      double duration = (endDate.millisecondsSinceEpoch - _timing.startedAt.millisecondsSinceEpoch) / 3600000;
      timingHours += duration;

      int existIndex = _chartData.indexWhere((record) => record.title.contains(_timing.status));
      if (existIndex == -1) {
        _chartData.add(new ChartData(title: _timing.status, value: duration, color: _timing.color()));
      } else {
        _chartData[existIndex].value += duration;
      }
    }

    for (var _record in _chartData) {
      _record.title = timingAlias[_record.title] + ' - ' + _record.value.toStringAsFixed(2) + ' год';
      _record.value = ((_record.value / timingHours * 100.0).round().toDouble());
    }

    return [
      new charts.Series<ChartData, String>(
          id: 'status',
          data: _chartData,
          domainFn: (ChartData record, _) => record.title,
          measureFn: (ChartData record, _) => record.value,

          // Set a label accessor to control the text of the arc label.
          labelAccessorFn: (ChartData record, _) => '${record.title}',
          colorFn: (ChartData record, _) => charts.ColorUtil.fromDartColor(record.color)),
    ];
  }

  _handleTiming(String timingStatus) async {
    final dateTimeNow = DateTime.now();
    final dayBegin = new DateTime(dateTimeNow.year, dateTimeNow.month, dateTimeNow.day);

    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(KEY_USER_ID) ?? "";

    if (timingStatus == TIMING_STATUS_WORKDAY) {
      Timing timing = Timing(
        date: dayBegin,
        userID: userID,
        status: timingStatus,
        startedAt: dateTimeNow,
      );

      await TimingDAO().insert(timing);
    } else if (timingStatus == '') {
      List<Timing> listTiming = await TimingDAO().getOpenStatusByDateUserId(dayBegin, userID);
      for (var timing in listTiming) {
        timing.endedAt = dateTimeNow;
        await TimingDAO().updateByMobID(timing);
      }

      listTiming = await TimingDAO().getOpenWorkdayByDateUserId(dayBegin, userID);
      for (var timing in listTiming) {
        timing.endedAt = dateTimeNow;
        await TimingDAO().updateByMobID(timing);
      }
    } else if (timingStatus == TIMING_STATUS_JOB ||
        timingStatus == TIMING_STATUS_LUNCH ||
        timingStatus == TIMING_STATUS_BREAK) {
      List<Timing> listTiming = await TimingDAO().getOpenStatusByDateUserId(dayBegin, userID);

      for (var timing in listTiming) {
        timing.endedAt = dateTimeNow;
        await TimingDAO().updateByMobID(timing);
      }

      Timing timing = Timing(date: dayBegin, userID: userID, status: timingStatus, startedAt: dateTimeNow);

      await TimingDAO().insert(timing);
    } else if (timingStatus == TIMING_STATUS_STOP) {
      List<Timing> listTiming = await TimingDAO().getOpenStatusByDateUserId(dayBegin, userID);

      for (var timing in listTiming) {
        timing.endedAt = dateTimeNow;
        await TimingDAO().updateByMobID(timing);
      }
    }

    // отримаємо поточний стан виходячи із записів в локальній базі
    _setCurrentStatus(userID);
    // прочитаємо записи локальної бази
    statuses = _getTiming(userID);
    // відобразимо на кругові діаграмі актульні даті з локальної бази
    listChartData = _createChartData(statuses);

    // відправимо змінені дані в хмару і отримаємо актуалізуємо локальну базу
    Timing.upload(userID);
  }

  // процедура актуалізації локальної бази даними з хмари
  Future<void> _refreshTiming() async {
    await Timing.downloadByDate(DateTime.now());

    // відправимо змінені дані в хмару і отримаємо актуалізуємо локальну базу
    _setCurrentStatus(userID);
    // прочитаємо записи локальної бази
    statuses = _getTiming(userID);
    // відобразимо на кругові діаграмі актульні даті з локальної бази
    listChartData = _createChartData(statuses);
  }

  void _setCurrentStatus(userID) async {
    String _currentTimeStatus = await TimingDAO().getCurrentStatusByUser(userID);
    setState(() {
      currentTimeStatus = _currentTimeStatus;
    });
  }

  var _tapPosition;

  void _showCustomMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    showMenu(
            context: context,
            items: <PopupMenuEntry<String>>[PlusMinusEntry()],
            position: RelativeRect.fromRect(
                _tapPosition & Size(40, 40), // smaller rect, the touch area
                Offset.zero & overlay.size // Bigger rect, the entire screen
                ))
        // This is how you handle user selection
        .then<void>((String delta) {
      // delta would be null if user taps on outside the popup menu
      // (causing it to close without making selection)
      if (delta == null) return;

//      setState(() {
//        _count = _count + delta;
//      });
    });

    // Another option:
    //
    // final delta = await showMenu(...);
    //
    // Then process `delta` however you want.
    // Remember to make the surrounding function `async`, that is:
    //
    // void _showCustomMenu() async { ... }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget rowIcon(String status) {
    switch (status) {
      case TIMING_STATUS_WORKDAY:
        return Icon(FontAwesomeIcons.building);
      case TIMING_STATUS_JOB:
        return Icon(FontAwesomeIcons.hammer);
      case TIMING_STATUS_LUNCH:
        return Icon(Icons.fastfood);
      case TIMING_STATUS_BREAK:
        return Icon(Icons.toys);
      default:
        return SizedBox(
          width: 24.0,
        );
    }
  }

  Widget dataTable(listTiming) {
    List<DataRow> dataRows = [];

    for (var timing in listTiming) {
      dataRows.add(DataRow(cells: <DataCell>[
        DataCell(GestureDetector(
          // This does not give the tap position ...
          onLongPress: _showCustomMenu,
          // Have to remember it on tap-down.
          onTapDown: _storePosition,
          child: Row(
            children: <Widget>[
              rowIcon(timing.status),
              SizedBox(
                width: 10.0,
              ),
              Text(timingAlias[timing.status]),
            ],
          ),
        )),
        DataCell(Text(timing.startedAt != null ? formatDate(timing.startedAt, [HH, ':', nn, ':', ss]) : "")),
        DataCell(Text(timing.endedAt != null ? formatDate(timing.endedAt, [HH, ':', nn, ':', ss]) : "")),
      ]));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Статус'),
          ),
          DataColumn(
            label: Text('Початок'),
          ),
          DataColumn(
            label: Text('Кінець'),
          )
        ],
        rows: dataRows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshTiming,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leading: MaterialButton(
                onPressed: () {
                  widget.parentScaffoldKey.currentState.openDrawer();
                },
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              title: Text('Хронометраж'),
              pinned: true,
              floating: false,
              expandedHeight: 300.0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.history),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/timinghistory',
                      arguments: "",
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: FutureBuilder(
                    future: listChartData,
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
                          return DonutAutoLabelChart(
                            snapshot.data,
                            animate: true,
                          );
                        default:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                      }
                    }),
              ),
            ),
            SliverFillRemaining(
              child: FutureBuilder(
                  future: statuses,
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
                        return dataTable(snapshot.data);
                      default:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: TimingFAB(currentTimeStatus, (String value) {
        if (currentTimeStatus != value) {
          _handleTiming(value);
        }
      }),
    );
  }
}

class TimingFAB extends StatefulWidget {
  final String timingStatus;
  final Function(String value) onPressed;

  TimingFAB(
    this.timingStatus,
    this.onPressed,
  );

  @override
  _TimingFABState createState() => _TimingFABState();
}

class _TimingFABState extends State<TimingFAB> {
  String currentTimingStatus;

  Widget workdayFAB() {
    return FloatingActionButton(
      onPressed: () {
        widget.onPressed(TIMING_STATUS_WORKDAY);
      },
      child: Icon(FontAwesomeIcons.building),
    );
  }

  SpeedDialChild jobSDC() {
    return SpeedDialChild(
      label: "Почати роботу",
      child: Icon(FontAwesomeIcons.hammer),
      onTap: () {
        widget.onPressed(TIMING_STATUS_JOB);
      },
    );
  }

  SpeedDialChild lanchSDC() {
    return SpeedDialChild(
      label: "Обід",
      child: Icon(Icons.fastfood),
      onTap: () {
        widget.onPressed(TIMING_STATUS_LUNCH);
      },
    );
  }

  SpeedDialChild breakSDC() {
    return SpeedDialChild(
      label: "Перерва",
      child: Icon(Icons.toys),
      onTap: () {
        widget.onPressed(TIMING_STATUS_BREAK);
      },
    );
  }

  SpeedDialChild stopSDC() {
    return SpeedDialChild(
      label: "Завершити роботу",
      child: Icon(Icons.stop),
      onTap: () {
        setState(() {
          widget.onPressed(TIMING_STATUS_STOP);
        });
      },
    );
  }

  SpeedDialChild homeSDC() {
    return SpeedDialChild(
      label: "Турнікет (вихід)",
      child: Icon(Icons.home),
      onTap: () {
        setState(() {
          widget.onPressed('');
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.timingStatus) {
      case '':
        return workdayFAB();
      case (TIMING_STATUS_WORKDAY):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            lanchSDC(),
            breakSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_STOP):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            lanchSDC(),
            breakSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_JOB):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            lanchSDC(),
            breakSDC(),
            stopSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_LUNCH):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            breakSDC(),
            stopSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_BREAK):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            lanchSDC(),
            stopSDC(),
            homeSDC(),
          ],
        );
      default:
        return workdayFAB();
    }
  }
}

class DonutAutoLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutAutoLabelChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        //
        // [ArcLabelDecorator] will automatically position the label inside the
        // arc if the label will fit. If the label will not fit, it will draw
        // outside of the arc with a leader line. Labels can always display
        // inside or outside using [LabelPosition].
        //
        // Text style for inside / outside can be controlled independently by
        // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
        //
        // Example configuring different styles for inside/outside:
        //       new charts.ArcLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 100, startAngle: 30, arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }
}

class PlusMinusEntry extends PopupMenuEntry<String> {
  @override
  double height = 100;
//  // height doesn't matter, as long as we are not giving
//  // initialValue to showMenu().
//
  @override
  bool represents(String n) => n == '1' || n == '-1';

  @override
  PlusMinusEntryState createState() => PlusMinusEntryState();
}

class PlusMinusEntryState extends State<PlusMinusEntry> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: FlatButton(onPressed: _plus1, child: Text('+1'))),
        Expanded(child: FlatButton(onPressed: _minus1, child: Text('-1'))),
      ],
    );
  }

  void _plus1() {
    // This is how you close the popup menu and return user selection.
    Navigator.pop<int>(context, 1);
  }

  void _minus1() {
    Navigator.pop<int>(context, -1);
  }
}
