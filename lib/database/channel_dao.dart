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
        'star,'
        'archive,'
        'delete_at'
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
        "chanel", {"star": DateTime.now().toIso8601String()},
        where: "id = ? ", whereArgs: [id]);
    return res;
  }

  unstarById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update("chanel", {"star": null},
        where: "id = ? ", whereArgs: [id]);
    return res;
  }

  archiveById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update(
        "chanel", {"archive": DateTime.now().toIso8601String()},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  unarchiveById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update("chanel", {"archive": null},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  deleteById(int id) async {
    final db = await dbProvider.database;
    var res = await db.update(
        "chanel", {"delete_at": DateTime.now().toIso8601String()},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  Future<List<Channel>> getByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and delete_at is null and archive is null",
        whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Channel>> getStarredByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and star is not null", whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Channel>> getDeletedByUSerId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and delete_at is not null", whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Channel>> getArchivedByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("chanel",
        where: "user_id = ? and archive is not null and delete_at is null",
        whereArgs: [userID]);

    List<Channel> list =
        res.isNotEmpty ? res.map((c) => Channel.fromMap(c)).toList() : [];
    return list;
  }
}
