import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageTimingHistory extends StatefulWidget {
  @override
  _PageTimingHistoryState createState() => _PageTimingHistoryState();
}

class _PageTimingHistoryState extends State<PageTimingHistory> {
  DateTime beginningPeriod = new DateTime.now().add(new Duration(days: -7));
  DateTime endPeriod = new DateTime.now();

  Future<List<ChartData>> jobChartData;
  Future<List<ChartData>> lanchChartData;
  Future<List<ChartData>> breakChartData;

  createChartData() {}

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
              background: GroupedFillColorBarChart.withSampleData(),
//                FutureBuilder(
//                    future: listChartData,
//                    builder: (BuildContext context, AsyncSnapshot snapshot) {
//                      switch (snapshot.connectionState) {
//                        case ConnectionState.none:
//                          return Center(
//                            child: CircularProgressIndicator(),
//                          );
//                        case ConnectionState.waiting:
//                          return Center(
//                            child: CircularProgressIndicator(),
//                          );
//                        case ConnectionState.active:
//                          return Center(
//                            child: CircularProgressIndicator(),
//                          );
//                        case ConnectionState.done:
//                          return DonutAutoLabelChart(
//                            snapshot.data,
//                            animate: true,
//                          );
//                        default:
//                          return Center(
//                            child: CircularProgressIndicator(),
//                          );
//                      }
//                    }),
//              background: DonutAutoLabelChart.withSampleData(),
            ),
          ),
          SliverFillRemaining(
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
//                    Icon(
//                      Icons.calendar_today,
//                      color: Theme.of(context).primaryColor,
//                    ),
//                    SizedBox(
//                      width: 10.0,
//                    ),
                    Text('період з:'),
                    SizedBox(
                      width: 10.0,
                    ),
                    FlatButton(
                      onPressed: () async {
                        DateTime picked = await showDatePicker(
                            context: context,
                            firstDate: new DateTime(2020),
                            initialDate: beginningPeriod,
                            lastDate: new DateTime(DateTime.now().year + 1));

                        if (picked != null)
                          setState(() {
                            beginningPeriod = picked;
                          });
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
                    Text('по:'),
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

                        if (picked != null)
                          setState(() {
                            endPeriod = picked;
                          });
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

  factory GroupedFillColorBarChart.withSampleData() {
    return new GroupedFillColorBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

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

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
    ];

    final tableSalesData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
    ];

    final mobileSalesData = [
      new OrdinalSales('2014', 10),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 50),
      new OrdinalSales('2017', 45),
    ];

    return [
      // Blue bars with a lighter center color.
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      // Solid red bars. Fill color will default to the series color if no
      // fillColorFn is configured.
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
      ),
      // Hollow green bars.
      new charts.Series<OrdinalSales, String>(
        id: 'Mobile',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: mobileSalesData,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.transparent,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
