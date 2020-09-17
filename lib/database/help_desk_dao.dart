import 'package:enterprise/models/helpdesk.dart';
import 'core.dart';

class HelpdeskDAO {
  final dbProvider = DBProvider.db;

  insert(HelpDesk helpdesk, {bool isModified = true}) async {
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
        'body,'
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
          helpdesk.body,
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
      HelpDesk.sync();
    }

    return raw;
  }

  Future<HelpDesk> getByMobID(int mobID) async {
    final db = await dbProvider.database;
    var res =
        await db.query("helpdesk", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? HelpDesk.fromMap(res.first) : null;
  }

  Future<HelpDesk> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? HelpDesk.fromMap(res.first) : null;
  }

  Future<bool> update(HelpDesk helpdesk,
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
      HelpDesk.sync();
    }

    return res.isFinite;
  }

  Future<List<HelpDesk>> getDeleted() async {
    final db = await dbProvider.database;
    var res =
        await db.query("helpdesk", where: 'is_deleted=1', orderBy: "id DESC");

    List<HelpDesk> list =
        res.isNotEmpty ? res.map((c) => HelpDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<HelpDesk>> getToUpload() async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "is_modified = 1");

    List<HelpDesk> list =
        res.isNotEmpty ? res.map((c) => HelpDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<void> deleteAll() async {
    final db = await dbProvider.database;
    db.delete("helpdesk");
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? HelpDesk.fromMap(res.first) : null;
  }

  Future<List<HelpDesk>> getByUserIdType(String userID, String status) async {
    final db = await dbProvider.database;
    var res = await db.query("helpdesk",
        where: "user_id = ? and status = ? and is_deleted = 0 ",
        whereArgs: [userID, status],
        orderBy: "mob_id DESC");

    List<HelpDesk> list =
        res.isNotEmpty ? res.map((c) => HelpDesk.fromMap(c)).toList() : [];
    return list;
  }
}
