import 'dart:async';
import 'dart:io';

import 'package:enterprise/models.dart';
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
          "blocked BIT"
          ")");
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
        "INSERT Into Profile (id, first_name, last_name, middle_name, phone, itn, email, photo, blocked)"
        " VALUES (?,?,?,?,?,?,?,?,?)",
        [
          id,
          newProfile.firstName,
          newProfile.lastName,
          newProfile.middleName,
          newProfile.phone,
          newProfile.itn,
          newProfile.email,
          newProfile.photo,
          newProfile.blocked
        ]);
    return raw;
  }

  block(Profile profile) async {
    final db = await database;
    Profile blocked = getProfile(profile.itn);
    blocked.blocked = true;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  unblock(Profile profile) async {
    final db = await database;
    Profile blocked = getProfile(profile.itn);
    blocked.blocked = false;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  updateProfile(Profile newProfile) async {
    final db = await database;
    var res = await db.update("Profile", newProfile.toMap(),
        where: "id = ?", whereArgs: [newProfile.id]);
    return res;
  }

  getProfile(String id) async {
    final db = await database;
    var res = await db.query("Profile", where: "itn = ?", whereArgs: [id]);
    return res.isNotEmpty ? Profile.fromMap(res.first) : null;
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
    return db.delete("Profile", where: "id = ?", whereArgs: [id]);
  }

  deleteProfileAll() async {
    final db = await database;
    db.rawDelete("Delete * from Profile");
  }
}
