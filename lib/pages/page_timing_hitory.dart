import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_format/date_format.dart';
import 'package:enterprise/models/contatns.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/timing.dart';
import 'package:enterprise/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTimingHistory extends StatefulWidget {
  @override
  _PageTimingHistoryState createState() => _PageTimingHistoryState();
}

class _PageTimingHistoryState extends State<PageTimingHistory> {
  DateTime beginningPeriod = new DateTime.now().add(new Duration(days: -4));
  DateTime endPeriod = new DateTime.now();

  Future<List<Timing>> operations;
  Future<List<charts.Series<ChartData, String>>> chartData;
  String userID;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWidgetState());
  }

  void _initWidgetState() async {
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";

    operations = _getTiming(_userID);
    chartData = _createChartData(operations);

    setState(() {
      userID = _userID;
    });
  }

  Future<List<Timing>> _getTiming(String userID) async {
    List<Timing> result = [];
    DateTime currentDay = beginningPeriod;
    List<DateTime> listDate = [];

    do {
      DateTime beginningDay;

      beginningDay = Utility.beginningOfDay(currentDay);
      listDate.add(beginningDay);

      currentDay = currentDay.add(new Duration(days: 1));
    } while (Utility.beginningOfDay(currentDay).millisecondsSinceEpoch <=
        endPeriod.millisecondsSinceEpoch);

    List<Timing> listTiming =
        await TimingDAO().geUndeletedtPeriodByDatesUserId(listDate, userID);

    for (var _timing in listTiming) {
      if (_timing.operation == TIMING_STATUS_WORKDAY) {
        continue;
      }

      DateTime endDate = _timing.endedAt;
      if (endDate == null) {
        endDate = DateTime.now();
      }

      double duration = (endDate.millisecondsSinceEpoch -
              _timing.startedAt.millisecondsSinceEpoch) /
          3600000;

      int existIndex = result.indexWhere((record) =>
          (record.date == _timing.date) &&
          (record.operation == _timing.operation));
      if (existIndex == -1) {
        result.add(new Timing(
            date: _timing.date,
            operation: _timing.operation,
            duration: duration));
      } else {
        result[existIndex].duration += duration;
      }
    }

    return result;
  }

  Future<List<charts.Series<ChartData, String>>> _createChartData(
      Future<List<Timing>> listTiming) async {
    List<Timing> _listTiming = await listTiming;

    List<ChartData> jobChartData = [];
    List<ChartData> lanchChartData = [];
    List<ChartData> breakChartData = [];
    String strDate;

    for (var _timing in _listTiming) {
      strDate = formatDate(_timing.date, [yyyy, '-', mm, '-', dd]);

      switch (_timing.operation) {
        case TIMING_STATUS_JOB:
          jobChartData
              .add(new ChartData(title: strDate, value: _timing.duration));
          break;
        case TIMING_STATUS_LANCH:
          lanchChartData
              .add(new ChartData(title: strDate, value: _timing.duration));
          break;
        case TIMING_STATUS_BREAK:
          breakChartData
              .add(new ChartData(title: strDate, value: _timing.duration));
          break;
        default:
          break;
      }
    }

    return [
      // Blue bars with a lighter center color.
      new charts.Series<ChartData, String>(
        id: OPERATION_ALIAS[TIMING_STATUS_JOB],
        domainFn: (ChartData timing, _) => timing.title,
        measureFn: (ChartData timing, _) => timing.value,
        data: jobChartData,
      ),
      new charts.Series<ChartData, String>(
        id: OPERATION_ALIAS[TIMING_STATUS_LANCH],
        domainFn: (ChartData timing, _) => timing.title,
        measureFn: (ChartData timing, _) => timing.value,
        data: lanchChartData,
      ),
      new charts.Series<ChartData, String>(
        id: OPERATION_ALIAS[TIMING_STATUS_BREAK],
        domainFn: (ChartData timing, _) => timing.title,
        measureFn: (ChartData timing, _) => timing.value,
        data: breakChartData,
      ),
    ];
  }

  Widget dataTable(List<Timing> listTiming) {
    List<DataRow> dataRows = [];

    for (var timing in listTiming) {
      dataRows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(
              Text(timing.date != null
                  ? formatDate(timing.date, [yyyy, '-', mm, '-', dd])
                  : ""),
            ),
            DataCell(
              Text(OPERATION_ALIAS[timing.operation]),
            ),
            DataCell(
              Text(timing.duration.toStringAsFixed(2)),
            ),
//                Text('')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Дата'),
          ),
          DataColumn(
            label: Text('Стаус'),
          ),
          DataColumn(
            label: Text('Год'),
          )
        ],
        rows: dataRows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Історія хронометражу'),
            pinned: true,
            floating: false,
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              background: FutureBuilder(
                  future: chartData,
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
                        return SimpleSeriesLegend(
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
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: PeriodBar(
              minSize: 40.0,
              maxSize: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      DateTime picked = await showDatePicker(
                          context: context,
                          firstDate: new DateTime(2020),
                          initialDate: beginningPeriod,
                          lastDate: new DateTime(DateTime.now().year + 1));

                      if (picked != null) {
                        setState(() {
                          beginningPeriod = picked;
                        });

                        operations = _getTiming(userID);
                        chartData = _createChartData(operations);
                      }
                    },
                    color: Colors.white,
                    child: Text(
                      formatDate(beginningPeriod, [yyyy, '-', mm, '-', dd]),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        side:
                            BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                  SizedBox(
                    width: 24.0,
                  ),
                  FlatButton(
                    onPressed: () async {
                      DateTime picked = await showDatePicker(
                          context: context,
                          firstDate: new DateTime(2020),
                          initialDate: endPeriod,
                          lastDate: new DateTime(DateTime.now().year + 1));

                      if (picked != null) {
                        setState(() {
                          endPeriod = picked;
                        });

                        operations = _getTiming(userID);
                        chartData = _createChartData(operations);
                      }
                    },
                    color: Colors.white,
                    child:
                        Text(formatDate(endPeriod, [yyyy, '-', mm, '-', dd])),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        side:
                            BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: FutureBuilder(
              future: operations,
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
              },
            ),
          ),
        ],
      ),
    );
//      ]),
//      StreamBuilder(
//          stream: Firestore.instance.collection("chanel").snapshots(),
//          builder:
//              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//            if (!snapshot.hasData) {
//              return Center(
//                child: CircularProgressIndicator(),
//              );
//            }
//
//            return ListView.builder(
//              itemCount: snapshot.data.documents.length,
//              itemBuilder: (context, index) {
//                var documnet = snapshot.data.documents[index];
//                return ListTile(
//                  title: Text(documnet.data['title']),
//                  isThreeLine: true,
//                  leading: CircleAvatar(
//                    child: Text('1C'),
//                  ),
//                  subtitle: Text(
//                    documnet.data['news'],
//                    maxLines: 2,
//                    overflow: TextOverflow.ellipsis,
//                  ),
//                );
//              },
//            );
//          }),
//    );
  }
}

class SimpleSeriesLegend extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleSeriesLegend(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      // Add the series legend behavior to the chart to turn on series legends.
      // By default the legend will display above the chart.
      behaviors: [
        new charts.SeriesLegend(
          // Positions for "start" and "end" will be left and right respectively
          // for widgets with a build context that has directionality ltr.
          // For rtl, "start" and "end" will be right and left respectively.
          // Since this example has directionality of ltr, the legend is
          // positioned on the right side of the chart.
          position: charts.BehaviorPosition.end,
          // For a legend that is positioned on the left or right of the chart,
          // setting the justification for [endDrawArea] is aligned to the
          // bottom of the chart draw area.
          outsideJustification: charts.OutsideJustification.endDrawArea,
          // By default, if the position of the chart is on the left or right of
          // the chart, [horizontalFirst] is set to false. This means that the
          // legend entries will grow as new rows first instead of a new column.
          horizontalFirst: false,
          // By setting this value to 2, the legend entries will grow up to two
          // rows before adding a new column.
          desiredMaxRows: 5,
          // This defines the padding around each legend entry.
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
        )
      ],
    );
  }
}

class PeriodBar extends SliverPersistentHeaderDelegate {
  final double minSize;
  final double maxSize;
  final Widget child;

  PeriodBar({
    this.minSize,
    this.maxSize,
    this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return child;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => maxSize;

  @override
  // TODO: implement minExtent
  double get minExtent => minSize;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
