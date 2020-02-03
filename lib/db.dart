import 'dart:async';
import 'dart:io';

import 'package:enterprise/contatns.dart';
import 'package:enterprise/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Profile ("
          "id INTEGER PRIMARY KEY,"
          "uuid TEXT,"
          "first_name TEXT,"
          "last_name TEXT,"
          "middle_name TEXT,"
          "phone TEXT,"
          "itn TEXT,"
          "email TEXT,"
          "photo TEXT,"
          "sex TEXT,"
          "blocked BIT,"
          "passport_type TEXT,"
          "passport_series TEXT,"
          "passport_number TEXT,"
          "passport_issued TEXT,"
          "passport_date TEXT,"
          "passport_expiry TEXT,"
          "civil_status TEXT,"
          "children TEXT,"
          "position INTEGER,"
          "education INTEGER,"
          "specialty TEXT,"
          "additional_education TEXT,"
          "last_work_place TEXT,"
          "skills TEXT,"
          "languages TEXT,"
          "disability BIT,"
          "pensioner BIT"
          ")");
      await db.execute('CREATE TABLE timing ('
          'id INTEGER PRIMARY KEY,'
          'ext_id TEXT,'
          'user_id TEXT,'
          'date TEXT,'
          'operation TEXT,'
          'started_at TEXT,'
          'ended_at TEXT,'
          'to_upload BIT,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'deleted_at TEXT'
          ')');
      await db.execute('CREATE TABLE timing_log ('
          'id INTEGER,'
          'old_ext_id TEXT,'
          'new_ext_id TEXT,'
          'old_user_id TEXT,'
          'new_user_id TEXT,'
          'old_date TEXT,'
          'new_date TEXT,'
          'old_operation TEXT,'
          'new_operation TEXT,'
          'old_start TEXT,'
          'new_start TEXT,'
          'old_end TEXT,'
          'new_end TEXT'
          ')');
      await db.execute('CREATE TABLE chanel ('
          'id INTEGER PRIMARY KEY,'
          'user_id TEXT,'
          'title TEXT,'
          'news TEXT,'
          'date TEXT,'
          'star TEXT,'
          'archive TEXT,'
          'delete TEXT'
          ')');
//      await db.execute('CREATE TRIGGER log_timing_after_update'
//          'AFTER UPDATE ON timing'
//          'WHEN old.ext_id <> new.ext_id'
//          'OR old.user_id <> new.user_id'
//          'OR old.date <> new.date'
//          'OR old.operation <> new.operation'
//          'OR old.start <> new.start'
//          'OR old.end <> new.end'
//          'BEGIN'
//          'INSERT INTO lead_logs ('
//          'id,'
//          'old_ext_id,'
//          'new_ext_id,'
//          'old_date,'
//          'new_date,'
//          'old_operation,'
//          'new_operation,'
//          'old_start,'
//          'new_start,'
//          'old_end,'
//          'old_end,'
//          'user_action,'
//          'created_at'
//          ')'
//          'VALUES('
//          'old.id,'
//          'old.phone,'
//          'new.phone,'
//          'old.email,'
//          'new.email,'
//          '\'UPDATE\','
//          'DATETIME(\'NOW\')'
//          ');'
//          'END;');
    });
  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    return await deleteDatabase(path);
  }

  newProfile(Profile newProfile) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Profile");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        'INSERT Into Profile ('
        'id, '
        'uuid, '
        'first_name,'
        'last_name,'
        'middle_name,'
        'phone,'
        'itn,'
        'email,'
        'photo,'
        'sex,'
        'blocked,'
        'passport_type,'
        'passport_series,'
        'passport_number,'
        'passport_issued,'
        'passport_date,'
        'passport_expiry,'
        'civil_status,'
        'children,'
        'position,'
        'education,'
        'specialty,'
        'additional_education,'
        'last_work_place,'
        'skills,'
        'languages,'
        'disability,'
        'pensioner'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          id,
          newProfile.uuid,
          newProfile.firstName,
          newProfile.lastName,
          newProfile.middleName,
          newProfile.phone,
          newProfile.itn,
          newProfile.email,
          newProfile.photo,
          newProfile.sex,
          newProfile.blocked,
          newProfile.passportType,
          newProfile.passportSeries,
          newProfile.passportNumber,
          newProfile.passportIssued,
          newProfile.passportDate,
          newProfile.passportExpiry,
          newProfile.civilStatus,
          newProfile.children,
          newProfile.position,
          newProfile.education,
          newProfile.specialty,
          newProfile.additionalEducation,
          newProfile.lastWorkPlace,
          newProfile.skills,
          newProfile.languages,
          newProfile.disability,
          newProfile.pensioner
        ]);
    return raw;
  }

  blockProfile(Profile profile) async {
    final db = await database;
    Profile blocked = getProfile(profile.uuid);
    blocked.blocked = true;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  unblockProfile(Profile profile) async {
    final db = await database;
    Profile blocked = getProfile(profile.uuid);
    blocked.blocked = false;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  updateProfile(Profile newProfile) async {
    final db = await database;
    var res = await db.update("Profile", newProfile.toDB(),
        where: "id = ?", whereArgs: [newProfile.id]);
    return res;
  }

  getProfile(String uuid) async {
    final db = await database;
    var res = await db.query("profile", where: "uuid = ?", whereArgs: [uuid]);
    return res.isNotEmpty ? Profile.fromDB(res.first) : null;
  }

  Future<List<Profile>> getBlockedProfiles() async {
    final db = await database;

    print("works");
    var res = await db.query("Profile", where: "blocked = ? ", whereArgs: [1]);

    List<Profile> list =
        res.isNotEmpty ? res.map((c) => Profile.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Profile>> getAllProfiles() async {
    final db = await database;
    var res = await db.query("Profile");
    List<Profile> list =
        res.isNotEmpty ? res.map((c) => Profile.fromMap(c)).toList() : [];
    return list;
  }

  deleteProfile(int id) async {
    final db = await database;
    return db.delete("profile", where: "id = ?", whereArgs: [id]);
  }

  deleteAllProfiles() async {
    final db = await database;
    db.delete("profile");
  }

  newTiming(Timing timing) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM timing");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        'INSERT Into timing ('
        'id,'
        'user_id,'
        'date,'
        'operation,'
        'started_at,'
        'to_upload,'
        'created_at'
        ')'
        'VALUES (?,?,?,?,?,?,?)',
        [
          id,
          timing.userID,
          timing.date.toIso8601String(),
          timing.operation,
          timing.startedAt.toIso8601String(),
          1,
          DateTime.now().toIso8601String(),
        ]);
    timing.id = raw;
    return raw;
  }

  getTiming(int id) async {
    final db = await database;
    var res = await db.query("timing", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Timing.fromMap(res.first) : null;
  }

  Future<List<Timing>> getUserTiming(DateTime date, String userID) async {
    final db = await database;
    var res = await db.query(
      "timing",
      where: "date=? and user_id=?",
      whereArgs: [date.toIso8601String(), userID],
    );

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getTimingOpenOperation(
      DateTime date, String userID) async {
    final db = await database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation<>? and ended_at is null",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getTimingToUpload(String userID) async {
    final db = await database;
    var res = await db.query("timing",
        where: "user_id = ? and to_upload=?", whereArgs: [userID, 1]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<String> getTimingCurrentByUser(String userID) async {
    final db = await database;
    var res = await db.query(
      "timing",
      where: "user_id=? and ended_at is null",
      whereArgs: [userID],
      orderBy: "started_at DESC",
      limit: 1,
    );

    Timing _timing = res.isNotEmpty ? Timing.fromMap(res.first) : null;
    return _timing != null ? _timing.operation : "";
  }

  Future<List<Timing>> getTimingOpenWorkday(
      DateTime date, String userID) async {
    final db = await database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation=? and ended_at is null",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getTimingOpenPastOperation(DateTime date) async {
    final db = await database;
    var res = await db.query("timing",
        where: "date <> ? and ended_at is null",
        whereArgs: [date.toIso8601String()]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getTimingPeriod(
      List<DateTime> date, String userID) async {
    final db = await database;

    List<String> conditionValues = [];
    for (var _date in date) {
      conditionValues.add(_date.toIso8601String());
    }

    String dateCondition = '';
    for (int i = 0; i < conditionValues.length; i++) {
      dateCondition += dateCondition.isEmpty ? '' : ', ';
      dateCondition += '?';
    }

    conditionValues.add(userID);

    var res = await db.query("timing",
        where: "date in ($dateCondition) and user_id = ?",
        whereArgs: conditionValues,
        orderBy: 'date ASC, operation ASC');

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  updateTiming(Timing timing) async {
    final db = await database;
    timing.toUpload = true;
    timing.updatedAt = DateTime.now();
    var res = await db.update("timing", timing.toMap(),
        where: "id = ?", whereArgs: [timing.id]);
    return res;
  }

  updateTimingProcessed(int id, int extID) async {
    final db = await database;
    var res = await db.update("timing", {'to_update': 0, 'ext_id': extID},
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  deleteAllTiming() async {
    final db = await database;
    Future<int> raw = db.rawDelete("Delete * from timing");
    return raw;
  }

  newChanel(Chanel chanel) async {
    final db = await database;
    var raw = await db.rawInsert(
        'INSERT Into chanel ('
        'id,'
        'user_id,'
        'title,'
        'date,'
        'news,'
        'star,'
        'archive,'
        'delete'
        ')'
        'VALUES (?,?,?,?,?)',
        [
          chanel.id,
          chanel.userID,
          chanel.title,
          chanel.date,
          chanel.news,
          chanel.star.toIso8601String(),
          chanel.archive.toIso8601String(),
          chanel.delete.toIso8601String(),
        ]);
    return raw;
  }

  getChanel(int id) async {
    final db = await database;
    var res = await db.query("chanel", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Chanel.fromMap(res.first) : null;
  }

  updateChanel(Chanel chanel) async {
    final db = await database;
    var res = await db.update("chanel", chanel.toMap(),
        where: "id = ?", whereArgs: [chanel.id]);
    return res;
  }

  updateStar(int id) async {
    final db = await database;
    var res = await db.update(
        "chanel", {"star": DateTime.now().toIso8601String()},
        where: "id = ? ", whereArgs: [id]);
    return res;
  }

  updateArchive(Chanel chanel) async {
    final db = await database;
    var res = await db.update(
        "chanel", {"archive": DateTime.now().toIso8601String()},
        where: "id = ?", whereArgs: [chanel.id]);
    return res;
  }

  updateDelete(Chanel chanel) async {
    final db = await database;
    var res = await db.update(
        "chanel", {"delete": DateTime.now().toIso8601String()},
        where: "id = ?", whereArgs: [chanel.id]);
    return res;
  }

  Future<List<Chanel>> getUserChanel(String userID) async {
    final db = await database;
    var res = await db.query("chanel",
        where: "user_id = ? and delete is null and archive is null",
        whereArgs: [userID]);

    List<Chanel> list =
        res.isNotEmpty ? res.map((c) => Chanel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Chanel>> getStarted(String userID) async {
    final db = await database;
    var res = await db.query("chanel",
        where: "user_id = ? and star is not null", whereArgs: [userID]);

    List<Chanel> list =
        res.isNotEmpty ? res.map((c) => Chanel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Chanel>> getDelete(String userID) async {
    final db = await database;
    var res = await db.query("chanel",
        where: "user_id = ? and delete is not null", whereArgs: [userID]);

    List<Chanel> list =
        res.isNotEmpty ? res.map((c) => Chanel.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Chanel>> getArchive(String userID) async {
    final db = await database;
    var res = await db.query("chanel",
        where: "user_id = ? and archive is not null and delete is null",
        whereArgs: [userID]);

    List<Chanel> list =
        res.isNotEmpty ? res.map((c) => Chanel.fromMap(c)).toList() : [];
    return list;
  }
}

//class DBProfile {
//  DBProvider db = DBProvider.db;
//
//  DBProfile({
//    this.db,
//  });
//
//  newProfile(Profile newProfile) async {
//    final db = await database;
//    //get the biggest id in the table
//    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Profile");
//    int id = table.first["id"];
//    //insert to the table using the new id
//    var raw = await db.rawInsert(
//        'INSERT Into Profile ('
//        'id, '
//        'first_name,'
//        'last_name,'
//        'middle_name,'
//        'phone,'
//        'itn,'
//        'email,'
//        'photo,'
//        'blocked,'
//        'passport_series,'
//        'passport_number,'
//        'passport_issued,'
//        'passport_date,'
//        'civil_status,'
//        'children,'
//        'education,'
//        'specialty,'
//        'additional_education,'
//        'last_work_place,'
//        'skills,'
//        'languages,'
//        'disability,'
//        'pensioner'
//        ')'
//        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
//        [
//          id,
//          newProfile.firstName,
//          newProfile.lastName,
//          newProfile.middleName,
//          newProfile.phone,
//          newProfile.itn,
//          newProfile.email,
//          newProfile.photo,
//          newProfile.blocked,
//          newProfile.passport.series,
//          newProfile.passport.number,
//          newProfile.passport.issued,
//          newProfile.passport.date,
//          newProfile.civilStatus,
//          newProfile.education,
//          newProfile.specialty,
//          newProfile.additionalEducation,
//          newProfile.lastWorkPlace,
//          newProfile.skills,
//          newProfile.languages,
//          newProfile.languages,
//          newProfile.disability,
//          newProfile.pensioner
//        ]);
//    return raw;
//  }
//}
