import 'package:enterprise/models/timing.dart';

import '../models/contatns.dart';
import 'core.dart';

class TimingDAO {
  final dbProvider = DBProvider.db;

  insert(Timing timing) async {
    final db = await dbProvider.database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM timing");

    if (timing.id == null) {
      timing.id = table.first["id"];
    }

    //insert to the table using the new id
    var raw = await db.rawInsert(
        'INSERT Into timing ('
        'id,'
        'user_id,'
        'date,'
        'operation,'
        'started_at,'
        'created_at'
        ')'
        'VALUES (?,?,?,?,?,?)',
        [
          timing.id,
          timing.userID,
          timing.date.toIso8601String(),
          timing.operation,
          timing.startedAt.toIso8601String(),
          DateTime.now().toIso8601String(),
        ]);
    timing.id = raw;
    return raw;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("timing", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Timing.fromMap(res.first) : null;
  }

  Future<List<Timing>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
    );

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getByDateUserId(DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
      where: "date=? and user_id=?",
      whereArgs: [date.toIso8601String(), userID],
    );

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getOpenOperationByDateUserId(
      DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation<>? and ended_at is null",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getToUploadByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "user_id = ? and ext_id is null", whereArgs: [userID]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<String> getCurrentOperationByUser(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
      where: "user_id=? and ended_at is null and deleted_at is null",
      whereArgs: [userID],
      orderBy: "started_at DESC",
      limit: 1,
    );

    Timing _timing = res.isNotEmpty ? Timing.fromMap(res.first) : null;
    return _timing != null ? _timing.operation : "";
  }

  Future<List<Timing>> getOpenWorkdayByDateUserId(
      DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation=? and ended_at is null",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getOpenPastOperation(DateTime date) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "date <> ? and ended_at is null",
        whereArgs: [date.toIso8601String()]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getPeriodByDatesUserId(
      List<DateTime> date, String userID) async {
    final db = await dbProvider.database;

    List<String> conditionValues = [];
    for (var _date in date) {
      conditionValues.add(_date.toIso8601String());
    }

    String dateCondition = '';
    for (int i = 0; i < conditionValues.length; i++) {
      dateCondition += dateCondition.isEmpty ? '' : ', ';
      dateCondition += '?';
    }

    conditionValues.add(userID);

    var res = await db.query("timing",
        where: "date in ($dateCondition) and user_id = ?",
        whereArgs: conditionValues,
        orderBy: 'date ASC, operation ASC');

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  update(Timing timing) async {
    final db = await dbProvider.database;
    timing.updatedAt = DateTime.now();
    var res = await db.update("timing", timing.toMap(),
        where: "id = ?", whereArgs: [timing.id]);
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    Future<int> raw = db.rawDelete("Delete * from timing");
    return raw;
  }
}
