import 'package:enterprise/models/warehouse/goods.dart';

class Documents {
  int mobID;
  int id;
  String userID;
  bool status;
  int number;
  DateTime date;
  String partner;
  List<Goods> goods = List();
  DateTime createdAt;
  DateTime updatedAt;
  bool isModified;

  Documents({
    this.mobID,
    this.id,
    this.userID,
    this.status,
    this.number,
    this.date,
    this.partner,
    this.createdAt,
    this.updatedAt,
    this.isModified,
  });

  factory Documents.fromMap(Map<String, dynamic> json) => new Documents(
    mobID: json["mob_id"],
    id: json["id"],
    userID: json["user_id"],
    status: json["document_status"] == 1 ? true : false,
    number: json["document_number"],
    date: DateTime.parse(json["document_date"]),
    partner: json["document_partner"],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json["updated_at"])
        : null,
    isModified: json["is_modified"] == 1 ? true : false,
  );

  Map<String, dynamic> toMap() => {
    "mob_id" : mobID,
    "id" : id,
    "user_id" : userID,
    "document_status" : status ? 1 : 0,
    "document_number" : number,
    "document_date" : date.toIso8601String(),
    "document_partner" : partner,
    'created_at': createdAt != null ? createdAt.toIso8601String() : null,
    'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
    "is_modified": isModified ? 1 : 0,
  };
}