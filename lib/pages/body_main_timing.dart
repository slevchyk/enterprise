import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';

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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {},
      ),
    );
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
