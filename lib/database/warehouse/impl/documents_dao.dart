
import 'package:enterprise/database/warehouse/documents_dao.dart';
import 'package:enterprise/database/warehouse/relation_documents_goods_dao.dart';
import 'package:enterprise/interfaces/documents_dao_interface.dart';
import 'package:enterprise/models/warehouse/documnets.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/models/warehouse/relation_documents_goods.dart';

import '../user_goods_dao.dart';

class ImplDocumentsDAO implements DocumentInterface {
  DocumentsDAO documentsDAO = DocumentsDAO();

  insert(Documents documents, {bool isModified = true}) async {
    return documentsDAO.insert(documents,isModified: isModified);
  }

  Future<Documents> getById(int id) async {
    return _addGoodsToDocument(await documentsDAO.getById(id), id);
  }

  Future<List<Documents>> getDocumentByGoodsID(int id) async {
    return await _addGoodsToListDocument(await documentsDAO.getDocumentByGoodsID(id));
  }

  Future<List<Documents>> getAll() async {
    return await _addGoodsToListDocument(await documentsDAO.getAll());
  }

  Future<List<Documents>> search(String query) async {
    return await _addGoodsToListDocument(await documentsDAO.search(query));
  }

  getLastId() async {
    return await documentsDAO.getLastId();
  }

  update(Documents documents, {bool isModified = true}) async {
    return documentsDAO.update(documents, isModified: isModified);
  }

  deleteById(int id) async {
    return documentsDAO.deleteById(id);
  }

  deleteAll() async {
    return documentsDAO.deleteAll();
  }

  Future<List<Documents>> _addGoodsToListDocument(List<Documents> input) async {
    List<Goods> goods = await UserGoodsDAO().getAll();
    List<RelationDocumentsGoods> relation =
        await RelationDocumentsGoodsDAO().getAll();
    input.forEach((document) {
      relation.where((relation) => relation.documentID==document.mobID)
          .forEach((relation) {
        document.goods.add(goods.where((good) => good.mobID == relation.goodsID)
            .toList().first);
      });
    });
    return input;
  }

  Future<Documents> _addGoodsToDocument(Documents input, int id) async {
    List<Goods> goods = await UserGoodsDAO().getAll();
    List<RelationDocumentsGoods> relations = await RelationDocumentsGoodsDAO().getById(id);
    relations.forEach((relation) async {
      input.goods.add(goods.where((good) => good.mobID == relation.goodsID).toList().first);
    });
    return input;
  }
}