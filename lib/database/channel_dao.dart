import 'package:enterprise/models/channel.dart';

import 'core.dart';

class ChannelDAO {
  final dbProvider = DBProvider.db;

  insert(Channel chanel) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
        'INSERT Into chanel ('
        'id,'
        'user_id,'
        'title,'
        'date,'
        'news,'
        'starred_at,'
        'archived_at,'
        'deleted_at'
        ')'
        'VALUES (?,?,?,?,?,?,?,?)',
        [
          chanel.id,
          chanel.userID,
          chanel.title,
          chanel.date != null ? chanel.date.toIso8601String() : null,
          chanel.news,
          chanel.starredAt != null ? chanel.starredAt.toIso8601String() : null,
          chanel.archivedAt != null
              ? chanel.archivedAt.toIso8601String()
              : null,
          chanel.deletedAt != null ? chanel.deletedAt.toIso8601String() : null,
        ]);
    return raw;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Channel.fromMap(res.first) : null;
  }

  update(Channel chanel) async {
    final db = await dbProvider.database;
    var res = await db.update("chanel", chanel.toMap(),
        where: "id = ?", whereArgs: [chanel.id]);
    return res;
  }

  starById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update(
        "chanel", {"starred_at": DateTime.now().toIso8601String()},
        where: "id = ? ", whereArgs: [id]);
    return res;
  }

  unstarById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update("chanel", {"starred_at": null},
        where: "id = ? ", whereArgs: [id]);
    return res;
  }

  archiveById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update(
        "chanel", {"archived_at": DateTime.now().toIso8601String()},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  unarchiveById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update("chanel", {"archived_at": null},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  deleteById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update(
        "chanel", {"deleted_at": DateTime.now().toIso8601String()},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  Future<List<Channel>> getByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and deleted_at is null and archived_at is null",
        whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Channel>> getStarredByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and starred_at is not null", whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Channel>> getDeletedByUSerId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and deleted_at is not null", whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Channel>> getArchivedByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and archived_at is not null and deleted_at is null",
        whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }
}
