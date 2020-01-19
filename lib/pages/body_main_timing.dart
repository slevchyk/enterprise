import 'package:enterprise/contatns.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueGrey,
        child: Center(
          child: Text(
            'Сьогодні',
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
      floatingActionButton: TimingFAB(currentTimeStatus, (String value) {
        if (currentTimeStatus != value) {
          setState(() {
            currentTimeStatus = value;
          });
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
            widget.onPressed(TIMING_STATUS_START);
          },
          child: Icon(Icons.work),
        );
      case (TIMING_STATUS_START):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              label: "Робота",
              child: Icon(Icons.add),
              onTap: () {
                widget.onPressed(TIMING_STATUS_WORK);
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
                widget.onPressed(TIMING_STATUS_WORK);
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
      case (TIMING_STATUS_WORK):
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
                widget.onPressed(TIMING_STATUS_WORK);
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
                widget.onPressed(TIMING_STATUS_WORK);
              },
            ),
            SpeedDialChild(
              label: "Домів",
              child: Icon(Icons.home),
              onTap: () {
                widget.onPressed('');
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
