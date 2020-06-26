import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/cost_item.dart';

class CostItemDAO {
  final dbProvider = DBProvider.db;

  insert(CostItem costItem) async {
    final db = await dbProvider.database;

    var raw = await db.rawInsert(
        'INSERT into cost_items ('
        'mob_id,'
        'id,'
        'acc_id,'
        'name,'
        'is_deleted'
        ')'
        'VALUES (?,?,?,?,?)',
        [
          costItem.mobID,
          costItem.id,
          costItem.accID,
          costItem.name,
          costItem.isDeleted,
        ]);

    return raw;
  }

  Future<CostItem> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("cost_items", where: "id=?", whereArgs: [id]);
    return res.isNotEmpty ? CostItem.fromMap(res.first) : null;
  }

  Future<CostItem> getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.query("cost_items", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? CostItem.fromMap(res.first) : null;
  }

  Future<CostItem> getByAccId(String accID) async {
    final db = await dbProvider.database;
    var res = await db.query("cost_items", where: "acc_id = ? ", whereArgs: [accID]);
    return res.isNotEmpty ? CostItem.fromMap(res.first) : null;
  }

  Future<List<CostItem>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("cost_items", orderBy: "name");

    List<CostItem> toReturn = res.isNotEmpty ? res.map((ci) => CostItem.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<List<CostItem>> getUnDeleted() async {
    final db = await dbProvider.database;
    var res = await db.query("cost_items", where: "is_deleted = 0", orderBy: "name");

    List<CostItem> toReturn = res.isNotEmpty ? res.map((ci) => CostItem.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<bool> update(CostItem costItem) async {
    final db = await dbProvider.database;

    var res = await db.update("cost_items", costItem.toMap(), where: "mob_id = ?", whereArgs: [costItem.mobID]);

    return res.isFinite;
  }
}
