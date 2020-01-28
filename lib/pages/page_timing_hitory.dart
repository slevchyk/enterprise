import 'package:charts_flutter/flutter.dart' as charts;
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/models.dart';
import 'package:enterprise/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTimingHistory extends StatefulWidget {
  @override
  _PageTimingHistoryState createState() => _PageTimingHistoryState();
}

class _PageTimingHistoryState extends State<PageTimingHistory> {
  DateTime beginningPeriod = new DateTime.now().add(new Duration(days: -7));
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

    operations = _getOperations(_userID);
    chartData = _createChartData(operations);

    setState(() {
      userID = _userID;
    });
  }

  Future<List<Timing>> _getOperations(String userID) async {
    DateTime currentDay = beginningPeriod;
    List<DateTime> listDate = [];

    do {
      DateTime beginningDay;

      beginningDay = Utility.beginningOfDay(currentDay);
      listDate.add(beginningDay);

      currentDay = currentDay.add(new Duration(days: 1));
    } while (
        currentDay.millisecondsSinceEpoch < endPeriod.millisecondsSinceEpoch);

    return DBProvider.db.getTimingPeriod(listDate, userID);
  }

  Future<List<charts.Series<ChartData, String>>> _createChartData(
      Future<List<Timing>> listTiming) async {
    List<Timing> _listTiming = await listTiming;

    List<ChartData> jobChartData = [];
    List<ChartData> lanchChartData = [];
    List<ChartData> breakChartData = [];
    String strDate;

    for (var _timing in _listTiming) {
      if (_timing.operation == TIMING_STATUS_WORKDAY) {
        continue;
      }

      strDate = formatDate(_timing.date, [yyyy, '-', mm, '-', dd]);

      DateTime endDate = _timing.endDate;
      if (endDate == null) {
        endDate = DateTime.now();
      }

      double duration = (endDate.millisecondsSinceEpoch -
              _timing.startDate.millisecondsSinceEpoch) /
          3600000;

      switch (_timing.operation) {
        case TIMING_STATUS_JOB:
          int existIndex = jobChartData
              .indexWhere((record) => record.title.contains(strDate));
          if (existIndex == -1) {
            jobChartData.add(new ChartData(title: strDate, value: duration));
          } else {
            jobChartData[existIndex].value += duration;
          }
          break;
        case TIMING_STATUS_LANCH:
          int existIndex = lanchChartData
              .indexWhere((record) => record.title.contains(strDate));
          if (existIndex == -1) {
            lanchChartData.add(new ChartData(title: strDate, value: duration));
          } else {
            lanchChartData[existIndex].value += duration;
          }
          break;
        case TIMING_STATUS_BREAK:
          int existIndex = breakChartData
              .indexWhere((record) => record.title.contains(strDate));
          if (existIndex == -1) {
            breakChartData.add(new ChartData(title: strDate, value: duration));
          } else {
            breakChartData[existIndex].value += duration;
          }
          break;
        default:
          break;
      }
    }

    return [
      // Blue bars with a lighter center color.
      new charts.Series<ChartData, String>(
        id: TIMING_STATUS_JOB,
        domainFn: (ChartData timing, _) => timing.title,
        measureFn: (ChartData timing, _) => timing.value,
        data: jobChartData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      // Solid red bars. Fill color will default to the series color if no
      // fillColorFn is configured.
      new charts.Series<ChartData, String>(
        id: TIMING_STATUS_LANCH,
        domainFn: (ChartData timing, _) => timing.title,
        measureFn: (ChartData timing, _) => timing.value,
        data: lanchChartData,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
      // Hollow green bars.
      new charts.Series<ChartData, String>(
        id: TIMING_STATUS_BREAK,
        domainFn: (ChartData timing, _) => timing.title,
        measureFn: (ChartData timing, _) => timing.value,
        data: breakChartData,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.transparent,
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
                  ? formatDate(timing.date, [dd, '-', mm, '-', yyyy])
                  : ""),
            ),
            DataCell(
              Text(timing.operation),
            ),
            DataCell(
//              Text(timing.duration?.toStringAsFixed(2)),
                Text('')),
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
                        return GroupedFillColorBarChart(
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
            child: ListView(
              children: <Widget>[
                Row(
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

                          operations = _getOperations(userID);
                          chartData = _createChartData(operations);
                        }
                      },
                      child: Text(formatDate(
                          beginningPeriod, [yyyy, '-', mm, '-', dd])),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor)),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(':'),
                    SizedBox(
                      width: 10.0,
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

                          operations = _getOperations(userID);
                          chartData = _createChartData(operations);
                        }
                      },
                      child:
                          Text(formatDate(endPeriod, [yyyy, '-', mm, '-', dd])),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
                FutureBuilder(
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
                    }),
              ],
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

class GroupedFillColorBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GroupedFillColorBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      // Configure a stroke width to enable borders on the bars.
      defaultRenderer: new charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.grouped, strokeWidthPx: 2.0),
    );
  }
}
