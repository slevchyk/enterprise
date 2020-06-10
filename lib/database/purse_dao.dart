import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/purse.dart';

class PurseDAO {
  final dbProvider = DBProvider.db;

  insert(Purse purse, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : purse?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : purse?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into purse ('
            'mob_id,'
            'id,'
            'user_id,'
            'name,'
            'created_at,'
            'updated_at,'
            'is_modified'
            ')'
            'VALUES (?,?,?,?,?,?,?)',
    [
      purse.mobID,
      purse.id,
      purse.uid,
      purse.name,
      createdAt,
      updatedAt,
      isModified,
    ]);

    if (raw.isFinite && purse.id == null) {
      Purse.sync();
    }

    return raw.isFinite;
  }

  Future<Purse> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("expense", where: "id=?", whereArgs: [id]);
    return res.isNotEmpty ? Purse.fromMap(res.first) : null;
  }

  Future<Purse> getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res =
        await db.query("purse", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? Purse.fromMap(res.first) : null;
  }

  Future<List<Purse>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("purse");

    List<Purse> toReturn =
      res.isNotEmpty ? res.map((e) => Purse.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<Purse>> getToUpload() async {
    final db = await dbProvider.database;
    var res = await db.query("purse", where: "is_modified = 1");

    List<Purse> toReturn =
    res.isNotEmpty ? res.map((e) => Purse.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<bool> update(Purse purse, {bool isModified = true}) async {
    final db = await dbProvider.database;
    purse.isModified = isModified;
    purse.updatedAt = DateTime.now();
    var res = await db.update("purse", purse.toMap(),
        where: "mob_id = ?", whereArgs: [purse.mobID]);

    if (res.isFinite && isModified) {
      Purse.sync();
    }

    return res.isFinite;
  }

}