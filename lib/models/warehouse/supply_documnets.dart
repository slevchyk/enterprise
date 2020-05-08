import 'package:enterprise/models/warehouse/goods.dart';

class SupplyDocuments {
  int mobID;
  int id;
  String userID;
  bool status;
  int number;
  DateTime date;
  String partner;
  int count;
  List<Goods> goods = List();
  DateTime createdAt;
  DateTime updatedAt;
  bool isModified;

  SupplyDocuments({
    this.mobID,
    this.id,
    this.userID,
    this.status,
    this.number,
    this.date,
    this.partner,
    this.count,
    this.createdAt,
    this.updatedAt,
    this.isModified,
  });

  factory SupplyDocuments.fromMap(Map<String, dynamic> json) => new SupplyDocuments(
    mobID: json["mob_id"],
    id: json["id"],
    userID: json["user_id"],
    status: json["supply_document_status"] == 1 ? true : false,
    number: json["supply_document_number"],
    date: DateTime.parse(json["supply_document_date"]),
    partner: json["supply_document_partner"],
    count: json["supply_document_count"],
    createdAt: json['created_at'] != null ?
        DateTime.parse(json["created_at"]) :
        null,
    updatedAt: json['updated_at'] != null ?
        DateTime.parse(json["updated_at"]) :
        null,
    isModified: json["is_modified"] == 1 ? true : false,
  );

  Map<String, dynamic> toMap() => {
    "mob_id" : mobID,
    "id" : id,
    "user_id" : userID,
    "supply_document_status" : status ? 1 : 0,
    "supply_document_number" : number,
    "supply_document_date" : date.toIso8601String(),
    "supply_document_partner" : partner,
    "supply_document_count" : count,
    'created_at': createdAt != null ? createdAt.toIso8601String() : null,
    'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
    "is_modified": isModified ? 1 : 0,
  };
}