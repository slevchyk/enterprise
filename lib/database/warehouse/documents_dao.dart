
import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/documnets.dart';

class DocumentsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(Documents documents) async {
    final db = await dbProvider.database;
    var  raw = await db.rawInsert(
        'INSERT Into documents ('
            'user_id,'
            'document_status,'
            'document_number,'
            'document_date,'
            'document_partner'
            ')'
            'VALUES (?,?,?,?,?)',
    [
     documents.userID,
     documents.status,
     documents.number,
     documents.date.toIso8601String(),
     documents.partner,
    ]);
    return raw.isFinite;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("documents" , where: "mob_id = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? Documents.fromMap(res.first) : null;
  }

  Future<List<Documents>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("documents");

    List<Documents> toReturn =
        res.isNotEmpty ? res.map((e) => Documents.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<Documents>> search(String query) async {
    query = "$query%";
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'select * from documents '
        'where document_partner like ? '
        'OR document_date like ?'
        'OR document_number like ?'
        ,[
          query,
          query,
          query,
        ]);

    List<Documents> toReturn =
    res.isNotEmpty
        ? res.map((e) => Documents.fromMap(e)).toList()
        : [];
    return toReturn;
  }

  update(Documents documents) async {
    final db = await dbProvider.database;
    var res = await db.update("documents", documents.toMap(),
    where: "mob_id = ?", whereArgs: [documents.mobID]);
    return res;
  }
}