
import 'package:enterprise/models/analytic_data.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:percent_indicator/linear_percent_indicator.dart';

class AnalyticChartsList{

  Widget toShowCharts(List<charts.Series<AnalyticData, String>> seriesList){
    return charts.PieChart(
      seriesList,
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

  Widget toShowChartsSimple(List<charts.Series<AnalyticData, String>> seriesList){
    return charts.BarChart(
      seriesList,
      animate: true,
    );
  }

  Widget showChartsLabels(int currency, var preparedMap, var amountFormatter, int currentColor, int currentIndex) {
    Map<dynamic, PayDesk> _toShow = preparedMap;
    return ListView.builder(
      itemCount: _toShow.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        amountFormatter.text = _toShow.values.elementAt(index).amount.toStringAsFixed(2);
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
                    color: currentIndex == 2 ? _toShow.keys.elementAt(index).color : _setColor(_toShow.values.elementAt(index), currentColor),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width/1.2,
                  child: Text(
                    "${_toShow.keys.elementAt(index).name} ${amountFormatter.text} ${CURRENCY_SYMBOL[currency]}",
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

  Widget showGeneralInformation(int currency, Map<dynamic, PayDesk> toShow, var amountFormatter, int currentColor, int currentIndex){
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: toShow.length,
        itemBuilder: (BuildContext context, int index) {
          amountFormatter.text = toShow.values.elementAt(index).amount.toStringAsFixed(2);
          return Card(
            child: Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(toShow.keys.elementAt(index).name),
                    trailing: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text("${amountFormatter.text} ${CURRENCY_SYMBOL[currency]}" ),
                          SizedBox(height: 5,),
                          Text("${toShow.values.elementAt(index).percentage.toStringAsFixed(2).replaceAll(".", ",")} %",
                            style: TextStyle(color: currentIndex == 2 ? toShow.keys.elementAt(index).color : currentIndex == 0 ? Colors.red : Colors.green[800]),),
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
                      percent: toShow.values.elementAt(index).percentage/100,
                      progressColor: currentIndex == 2 ? toShow.keys.elementAt(index).color : _setColor(toShow.values.elementAt(index), currentColor),
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
}