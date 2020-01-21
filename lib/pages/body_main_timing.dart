import 'package:date_format/date_format.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class BodyMain extends StatefulWidget {
  final Profile profile;

  BodyMain(
    this.profile,
  );

  BodyMainState createState() => BodyMainState();
}

class BodyMainState extends State<BodyMain> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Хронометраж'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Сьогодні',
              ),
              Tab(
                text: 'Історія',
              ),
            ],
          ),
        ),
        drawer: AppDrawer(widget.profile),
        body: TabBarView(
          children: <Widget>[
            TimingMain(),
            TimingHistory(),
          ],
        ),
      ),
    );
  }
}

class TimingMain extends StatefulWidget {
  @override
  _TimingMainState createState() => _TimingMainState();
}

class _TimingMainState extends State<TimingMain> {
  String currentTimeStatus = '';
  String userID;
  Future<List<Timing>> statuses;

  void initState() {
    statuses = getStatuses();
  }

  Future<List<Timing>> getStatuses() async {
    final now = DateTime.now();
    final date = new DateTime(now.year, now.month, now.day).toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(KEY_USER_ID) ?? "";

    if (currentTimeStatus.isEmpty) {
      String _currentTimeStatus = prefs.getString("dd") ?? "";
      setState(() {
        currentTimeStatus = _currentTimeStatus;
      });
    }

    return await DBProvider.db.getUserTiming(date, userID);
  }

  handleStatus(String timingStatus) async {
    final now = DateTime.now();
    final date = new DateTime(now.year, now.month, now.day).toIso8601String();

    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";

    if (timingStatus == TIMING_STATUS_WORKDAY) {
      Timing timing = Timing(
          date: date,
          userID: userID,
          operation: timingStatus,
          startTime: now.toIso8601String());

      await DBProvider.db.newTiming(timing);
    } else if (timingStatus == '') {
      List<Timing> listTiming =
          await DBProvider.db.getOpenTimingOperation(date, userID);
      for (var timing in listTiming) {
        await DBProvider.db.endOperation(timing);
      }

      listTiming = await DBProvider.db.getOpenTiming(date, userID);
      for (var timing in listTiming) {
        await DBProvider.db.endOperation(timing);
      }
    } else if (timingStatus == TIMING_STATUS_JOB ||
        timingStatus == TIMING_STATUS_DINER ||
        timingStatus == TIMING_STATUS_BREAK) {
      List<Timing> listTiming =
          await DBProvider.db.getOpenTimingOperation(date, userID);

      for (var timing in listTiming) {
        await DBProvider.db.endOperation(timing);
      }

      Timing timing = Timing(
          date: date,
          userID: userID,
          operation: timingStatus,
          startTime: now.toIso8601String());

      await DBProvider.db.newTiming(timing);
    } else if (timingStatus == TIMING_STATUS_STOP) {
      List<Timing> listTiming =
          await DBProvider.db.getOpenTimingOperation(date, userID);

      for (var timing in listTiming) {
        await DBProvider.db.endOperation(timing);
      }
    }

    statuses = getStatuses();

    prefs.setString("dd", timingStatus);
    setState(() {
      currentTimeStatus = timingStatus;
    });
  }

  Map<String, String> mapOperation = {
    TIMING_STATUS_WORKDAY: "Робочий день",
    TIMING_STATUS_JOB: "Робота",
    TIMING_STATUS_DINER: "Обід",
    TIMING_STATUS_BREAK: "Перерва",
  };

  String formatISO8601DataToTime(String strDataTime) {
    if (strDataTime.isEmpty) return "";

    DateTime _dateTime = DateTime.parse(strDataTime);
    return formatDate(_dateTime, [hh, ':', nn, ':', ss]);
  }

  Widget rowIcon(String operation) {
    switch (operation) {
      case TIMING_STATUS_WORKDAY:
        return Icon(Icons.work);
      case TIMING_STATUS_JOB:
        return Icon(Icons.add);
      case TIMING_STATUS_DINER:
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
        DataCell(Row(
          children: <Widget>[
            rowIcon(timing.operation),
            SizedBox(
              width: 10.0,
            ),
            Text(mapOperation[timing.operation]),
          ],
        )),
        DataCell(Text(formatISO8601DataToTime(timing.startTime))),
        DataCell(Text(formatISO8601DataToTime(timing.endTime))),
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
      body: Container(
//        color: Colors.blueGrey,
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
              }
            }),
      ),
      floatingActionButton: TimingFAB(currentTimeStatus, (String value) {
        if (currentTimeStatus != value) {
          handleStatus(value);
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

  @override
  Widget build(BuildContext context) {
    switch (widget.timingStatus) {
      case '':
        return FloatingActionButton(
          onPressed: () {
            widget.onPressed(TIMING_STATUS_WORKDAY);
          },
          child: Icon(Icons.work),
        );
      case (TIMING_STATUS_WORKDAY):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              label: "Робота",
              child: Icon(Icons.add),
              onTap: () {
                widget.onPressed(TIMING_STATUS_JOB);
              },
            ),
            SpeedDialChild(
              label: "Обід",
              child: Icon(Icons.fastfood),
              onTap: () {
                widget.onPressed(TIMING_STATUS_DINER);
              },
            ),
            SpeedDialChild(
              label: "Перерва",
              child: Icon(Icons.toys),
              onTap: () {
                widget.onPressed(TIMING_STATUS_BREAK);
              },
            ),
            SpeedDialChild(
              label: "Домів",
              child: Icon(Icons.home),
              onTap: () {
                setState(() {
                  widget.onPressed('');
                });
              },
            ),
          ],
        );
      case (TIMING_STATUS_STOP):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              label: "Робота",
              child: Icon(Icons.add),
              onTap: () {
                widget.onPressed(TIMING_STATUS_JOB);
              },
            ),
            SpeedDialChild(
              label: "Обід",
              child: Icon(Icons.fastfood),
              onTap: () {
                widget.onPressed(TIMING_STATUS_DINER);
              },
            ),
            SpeedDialChild(
              label: "Перерва",
              child: Icon(Icons.toys),
              onTap: () {
                widget.onPressed(TIMING_STATUS_BREAK);
              },
            ),
            SpeedDialChild(
              label: "Домів",
              child: Icon(Icons.home),
              onTap: () {
                widget.onPressed('');
              },
            ),
          ],
        );
      case (TIMING_STATUS_JOB):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              label: "Обід",
              child: Icon(Icons.fastfood),
              onTap: () {
                widget.onPressed(TIMING_STATUS_DINER);
              },
            ),
            SpeedDialChild(
              label: "Перерва",
              child: Icon(Icons.toys),
              onTap: () {
                widget.onPressed(TIMING_STATUS_BREAK);
              },
            ),
            SpeedDialChild(
              label: "Завершити",
              child: Icon(Icons.stop),
              onTap: () {
                widget.onPressed(TIMING_STATUS_STOP);
              },
            ),
            SpeedDialChild(
              label: "Домів",
              child: Icon(Icons.home),
              onTap: () {
                widget.onPressed('');
              },
            ),
          ],
        );
      case (TIMING_STATUS_DINER):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              label: "Робота",
              child: Icon(Icons.add),
              onTap: () {
                widget.onPressed(TIMING_STATUS_JOB);
              },
            ),
            SpeedDialChild(
              label: "Перерва",
              child: Icon(Icons.toys),
              onTap: () {
                widget.onPressed(TIMING_STATUS_BREAK);
              },
            ),
            SpeedDialChild(
              label: "Завершити",
              child: Icon(Icons.stop),
              onTap: () {
                widget.onPressed(TIMING_STATUS_STOP);
              },
            ),
            SpeedDialChild(
              label: "Домів",
              child: Icon(Icons.home),
              onTap: () {
                widget.onPressed('');
              },
            ),
          ],
        );
      case (TIMING_STATUS_BREAK):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              label: "Робота",
              child: Icon(Icons.add),
              onTap: () {
                widget.onPressed(TIMING_STATUS_JOB);
              },
            ),
            SpeedDialChild(
              label: "Обід",
              child: Icon(Icons.fastfood),
              onTap: () {
                widget.onPressed(TIMING_STATUS_DINER);
              },
            ),
            SpeedDialChild(
              label: "Завершити",
              child: Icon(Icons.stop),
              onTap: () {
                widget.onPressed(TIMING_STATUS_STOP);
              },
            ),
            SpeedDialChild(
              label: "Домів",
              child: Icon(Icons.home),
              onTap: () {
                widget.onPressed('');
              },
            ),
          ],
        );
      default:
        return FloatingActionButton(
          onPressed: () {
            widget.onPressed('');
          },
          child: Icon(Icons.stop),
        );
    }
  }
}

class TimingHistory extends StatefulWidget {
  @override
  _TimingHistoryState createState() => _TimingHistoryState();
}

class _TimingHistoryState extends State<TimingHistory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Center(
        child: Text(
          'Історія',
          style: TextStyle(fontSize: 50),
        ),
      ),
    );
  }
}
