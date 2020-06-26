import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/income_item.dart';

class IncomeItemDAO {
  final dbProvider = DBProvider.db;

  insert(IncomeItem incomeItem) async {
    final db = await dbProvider.database;

    var raw = await db.rawInsert(
        'INSERT into income_items ('
        'mob_id,'
        'id,'
        'acc_id,'
        'name,'
        'is_deleted'
        ')'
        'VALUES (?,?,?,?,?)',
        [
          incomeItem.mobID,
          incomeItem.id,
          incomeItem.accID,
          incomeItem.name,
          incomeItem.isDeleted,
        ]);

    return raw;
  }

  Future<IncomeItem> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("income_items", where: "id=?", whereArgs: [id]);
    return res.isNotEmpty ? IncomeItem.fromMap(res.first) : null;
  }

  Future<IncomeItem> getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.query("income_items", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? IncomeItem.fromMap(res.first) : null;
  }

  Future<IncomeItem> getByAccId(String accID) async {
    final db = await dbProvider.database;
    var res = await db.query("income_items", where: "acc_id = ? ", whereArgs: [accID]);
    return res.isNotEmpty ? IncomeItem.fromMap(res.first) : null;
  }

  Future<List<IncomeItem>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("income_items", orderBy: "name");

    List<IncomeItem> toReturn = res.isNotEmpty ? res.map((ci) => IncomeItem.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<List<IncomeItem>> getUnDeleted() async {
    final db = await dbProvider.database;
    var res = await db.query("income_items", where: "is_deleted = 0", orderBy: "name");

    List<IncomeItem> toReturn = res.isNotEmpty ? res.map((ci) => IncomeItem.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<bool> update(IncomeItem incomeItem) async {
    final db = await dbProvider.database;

    var res = await db.update("income_items", incomeItem.toMap(), where: "mob_id = ?", whereArgs: [incomeItem.mobID]);

    return res.isFinite;
  }
}
