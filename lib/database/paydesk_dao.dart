import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/paydesk.dart';

class PayDeskDAO {
  final dbProvider = DBProvider.db;

  insert(PayDesk payDesk, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : payDesk?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : payDesk?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into paydesk ('
        'user_id,'
        'payment_status,'
        'amount,'
        'payment,'
        'document_number,'
        'document_date,'
        'file_paths,'
        'files_quantity,'
        'created_at,'
        'updated_at,'
        'is_deleted,'
        'is_modified'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          payDesk.userID,
          payDesk.paymentStatus,
          payDesk.amount,
          payDesk.payment,
          payDesk.documentNumber,
          payDesk.documentDate != null
              ? payDesk.documentDate.toIso8601String()
              : null,
          payDesk.filePaths,
          payDesk.filesQuantity,
          createdAt,
          updatedAt,
          payDesk.isDeleted,
          isModified,
        ]);

    if (raw.isFinite && payDesk.id == null) {
      PayDesk.sync();
    }

    return raw;
  }

  Future<PayDesk> getByMobID(int mobID) async {
    final db = await dbProvider.database;
    var res =
        await db.query("paydesk", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? PayDesk.fromMap(res.first) : null;
  }

  Future<PayDesk> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("paydesk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? PayDesk.fromMap(res.first) : null;
  }

  Future<bool> update(PayDesk payDesk, {bool isModified = true}) async {
    final db = await dbProvider.database;
    payDesk.isModified = isModified;
    payDesk.updatedAt = DateTime.now();
    var res = await db.update("paydesk", payDesk.toMap(),
        where: "mob_id = ?", whereArgs: [payDesk.mobID]);

    if (res.isFinite && isModified) {
      PayDesk.sync();
    }

    return res.isFinite;
  }

  Future<List<PayDesk>> getUnDeleted() async {
    final db = await dbProvider.database;
    var res =
        await db.query("paydesk", where: 'is_deleted=0', orderBy: "id DESC");

    List<PayDesk> list =
        res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getDeleted() async {
    final db = await dbProvider.database;
    var res =
        await db.query("paydesk", where: 'is_deleted=1', orderBy: "id DESC");

    List<PayDesk> list =
        res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getToUpload() async {
    final db = await dbProvider.database;
    var res = await db.query("paydesk", where: "is_modified = 1");

    List<PayDesk> list =
        res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<void> deleteAll() async {
    final db = await dbProvider.database;
    db.delete("paydesk");
  }
}
