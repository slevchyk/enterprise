import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/expense.dart';

class ExpenseDAO {
  final dbProvider = DBProvider.db;

  insert(Expense expense, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : expense?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : expense?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into expense ('
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
          expense.mobID,
          expense.id,
          expense.uid,
          expense.name,
          createdAt,
          updatedAt,
          isModified,
        ]);

    if (raw.isFinite && expense.id == null) {
      Expense.sync();
    }

    return raw;
  }

  Future<Expense> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("expense", where: "id=?", whereArgs: [id]);
    return res.isNotEmpty ? Expense.fromMap(res.first) : null;
  }

  Future<Expense> getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res =
    await db.query("expense", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? Expense.fromMap(res.first) : null;
  }

  Future<List<Expense>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("expense");

    List<Expense> toReturn =
    res.isNotEmpty ? res.map((e) => Expense.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<Expense>> getToUpload() async {
    final db = await dbProvider.database;
    var res = await db.query("expense", where: "is_modified = 1");

    List<Expense> toReturn =
        res.isNotEmpty ? res.map((e) => Expense.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<bool> update(Expense expense, {bool isModified = true}) async {
    final db = await dbProvider.database;
    expense.isModified = isModified;
    expense.updatedAt = DateTime.now();
    var res = await db.update("expense", expense.toMap(),
        where: "mob_id = ?", whereArgs: [expense.mobID]);

    if (res.isFinite && isModified) {
      Expense.sync();
    }

    return res.isFinite;
  }

}