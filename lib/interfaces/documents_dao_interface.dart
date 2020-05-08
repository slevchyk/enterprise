
import 'package:enterprise/models/warehouse/documnets.dart';

abstract class DocumentInterface {
  insert(Documents documents, {bool isModified = true});
  getById(int id);
  Future<List<Documents>> getDocumentByGoodsID(int id);
  Future<List<Documents>> getAll();
  Future<List<Documents>> search(String query);
  getLastId();
  update(Documents documents, {bool isModified = true});
  deleteById(int id);
  deleteAll();
}