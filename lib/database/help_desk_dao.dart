import 'package:enterprise/models/helpdesk.dart';
import 'core.dart';

class HelpdeskDAO {
  final dbProvider = DBProvider.db;

  insert(Helpdesk helpdesk) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
        'INSERT Into chanel ('
        'id,'
        'user_id,'
        'status,'
        'date,'
        'title,'
        'description,'
        'ansvered_ad,'
        'ansvered_by,'
        'ansver'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?)',
        [
          helpdesk.id,
          helpdesk.userID,
          helpdesk.status,
          helpdesk.date != null ? helpdesk.date.toIso8601String() : null,
          helpdesk.title,
          helpdesk.description,
          helpdesk.ansvered_ad != null
              ? helpdesk.ansvered_ad.toIso8601String()
              : null,
          helpdesk.ansvered_by,
          helpdesk.ansver,
        ]);
    return raw;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? Helpdesk.fromMap(res.first) : null;
  }

  update(Helpdesk helpdesk) async {
    final db = await dbProvider.database;
    var res = await db.update("helpdesk", helpdesk.toMap(),
        where: "id = ?", whereArgs: [helpdesk.id]);
    return res;
  }

  Future<List<Helpdesk>> getByUserIdType(String userID, String status) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk",
        where: "user_id = ? and status = ? ",
        whereArgs: [userID, status],
        orderBy: "date DESC");

    List<Helpdesk> list =
        res.isNotEmpty ? res.map((c) => Helpdesk.fromMap(c)).toList() : [];
    return list;
  }
}
