import 'package:date_format/date_format.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/timing.dart';
import 'package:flutter/material.dart';

class PageTimingDB extends StatefulWidget {
  @override
  _PageTimingDBState createState() => _PageTimingDBState();
}

class _PageTimingDBState extends State<PageTimingDB> {
  Future<List<Timing>> listTiming;

  @override
  void initState() {
    listTiming = _getTiming();
  }

  Future<List<Timing>> _getTiming() async {
    return await TimingDAO().getAll();
  }

  Widget dataTable(_listTiming) {
    List<DataRow> dataRows = [];

    for (var timing in _listTiming) {
      dataRows.add(DataRow(cells: <DataCell>[
        DataCell(
          Text(timing.date.toIso8601String()),
        ),
        DataCell(
          Text(timing.userID),
        ),
        DataCell(
          Text(timing.operation),
        ),
        DataCell(
          Text(timing.startedAt != null
              ? formatDate(timing.startedAt, [hh, ':', nn, ':', ss])
              : ""),
        ),
        DataCell(
          Text(timing.endedAt != null
              ? formatDate(timing.endedAt, [hh, ':', nn, ':', ss])
              : ""),
        ),
      ]));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('date'),
          ),
          DataColumn(
            label: Text('user_id'),
          ),
          DataColumn(
            label: Text('operation'),
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FutureBuilder(
              future: listTiming,
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
      ),
    );
  }
}
