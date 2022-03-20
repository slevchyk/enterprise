import 'package:enterprise/database/core.dart';
import 'package:enterprise/interfaces/pay_office_dao_interface.dart';
import 'package:enterprise/models/pay_office.dart';

class PayOfficeDAO implements PayOfficeInterface{
  final dbProvider = DBProvider.db;

  insert(PayOffice payOffice) async {
    final db = await dbProvider.database;

    var raw = await db.rawInsert(
        'INSERT into pay_offices ('
        'mob_id,'
        'id,'
        'amount,'
        'acc_id,'
        'currency_acc_id,'
        'name,'
        'is_deleted,'
        'is_visible,'
        'is_available,'
        'is_receiver,'
        'updated_at'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?)',
        [
          payOffice.mobID,
          payOffice.id,
          payOffice.amount,
          payOffice.accID,
          payOffice.currencyAccID,
          payOffice.name,
          payOffice.isDeleted,
          payOffice.isVisible,
          payOffice.isAvailable,
          payOffice.isReceiver,
          payOffice.updatedAt != null ? payOffice.updatedAt.toIso8601String() : null,
        ]);

    return raw;
  }

  Future<PayOffice> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices", where: "id=?", whereArgs: [id]);
    return res.isNotEmpty ? PayOffice.fromMap(res.first) : null;
  }

  Future<PayOffice> getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? PayOffice.fromMap(res.first) : null;
  }

  Future<PayOffice> getByAccId(String accID) async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices", where: "acc_id = ? ", whereArgs: [accID]);
    return res.isNotEmpty ? PayOffice.fromMap(res.first) : null;
  }

  Future<List<PayOffice>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices", orderBy: "name");

    List<PayOffice> toReturn = res.isNotEmpty ? res.map((ci) => PayOffice.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<List<PayOffice>> getAllExceptId(String name, String accID) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery("SELECT * FROM pay_offices"
        " WHERE name!=? "
        "AND currency_acc_id=? AND is_receiver=1",
      [name, accID]
    );

    List<PayOffice> toReturn = res.isNotEmpty ? res.map((ci) => PayOffice.fromMap(ci)).toList() : [];
    
    return toReturn.reversed.toList();
  }

  Future<List<PayOffice>> getAllToTransfer() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery("SELECT * FROM pay_offices"
        " WHERE is_receiver=1",
    );

    List<PayOffice> toReturn = res.isNotEmpty ? res.map((ci) => PayOffice.fromMap(ci)).toList() : [];
    return toReturn.reversed.toList();

  }

  Future<List<PayOffice>> getUnDeleted() async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices", where: "is_deleted = 0", orderBy: "name");

    List<PayOffice> toReturn = res.isNotEmpty ? res.map((ci) => PayOffice.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<List<PayOffice>> getUnDeletedAndAvailable() async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices", where: "is_deleted = 0 AND is_available = 1", orderBy: "name");

    List<PayOffice> toReturn = res.isNotEmpty ? res.map((ci) => PayOffice.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<List<PayOffice>> getByCurrencyAccID(String currencyAccID) async {
    final db = await dbProvider.database;
    var res = await db.query("pay_offices",
        where: "is_deleted = 0 AND currency_acc_id = ?", whereArgs: [currencyAccID], orderBy: "name");

    List<PayOffice> toReturn = res.isNotEmpty ? res.map((ci) => PayOffice.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<bool> delete(PayOffice payOffice) async {
    final db = await dbProvider.database;
    var res = await db.delete("pay_offices", where: "mob_id = ?", whereArgs: [payOffice.mobID]);

    return res.isFinite;
  }

  Future<bool> update(PayOffice payOffice) async {
    final db = await dbProvider.database;

    var res = await db.update("pay_offices", payOffice.toMap(), where: "mob_id = ?", whereArgs: [payOffice.mobID]);

    return res.isFinite;
  }
}
