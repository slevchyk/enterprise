import 'package:date_format/date_format.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:enterprise/models/timing.dart';
import 'package:flutter/material.dart';

class PageTimingDB extends StatefulWidget {
  @override
  _PageTimingDBState createState() => _PageTimingDBState();
}

class _PageTimingDBState extends State<PageTimingDB> {
  List<Timing> listTiming;

  @override
  void initState() {
//    List<Timing> _listTiming = getTiming();
    setState(() {
      listTiming = getTiming();
    });
  }

  getTiming() async {
    return await TimingDAO().getAll();
  }

  Widget dataTable() {
    List<DataRow> dataRows = [];

    for (var timing in listTiming) {
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
      body: dataTable(),
    );
  }
}
