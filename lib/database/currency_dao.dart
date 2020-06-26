import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/currency.dart';

class CurrencyDAO {
  final dbProvider = DBProvider.db;

  insert(Currency currency) async {
    final db = await dbProvider.database;

    var raw = await db.rawInsert(
        'INSERT into currency ('
        'mob_id,'
        'id,'
        'acc_id,'
        'code,'
        'name,'
        'is_deleted'
        ')'
        'VALUES (?,?,?,?,?,?)',
        [
          currency.mobID,
          currency.id,
          currency.accID,
          currency.code,
          currency.name,
          currency.isDeleted,
        ]);

    return raw;
  }

  Future<Currency> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("currency", where: "id=?", whereArgs: [id]);
    return res.isNotEmpty ? Currency.fromMap(res.first) : null;
  }

  Future<Currency> getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.query("currency", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? Currency.fromMap(res.first) : null;
  }

  Future<Currency> getByAccId(String accID) async {
    final db = await dbProvider.database;
    var res = await db.query("currency", where: "acc_id = ? ", whereArgs: [accID]);
    return res.isNotEmpty ? Currency.fromMap(res.first) : null;
  }

  Future<List<Currency>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("currency", orderBy: "name");

    List<Currency> toReturn = res.isNotEmpty ? res.map((ci) => Currency.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<List<Currency>> getUnDeleted() async {
    final db = await dbProvider.database;
    var res = await db.query("currency", where: "is_deleted = 0", orderBy: "name");

    List<Currency> toReturn = res.isNotEmpty ? res.map((ci) => Currency.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<bool> update(Currency currency) async {
    final db = await dbProvider.database;

    var res = await db.update("currency", currency.toMap(), where: "mob_id = ?", whereArgs: [currency.mobID]);

    return res.isFinite;
  }
}
