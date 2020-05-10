
import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/interfaces/documents_dao_interface.dart';
import 'package:enterprise/models/warehouse/documnets.dart';

class DocumentsDAO implements DocumentInterface {
  final dbProvider = DBWarehouseProvider.db;

  insert(Documents documents, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : documents?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : documents?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into documents ('
            'user_id,'
            'document_status,'
            'document_number,'
            'document_date,'
            'document_partner,'
            'created_at,'
            'updated_at,'
            'is_modified'
            ')'
            'VALUES (?,?,?,?,?,?,?,?)',
        [
          documents.userID,
          documents.status,
          documents.number,
          documents.date.toIso8601String(),
          documents.partner,
          createdAt,
          updatedAt,
          isModified,
        ]);
    return raw.isFinite;
  }

  Future<Documents> getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("documents" , where: "mob_id = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? Documents.fromMap(res.first) : null;
  }

  Future<List<Documents>> getDocumentByGoodsID(int id) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        "SELECT * "
            "FROM documents "
            "JOIN relation_documents_goods "
            "ON relation_documents_goods.document_id = documents.mob_id "
            "WHERE relation_documents_goods.goods_id = ? ",
      [id]
    );
    List<Documents> toReturn =
    res.isNotEmpty ? res.map((e) => Documents.fromMap(e)).toList() : [];
    return toReturn;
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

  getLastId() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'SELECT * FROM documents ORDER BY mob_id DESC LIMIT 1');

    int toReturn =
    res.isNotEmpty
        ? res.map((e) => Documents.fromMap(e).mobID).toList().first +1
        : 1;
    return toReturn;
  }

  update(Documents documents, {bool isModified = true}) async {
    final db = await dbProvider.database;
    documents.isModified = isModified;
    documents.updatedAt = DateTime.now();
    var res = await db.update("documents", documents.toMap(),
    where: "mob_id = ?", whereArgs: [documents.mobID]);
    return res.isFinite;
  }

  deleteById(int id) async {
    final db = await dbProvider.database;
    var res = db.delete("documents", where: "mob_id = ?", whereArgs: [id]);
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("documents");
  }
}