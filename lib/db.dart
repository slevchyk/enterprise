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
          "first_name TEXT,"
          "last_name TEXT,"
          "middle_name TEXT,"
          "phone TEXT,"
          "itn TEXT,"
          "email TEXT,"
          "photo TEXT,"
          "blocked BIT,"
          "passport_series TEXT,"
          "passport_number TEXT,"
          "passport_issued TEXT,"
          "passport_date TEXT,"
          "civil_status TEXT,"
          "children TEXT,"
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
          'user_id TEXT,'
          'date TEXT,'
          'operation TEXT,'
          'start_date TEXT,'
          'end_date TEXT,'
          'change_date TEXT'
          ')');
      await db.execute('CREATE TABLE chanel ('
          'id INTEGER PRIMARY KEY,'
          'user_id TEXT,'
          'title TEXT,'
          'news TEXT,'
          'date TEXT'
          ')');
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
        'first_name,'
        'last_name,'
        'middle_name,'
        'phone,'
        'itn,'
        'email,'
        'photo,'
        'blocked,'
        'passport_series,'
        'passport_number,'
        'passport_issued,'
        'passport_date,'
        'civil_status,'
        'children,'
        'education,'
        'specialty,'
        'additional_education,'
        'last_work_place,'
        'skills,'
        'languages,'
        'disability,'
        'pensioner'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          id,
          newProfile.firstName,
          newProfile.lastName,
          newProfile.middleName,
          newProfile.phone,
          newProfile.itn,
          newProfile.email,
          newProfile.photo,
          newProfile.blocked,
          newProfile.passport.series,
          newProfile.passport.number,
          newProfile.passport.issued,
          newProfile.passport.date,
          newProfile.civilStatus,
          newProfile.children,
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
    Profile blocked = getProfile(profile.itn);
    blocked.blocked = true;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  unblockProfile(Profile profile) async {
    final db = await database;
    Profile blocked = getProfile(profile.itn);
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

  getProfile(String id) async {
    final db = await database;
    var res = await db.query("Profile", where: "itn = ?", whereArgs: [id]);
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
        'start_date,'
        'end_date,'
        'change_date'
        ')'
        'VALUES (?,?,?,?,?,?,?)',
        [
          id,
          timing.userID,
          timing.date.toIso8601String(),
          timing.operation,
          timing.startDate.toIso8601String(),
          "",
          DateTime.now().toIso8601String(),
        ]);
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
        where: "user_id=? and date=? and operation<>? and end_date=?",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY, ""]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<String> getTimingCurrentByUser(String userID) async {
    final db = await database;
    var res = await db.query(
      "timing",
      where: "user_id=? and end_date = ?",
      whereArgs: [userID, ""],
      orderBy: "start_date DESC",
      limit: 1,
    );

    Timing _timing = res.isNotEmpty ? Timing.fromMap(res.first) : null;
    return _timing != null ? _timing.operation : "";
  }

  Future<List<Timing>> getTimingOpenWorkday(
      DateTime date, String userID) async {
    final db = await database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation=? and end_date=?",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY, ""]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getTimingOpenPastOperation(DateTime date) async {
    final db = await database;
    var res = await db.query("timing",
        where: "date <> ? and end_date = ?",
        whereArgs: [date.toIso8601String(), ""]);

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
    var res = await db.update("timing", timing.toMap(),
        where: "id = ?", whereArgs: [timing.id]);
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
        'news'
        ')'
        'VALUES (?,?,?,?,?)',
        [
          chanel.id,
          chanel.userID,
          chanel.title,
          chanel.date,
          chanel.news,
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

  Future<List<Chanel>> getUserChanel(String userID) async {
    final db = await database;
    var res =
        await db.query("chanel", where: "user_id = ?", whereArgs: [userID]);

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
