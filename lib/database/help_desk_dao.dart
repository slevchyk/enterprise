import 'package:enterprise/models/helpdesk.dart';
import 'core.dart';

class HelpdeskDAO {
  final dbProvider = DBProvider.db;

  insert(Helpdesk helpdesk, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : helpdesk?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : helpdesk?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into helpdesk ('
        'user_id,'
        'date,'
        'title,'
        'description,'
        'status,'
        'answered_at,'
        'answered_by,'
        'answer,'
        'file_paths,'
        'files_quantity,'
        'created_at,'
        'updated_at,'
        'is_deleted,'
        'is_modified'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          helpdesk.userID,
          helpdesk.date != null ? helpdesk.date.toIso8601String() : null,
          helpdesk.title,
          helpdesk.description,
          helpdesk.status,
          helpdesk.answeredAt != null
              ? helpdesk.answeredAt.toIso8601String()
              : null,
          helpdesk.answeredBy,
          helpdesk.answer,
          helpdesk.filePaths,
          helpdesk.filesQuantity,
          createdAt,
          updatedAt,
          helpdesk.isDeleted,
          isModified,
        ]);

    if (raw.isFinite && helpdesk.id == null) {
      Helpdesk.sync();
    }

    return raw;
  }

  Future<Helpdesk> getByMobID(int mobID) async {
    final db = await dbProvider.database;
    var res =
        await db.query("helpdesk", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? Helpdesk.fromMap(res.first) : null;
  }

  Future<Helpdesk> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? Helpdesk.fromMap(res.first) : null;
  }

  Future<bool> update(Helpdesk helpdesk,
      {bool isModified = true, sync = true}) async {
    final db = await dbProvider.database;

    if (!isModified) {
      sync = false;
    }

    helpdesk.isModified = isModified;
    helpdesk.updatedAt = DateTime.now();
    var res = await db.update("helpdesk", helpdesk.toMap(),
        where: "mob_id = ?", whereArgs: [helpdesk.mobID]);

    if (res.isFinite && sync) {
      Helpdesk.sync();
    }

    return res.isFinite;
  }

  Future<List<Helpdesk>> getDeleted() async {
    final db = await dbProvider.database;
    var res =
        await db.query("helpdesk", where: 'is_deleted=1', orderBy: "id DESC");

    List<Helpdesk> list =
        res.isNotEmpty ? res.map((c) => Helpdesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Helpdesk>> getToUpload() async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "is_modified = 1");

    List<Helpdesk> list =
        res.isNotEmpty ? res.map((c) => Helpdesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<void> deleteAll() async {
    final db = await dbProvider.database;
    db.delete("helpdesk");
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? Helpdesk.fromMap(res.first) : null;
  }

  Future<List<Helpdesk>> getByUserIdType(String userID, String status) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk",
        where: "user_id = ? and status = ? and is_deleted = 0 ",
        whereArgs: [userID, status],
        orderBy: "date DESC");

    List<Helpdesk> list =
        res.isNotEmpty ? res.map((c) => Helpdesk.fromMap(c)).toList() : [];
    return list;
  }
}
