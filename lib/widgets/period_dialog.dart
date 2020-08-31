import 'package:date_format/date_format.dart';
import 'package:enterprise/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodDialog{

  /// To update window, use: "PeriodDialog.showPeriodDialog().whenComplete(() => setState((){}));"
  /// If TextEditingController is empty, controllers will set automatically
  /// Firs date to choose is 01.01.2000 and last date current year + 1
  /// Last date to choose is current day, month, year
  /// You can use setControllersMap to set map

  static Future showPeriodDialog(BuildContext context, TextEditingController dateFrom, TextEditingController dateTo,  Map<SortControllers, bool> controllersMap) {
    DateTime _now = DateTime.now();
    DateTime _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _setControllersIfEmpty(dateFrom, dateTo, _now);
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
                                firstDate: DateTime(2000), // set first date
                                initialDate: DateFormat('dd.MM.yyyy').parse(dateFrom.text),
                                lastDate: DateTime(_now.year, _now.month, _now.day)); // set last date

                            if (picked != null) {
                              dateFrom.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                            }
                          },
                          child: TextFormField(
                            controller: dateFrom,
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
                                initialDate: DateFormat('dd.MM.yyyy').parse(dateTo.text),
                                lastDate: DateTime(_now.year, _now.month, _now.day));

                            if (picked != null) {
                              dateTo.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                            }
                          },
                          child: TextFormField(
                            controller: dateTo,
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
                                    controllersMap.update(SortControllers.reload, (value) => false);
                                    controllersMap.update(SortControllers.period, (value) => true);
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Сьогодні"),
                                  onPressed: () {
                                    dateTo.text = DateFormat('dd.MM.yyyy').format(_now);
                                    dateFrom.text = DateFormat('dd.MM.yyyy').format(_now);
                                    controllersMap.updateAll((key, value) => false);
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Вчора"),
                                  onPressed: () {
                                    final _yesterday = DateTime(_now.year, _now.month, _now.day-1);
                                    dateTo.text = DateFormat('dd.MM.yyyy').format(_yesterday);
                                    dateFrom.text = DateFormat('dd.MM.yyyy').format(_yesterday);
                                    controllersMap.updateAll((key, value) => false);
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Поточний місяць"),
                                  onPressed: (){
                                    dateFrom.text = DateFormat('dd.MM.yyyy').format(_firstDayOfMonth);
                                    dateTo.text = DateFormat('dd.MM.yyyy').format(_now);
                                    controllersMap.update(SortControllers.reload, (value) => false);
                                    controllersMap.update(SortControllers.period, (value) => true);
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Попередній місяць"),
                                  onPressed: (){
                                    final _firstDayOfPreviousMonth = DateTime(_now.year, _now.month-1, 1);
                                    final _lastDayOfPreviousMonth = DateTime(_now.year, _now.month, 0);
                                    dateFrom.text = DateFormat('dd.MM.yyyy').format(_firstDayOfPreviousMonth);
                                    dateTo.text = DateFormat('dd.MM.yyyy').format(_lastDayOfPreviousMonth);
                                    controllersMap.update(SortControllers.reload, (value) => false);
                                    controllersMap.update(SortControllers.period, (value) => true);
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("За весь час"),
                                  onPressed: (){
                                    final _lastDate = DateTime(2000, 1, 1);
                                    dateFrom.text = formatDate(_lastDate, [dd, '.', mm, '.', yyyy]);
                                    dateTo.text = formatDate(_now, [dd, '.', mm, '.', yyyy]);
                                    controllersMap.updateAll((key, value) => true);
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

  static _setControllersIfEmpty(TextEditingController dateFrom, TextEditingController dateTo, DateTime now){
    if(dateFrom.text.isEmpty || dateTo.text.isEmpty){
      dateFrom.text = formatDate(DateTime(now.year, now.month, 1), [dd, '.', mm, '.', yyyy]);
      dateTo.text = formatDate(now, [dd, '.', mm, '.', yyyy]);
    }
  }

  static Map<SortControllers, bool> setControllersMap(){
    return {SortControllers.reload : true, SortControllers.period : true};
  }

}