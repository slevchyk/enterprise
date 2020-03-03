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
          "mob_id INTEGER PRIMARY KEY,"
          "id INTEGER,"
          "acc_id TEXT,"
          "is_deleted BIT,"
          "name TEXT"
          ")");
    });
  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "warehouse.db");
    return await deleteDatabase(path);
  }
}
