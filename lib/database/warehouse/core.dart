import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBWarehouseProvider {
  DBWarehouseProvider._();

  static final DBWarehouseProvider db = DBWarehouseProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "warehouse.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE goods ("
          "mob_id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "id INTEGER,"
          "user_id  TEXT,"
          "good_status BIT,"
          "good_count INTEGET,"
          "good_name TEXT,"
          "good_unit TEXT"
          ")");
      await db.execute("CREATE TABLE newGoods ("
          "mob_id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "id INTEGER,"
          "user_id  TEXT,"
          "good_status BIT,"
          "good_count INTEGET,"
          "good_name TEXT,"
          "good_unit TEXT"
          ")");
      await db.execute('CREATE TABLE documents ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          "id INTEGER,"
          'user_id TEXT,'
          'document_status BIT,'
          'document_number INTEGET,'
          'document_date TEXT,'
          'document_partner TEXT'
          ')');
      await db.execute("CREATE TABLE partners ("
          "mob_id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "id INTEGER,"
          "user_id TEXT,"
          "partner_name TEXT"
          ")");
    });

  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "warehouse.db");
    return await deleteDatabase(path);
  }
}
