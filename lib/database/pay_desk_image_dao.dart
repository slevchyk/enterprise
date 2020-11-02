import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/paydesk_image.dart';

class PayDeskImageDAO {
  final dbProvider = DBProvider.db;

  insert(PayDeskImage payDeskImage) async {
    final db = await dbProvider.database;

    var raw = await db.rawInsert(""
        "INSERT INTO pay_desk_image ("
        "mob_id,"
        "pid,"
        "path,"
        "is_deleted"
        ")"
        "VALUES (?,?,?,?) "
        "ON CONFLICT(path) DO UPDATE SET is_deleted = ?",
        [
          payDeskImage.mobID,
          payDeskImage.pid,
          payDeskImage.path,
          payDeskImage.isDeleted,
          payDeskImage.isDeleted,
        ]);

    return raw;
  }

  Future<List<PayDeskImage>> getByPid(int pid) async {
    final db = await dbProvider.database;

    var res = await db.query("pay_desk_image", where: "pid = ?", whereArgs: [pid]);

    List<PayDeskImage> toReturn = res.isNotEmpty ? res.map((ci) => PayDeskImage.fromMap(ci)).toList() : [];

    return toReturn;
  }

  Future<List<PayDeskImage>> getByMobID(int mobId) async {
    final db = await dbProvider.database;

    var res = await db.query("pay_desk_image", where: "mob_id = ?", whereArgs: [mobId]);

    List<PayDeskImage> toReturn = res.isNotEmpty ? res.map((ci) => PayDeskImage.fromMap(ci)).toList() : [];

    return toReturn;
  }

  Future<List<PayDeskImage>> getUnDeletedByMobID(int mobId) async {
    final db = await dbProvider.database;

    var res = await db.query("pay_desk_image", where: "mob_id = ? AND is_deleted = 0", whereArgs: [mobId]);

    List<PayDeskImage> toReturn = res.isNotEmpty ? res.map((ci) => PayDeskImage.fromMap(ci)).toList() : [];

    return toReturn;
  }

  Future<PayDeskImage> getByPath(String path) async {
    final db = await dbProvider.database;

    var res = await db.query("pay_desk_image", where: "path = ?", whereArgs: [path]);

    return res.isNotEmpty ? PayDeskImage.fromMap(res.first) : null;
  }

  Future<bool> update(PayDeskImage payDeskImage) async {
    final db = await dbProvider.database;

    var res = await db.update("pay_desk_image", payDeskImage.toMapUpdate(), where: "mob_id = ?", whereArgs: [payDeskImage.mobID]);

    return res.isFinite;
  }

  Future setPidByMobID(int pid, int mobID) async {
    final db = await dbProvider.database;

    var raw = await db.rawQuery("UPDATE pay_desk_image SET pid = ? WHERE mob_id = ?", [pid, mobID]);

    return raw;
  }

  Future setDeleteByPath(String path) async {
    final db = await dbProvider.database;

    var raw = await db.rawUpdate("UPDATE pay_desk_image SET is_deleted = 1 WHERE path = ?", [path]);

    return raw;
  }


  Future<bool> delete(int pid) async {
    final db = await dbProvider.database;

    var res = await db.rawDelete("DELETE FROM pay_desk_image WHERE pid = ?",[pid]);

    return res.isFinite;
  }
}