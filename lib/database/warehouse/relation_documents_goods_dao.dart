import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/relation_documents_goods.dart';

class RelationDocumentsGoodsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(RelationDocumentsGoods relationDocumentsGoods) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
      "INSERT Into relation_documents_goods ("
          "document_id,"
          "goods_id"
          ")"
          "VALUES (?,?)",
        [
          relationDocumentsGoods.documentID,
          relationDocumentsGoods.goodsID,
        ]
    );
    return raw.isFinite;
  }

  Future<List<RelationDocumentsGoods>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("relation_documents_goods");

    List<RelationDocumentsGoods> toReturn =
    res.isNotEmpty ? res.map((e) => RelationDocumentsGoods.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<RelationDocumentsGoods>> getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        "SELECT * FROM relation_documents_goods WHERE document_id = ?",
      [id]
    );
    List<RelationDocumentsGoods> toReturn =
    res.isNotEmpty ? res.map((e) => RelationDocumentsGoods.fromMap(e)).toList() : [];
    return toReturn;
  }

  deleteById(int docID) async {
    final db = await dbProvider.database;
    var res = await db.delete("relation_documents_goods",
        where: "document_id = ?",
        whereArgs: [docID]
    );
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("relation_documents_goods");
  }

}