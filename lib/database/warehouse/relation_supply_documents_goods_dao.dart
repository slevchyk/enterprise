import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/relation_supply_documents_goods.dart';

class RelationSupplyDocumentsGoodsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(RelationSupplyDocumentsGoods relationSupplyDocumentsGoods) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
      "INSERT Into relation_supply_documents_goods ("
          "supply_document_id,"
          "goods_id"
          ")"
          "VALUES (?,?)",
        [
          relationSupplyDocumentsGoods.documentID,
          relationSupplyDocumentsGoods.goodsID,
        ]
    );
    return raw.isFinite;
  }

  Future<List<RelationSupplyDocumentsGoods>>getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        "SELECT * FROM relation_supply_documents_goods WHERE supply_document_id = ?",
        [id]
    );
    List<RelationSupplyDocumentsGoods> toReturn =
    res.isNotEmpty ? res.map((e) => RelationSupplyDocumentsGoods.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<RelationSupplyDocumentsGoods>>getAllConnectedToId(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("relation_supply_documents_goods",
        where: "supply_document_id = ? ", whereArgs: [id]);
    List<RelationSupplyDocumentsGoods> toReturn =
    res.isNotEmpty ? res.map((e) => RelationSupplyDocumentsGoods.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<RelationSupplyDocumentsGoods>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("relation_supply_documents_goods");

    List<RelationSupplyDocumentsGoods> toReturn =
    res.isNotEmpty ? res.map((e) => RelationSupplyDocumentsGoods.fromMap(e)).toList() : [];
    return toReturn;
  }

  deleteById(int docID) async {
    final db = await dbProvider.database;
    var res = await db.delete("relation_supply_documents_goods",
        where: "supply_document_id = ?",
        whereArgs: [docID]
    );
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("relation_supply_documents_goods");
  }

}