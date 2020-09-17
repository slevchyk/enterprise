import 'dart:async';
import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Profile ("
          "id INTEGER PRIMARY KEY,"
          "blocked BIT,"
          "user_id TEXT,"
          "pin TEXT,"
          "info_card INTEGER,"
          "first_name TEXT,"
          "last_name TEXT,"
          "middle_name TEXT,"
          "phone TEXT,"
          "birthday TEXT,"
          "itn TEXT,"
          "email TEXT,"
          "gender TEXT,"
          "passport_type TEXT,"
          "passport_series TEXT,"
          "passport_number TEXT,"
          "passport_issued TEXT,"
          "passport_date TEXT,"
          "passport_expiry TEXT,"
          "civil_status TEXT,"
          "children TEXT,"
          "job_position INTEGER,"
          "education INTEGER,"
          "specialty TEXT,"
          "additional_education TEXT,"
          "last_work_place TEXT,"
          "skills TEXT,"
          "languages TEXT,"
          "disability BIT,"
          "pensioner BIT,"
          "photo_name TEXT"
          ")");

      await db.execute('CREATE TABLE timing ('
          'mob_id INTEGER PRIMARY KEY,'
          'id INTEGER,'
          'acc_id TEXT,'
          'user_id TEXT,'
          'date TEXT,'
          'is_turnstile BIT,'
          'status TEXT,'
          'started_at TEXT,'
          'ended_at TEXT,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'deleted_at TEXT,'
          'is_modified BIT'
          ')');

      await db.execute('CREATE TABLE timing_log ('
          'mob_id INTEGER,'
          'old_id TEXT,'
          'new_id TEXT,'
          'old_acc_id TEXT,'
          'new_acc_id TEXT,'
          'old_user_id TEXT,'
          'new_user_id TEXT,'
          'old_date TEXT,'
          'new_date TEXT,'
          'old_status TEXT,'
          'new_status TEXT,'
          'old_start TEXT,'
          'new_start TEXT,'
          'old_end TEXT,'
          'new_end TEXT'
          ')');

      await db.execute('CREATE TABLE chanel ('
          'id INTEGER PRIMARY KEY,'
          'user_id TEXT,'
          'type TEXT,'
          'date TEXT,'
          'title TEXT,'
          'news TEXT,'
          'starred_at TEXT,'
          'archived_at TEXT,'
          'deleted_at TEXT'
          ')');
      await db.execute('CREATE TABLE helpdesk ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'id INTEGER,'
          'user_id TEXT,'
          'date TEXT,'
          'title TEXT,'
          'body TEXT,'
          'status TEXT,'
          'answered_at TEXT,'
          'answered_by TEXT,'
          'answer TEXT,'
          'file_paths TEXT,'
          'files_quantity,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'is_deleted BIT DEFAULT 0,'
          'is_modified BIT'
          ')');
      await db.execute('CREATE TABLE pay_desk ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'id INTEGER,'
          'pay_desk_type INTEGER,'
          'currency_acc_id TEXT,'
          'cost_item_acc_id TEXT,'
          'income_item_acc_id TEXT,'
          'from_pay_office_acc_id TEXT,'
          'to_pay_office_acc_id TEXT,'
          'user_id TEXT,'
          'amount DOUBLE,'
          'payment TEXT,'
          'document_number TEXT,'
          'document_date TEXT,'
          'is_checked BIT,'
          'file_paths TEXT,'
          'files_quantity,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'is_deleted BIT DEFAULT 0,'
          'is_modified BIT'
          ')');
      await db.execute('CREATE TABLE cost_items ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'id INTEGER,'
          'acc_id TEXT,'
          'name TEXT,'
          'is_deleted BIT'
          ')');
      await db.execute('CREATE TABLE income_items ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'id INTEGER,'
          'acc_id TEXT,'
          'name TEXT,'
          'is_deleted BIT'
          ')');
      await db.execute('CREATE TABLE pay_offices ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'id INTEGER,'
          'acc_id TEXT,'
          'amount INTEGER,'
          'currency_acc_id TEXT,'
          'name TEXT,'
          'is_deleted BIT,'
          'is_visible BIT,'
          'is_available BIT,'
          'is_receiver BIT,'
          'updated_at TEXT'
          ')');
      await db.execute('CREATE TABLE currency ('
          'mob_id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'id INTEGER,'
          'acc_id TEXT,'
          'code INTEGER,'
          'name TEXT,'
          'is_deleted BIT'
          ')');
      await db.execute('CREATE TABLE user_grants ('
          'user_id TEXT,'
          'odject_type INT,'
          'odject_acc_id TEXT,'
          'is_visible BIT,'
          'is_available BIT,'
          'is_receiver BIT'
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
      FLog.info(
        text: "initDB complete",
      );
    });
  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    FLog.info(
      text: "db deleted",
    );
    return await deleteDatabase(path);
  }
}
