import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/pay.dart';

class PayDeskDAO {
  final dbProvider = DBProvider.db;

  insert(Pay pay) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
        'INSERT Into paydesk ('
            'user_id,'
            'amount,'
            'payment,'
            'confirming,'
            'date,'
            'files'
            ')'
            'VALUES (?,?,?,?,?,?)',
        [
          pay.userID,
          pay.amount,
          pay.payment,
          pay.confirming,
          pay.date != null
              ? pay.date.toIso8601String()
              : null,
          pay.files,
        ]);
    return raw;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("paydesk", where: "id = ? ",
        whereArgs: [id]);
    return res.isNotEmpty ? Pay.fromMap(res.first) : null;
  }

  getLastId() async {
    final db = await dbProvider.database;
    var res = await db.query("paydesk", where: "last_insert_rowid()");
    return res.isNotEmpty ? Pay.fromMap(res.last) : null;
  }

  getAll() async {
    final db = await dbProvider.database;
    var res =  await db.query("paydesk");
    return res;
  }

  update(Pay pay) async {
    final db = await dbProvider.database;
    var res = await db.update("paydesk", pay.toMap(),
    where: "user_id = ?", whereArgs: [pay.id]);
    return res;
  }

}