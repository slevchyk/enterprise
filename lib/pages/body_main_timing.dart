import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  Future<List<Timing>> operations;

  void initState() {
    operations = getOperations();
  }

  Future<List<Timing>> getOperations() async {
    final dateTimeNow = DateTime.now();
    final dayBegin =
        new DateTime(dateTimeNow.year, dateTimeNow.month, dateTimeNow.day);

    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(KEY_USER_ID) ?? "";

    if (currentTimeStatus.isEmpty) {
      String _currentTimeStatus = prefs.getString(KEY_CURRENT_STATUS) ?? "";
      setState(() {
        currentTimeStatus = _currentTimeStatus;
      });
    }

    return await DBProvider.db.getUserTiming(dayBegin, userID);
  }

  handleOperation(String timingOperation) async {
    final dateTimeNow = DateTime.now();
    final dayBegin =
        new DateTime(dateTimeNow.year, dateTimeNow.month, dateTimeNow.day);

    final prefs = await SharedPreferences.getInstance();

    String userID = prefs.getString(KEY_USER_ID) ?? "";

    if (timingOperation == TIMING_STATUS_WORKDAY) {
      Timing timing = Timing(
        date: dayBegin,
        userID: userID,
        operation: timingOperation,
        startDate: dateTimeNow,
      );

      await DBProvider.db.newTiming(timing);
    } else if (timingOperation == '') {
      List<Timing> listTiming =
          await DBProvider.db.getTimingOpenOperation(dayBegin, userID);
      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }

      listTiming = await DBProvider.db.getTimingOpenWorkday(dayBegin, userID);
      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }
    } else if (timingOperation == TIMING_STATUS_JOB ||
        timingOperation == TIMING_STATUS_LANCH ||
        timingOperation == TIMING_STATUS_BREAK) {
      List<Timing> listTiming =
          await DBProvider.db.getTimingOpenOperation(dayBegin, userID);

      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }

      Timing timing = Timing(
          date: dayBegin,
          userID: userID,
          operation: timingOperation,
          startDate: dateTimeNow);

      await DBProvider.db.newTiming(timing);
    } else if (timingOperation == TIMING_STATUS_STOP) {
      List<Timing> listTiming =
          await DBProvider.db.getTimingOpenOperation(dayBegin, userID);

      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }
    }

    operations = getOperations();

    prefs.setString(KEY_CURRENT_STATUS, timingOperation);
    setState(() {
      currentTimeStatus = timingOperation;
    });
  }

  Map<String, String> mapOperation = {
    TIMING_STATUS_WORKDAY: "Робочий день",
    TIMING_STATUS_JOB: "Робота",
    TIMING_STATUS_LANCH: "Обід",
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
        return Icon(FontAwesomeIcons.building);
      case TIMING_STATUS_JOB:
        return Icon(FontAwesomeIcons.hammer);
      case TIMING_STATUS_LANCH:
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
        DataCell(Text(timing.startDate != null
            ? formatDate(timing.startDate, [hh, ':', nn, ':', ss])
            : "")),
        DataCell(Text(timing.endDate != null
            ? formatDate(timing.endDate, [hh, ':', nn, ':', ss])
            : "")),
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
              }
            }),
      ),
      floatingActionButton: TimingFAB(currentTimeStatus, (String value) {
        if (currentTimeStatus != value) {
          handleOperation(value);
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
      label: "Робота",
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
        widget.onPressed(TIMING_STATUS_LANCH);
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
      label: "Завершити",
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
      label: "Домів",
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
      case (TIMING_STATUS_LANCH):
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

class TimingHistory extends StatefulWidget {
  @override
  _TimingHistoryState createState() => _TimingHistoryState();
}

class _TimingHistoryState extends State<TimingHistory> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection("chanel").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
//            itemCount: snapshot.data.documnets.length,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              var documnet = snapshot.data.documents[index];
              return ListTile(
                title: Text(documnet.data['title']),
                isThreeLine: true,
                leading: CircleAvatar(
                  child: Text('1C'),
                ),
                subtitle: Text(
                  documnet.data['news'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        });
//    Container(
//      color: Colors.yellow,
//      child: Center(
//        child: Text(
//          'Історія',
//          style: TextStyle(fontSize: 50),
//        ),
//      ),
//    );
  }
}
