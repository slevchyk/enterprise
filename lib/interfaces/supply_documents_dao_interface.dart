
import 'package:enterprise/models/warehouse/supply_documnets.dart';

abstract class SupplyDocumentInterface {
  insert(SupplyDocuments supplyDocuments, {bool isModified = true});
  getById(int id);
  Future<List<SupplyDocuments>> getDocumentByGoodsID(int id);
  Future<List<SupplyDocuments>> getAll();
  Future<List<SupplyDocuments>> search(String query);
  getLastId();
  update(SupplyDocuments supplyDocuments, {bool isModified = true});
  deleteById(int id);
  deleteAll();
}