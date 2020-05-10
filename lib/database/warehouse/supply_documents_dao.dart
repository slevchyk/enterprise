
import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/supply_documnets.dart';

class SupplyDocumentsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(SupplyDocuments supplyDocuments, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : supplyDocuments?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : supplyDocuments?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into supply_documents ('
            'user_id,'
            'supply_document_status,'
            'supply_document_number,'
            'supply_document_date,'
            'supply_document_partner,'
            'supply_document_count,'
            'created_at,'
            'updated_at,'
            'is_modified'
            ')'
            'VALUES (?,?,?,?,?,?,?,?,?)',
        [
          supplyDocuments.userID,
          supplyDocuments.status,
          supplyDocuments.number,
          supplyDocuments.date.toIso8601String(),
          supplyDocuments.partner,
          supplyDocuments.count,
          createdAt,
          updatedAt,
          isModified,
        ]);
    return raw.isFinite;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("supply_documents" , where: "mob_id = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? SupplyDocuments.fromMap(res.first) : null;
  }

  Future<List<SupplyDocuments>> getSupplyDocumentByGoodsID(int id) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        "SELECT * "
            "FROM supply_documents "
            "JOIN relation_supply_documents_goods "
            "ON relation_supply_documents_goods.supply_document_id = supply_documents.mob_id "
            "WHERE relation_supply_documents_goods.goods_id = ? ",
        [id]
    );
    List<SupplyDocuments> toReturn =
    res.isNotEmpty ? res.map((e) => SupplyDocuments.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<SupplyDocuments>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("supply_documents");

    List<SupplyDocuments> toReturn =
        res.isNotEmpty ? res.map((e) => SupplyDocuments.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<SupplyDocuments>> search(String query) async {
    query = "$query%";
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'select * from supply_documents '
        'where supply_document_partner like ? '
        'OR supply_document_date like ?'
        'OR supply_document_number like ?'
        'OR supply_document_count like ?'
        ,[
          query,
          query,
          query,
          query,
        ]);

    List<SupplyDocuments> toReturn =
    res.isNotEmpty
        ? res.map((e) => SupplyDocuments.fromMap(e)).toList()
        : [];
    return toReturn;
  }

  getLastId() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'SELECT * FROM supply_documents ORDER BY mob_id DESC LIMIT 1');

    int toReturn =
    res.isNotEmpty
        ? res.map((e) => SupplyDocuments.fromMap(e).mobID).toList().first +1
        : 1;
    return toReturn;
  }

  update(SupplyDocuments supplyDocuments, {bool isModified = true}) async {
    final db = await dbProvider.database;
    supplyDocuments.isModified = isModified;
    supplyDocuments.updatedAt = DateTime.now();
    var res = await db.update("supply_documents", supplyDocuments.toMap(),
    where: "mob_id = ?", whereArgs: [supplyDocuments.mobID]);
    return res.isFinite;
  }

  deleteById(int id) async {
    final db = await dbProvider.database;
    var res = db.delete("supply_documents", where: "mob_id = ?", whereArgs: [id]);
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("supply_documents");
  }
}