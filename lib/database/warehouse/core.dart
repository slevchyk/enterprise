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
          "good_count INTEGER,"
          "good_name TEXT,"
          "good_unit TEXT"
          ")");
      await db.execute("CREATE TABLE user_goods ("
          "mob_id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "id INTEGER,"
          "user_id  TEXT,"
          "good_status BIT,"
          "good_count INTEGER,"
          "good_name TEXT,"
          "good_unit TEXT,"
          'created_at TEXT,'
          'updated_at TEXT,'
          'is_modified BIT'
          ")");
      await db.execute('CREATE TABLE documents ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          "id INTEGER,"
          'user_id TEXT,'
          'document_status BIT,'
          'document_number INTEGER,'
          'document_date TEXT,'
          'document_partner TEXT,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'is_modified BIT'
          ')');
      await db.execute('CREATE TABLE supply_documents ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          "id INTEGER,"
          'user_id TEXT,'
          'supply_document_status BIT,'
          'supply_document_number INTEGER,'
          'supply_document_date TEXT,'
          'supply_document_partner TEXT,'
          'supply_document_count INTEGER,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'is_modified BIT'
          ')');
      await db.execute("CREATE TABLE partners ("
          "mob_id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "id INTEGER,"
          "user_id TEXT,"
          "partner_name TEXT"
          ")");
      await db.execute("CREATE TABLE relation_documents_goods ("
          "document_id INTEGER,"
          "goods_id INTEGER,"
          "UNIQUE (document_id, goods_id) ON CONFLICT REPLACE,"
          "FOREIGN KEY (document_id) REFERENCES documents(mob_id),"
          "FOREIGN KEY (goods_id) REFERENCES newGoods(mob_id),"
          "PRIMARY KEY (document_id, goods_id)"
          ")");
      await db.execute("CREATE TABLE relation_supply_documents_goods ("
          "supply_document_id INTEGER,"
          "goods_id INTEGER,"
          "UNIQUE (supply_document_id, goods_id) ON CONFLICT REPLACE,"
          "FOREIGN KEY (supply_document_id) REFERENCES supply_documents(mob_id),"
          "FOREIGN KEY (goods_id) REFERENCES newGoods(mob_id),"
          "PRIMARY KEY (supply_document_id, goods_id)"
          ")");
    });
  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "warehouse.db");
    return await deleteDatabase(path);
  }
}
