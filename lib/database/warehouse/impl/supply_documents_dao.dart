
import 'package:enterprise/database/warehouse/goods_dao.dart';
import 'package:enterprise/database/warehouse/relation_supply_documents_goods_dao.dart';
import 'package:enterprise/database/warehouse/supply_documents_dao.dart';
import 'package:enterprise/interfaces/supply_documents_dao_interface.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/models/warehouse/relation_supply_documents_goods.dart';
import 'package:enterprise/models/warehouse/supply_documnets.dart';

class ImplSupplyDocumentsDAO implements SupplyDocumentInterface {
  SupplyDocumentsDAO supplyDocumentsDAO = SupplyDocumentsDAO();

  insert(SupplyDocuments supplyDocuments, {bool isModified = true}) async {
    return supplyDocumentsDAO.insert(supplyDocuments,isModified: isModified);
  }

  Future<SupplyDocuments> getById(int id) async {
    return _addGoodsToDocument(await supplyDocumentsDAO.getById(id), id);
  }

  Future<List<SupplyDocuments>> getDocumentByGoodsID(int id) async {
    return await _addGoodsToListDocument(await supplyDocumentsDAO.getSupplyDocumentByGoodsID(id));
  }

  Future<List<SupplyDocuments>> getAll() async {
    return await _addGoodsToListDocument(await supplyDocumentsDAO.getAll());
  }

  Future<List<SupplyDocuments>> search(String query) async {
    return await _addGoodsToListDocument(await supplyDocumentsDAO.search(query));
  }

  getLastId() async {
    return await supplyDocumentsDAO.getLastId();
  }

  update(SupplyDocuments supplyDocuments, {bool isModified = true}) async {
    return supplyDocumentsDAO.update(supplyDocuments, isModified: isModified);
  }

  deleteById(int id) async {
    return supplyDocumentsDAO.deleteById(id);
  }

  deleteAll() async {
    return supplyDocumentsDAO.deleteAll();
  }

  Future<List<SupplyDocuments>> _addGoodsToListDocument(List<SupplyDocuments> input) async {
    List<Goods> goods = await GoodsDAO().getAll();
    List<RelationSupplyDocumentsGoods> relation =
    await RelationSupplyDocumentsGoodsDAO().getAll();
    input.forEach((document) {
      relation.where((relation) => relation.documentID==document.mobID)
          .forEach((relation) {
        document.goods.add(goods.where((good) => good.mobID == relation.goodsID)
            .toList().first);
      });
    });
    return input;
  }

  Future<SupplyDocuments> _addGoodsToDocument(SupplyDocuments input, int id) async {
    List<Goods> goods = await GoodsDAO().getAll();
    List<RelationSupplyDocumentsGoods> relations =
    await RelationSupplyDocumentsGoodsDAO().getById(id);
    relations.forEach((relation) async {
      input.goods.add(goods.where((good) => good.mobID == relation.goodsID).toList().first);
    });
    return input;
  }
}