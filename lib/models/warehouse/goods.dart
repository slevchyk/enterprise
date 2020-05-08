class Goods {
  int mobID;
  int id;
  String userID;
  bool status;
  bool isSelected;
  int count;
  String name;
  String unit;
  DateTime createdAt;
  DateTime updatedAt;
  bool isModified;

  Goods({
    this.mobID,
    this.id,
    this.userID,
    this.isSelected = false,
    this.status,
    this.count,
    this.name,
    this.unit,
    this.createdAt,
    this.updatedAt,
    this.isModified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Goods &&
              runtimeType == other.runtimeType &&
              mobID == other.mobID &&
              count == other.count &&
              name == other.name;

  @override
  int get hashCode =>
      mobID.hashCode ^
      count.hashCode ^
      name.hashCode;

  factory Goods.fromMap(Map<String, dynamic> json) => new Goods(
    mobID: json["mob_id"],
    id: json["id"],
    userID: json["user_id"],
    status: json["good_status"] == 1 ? true : false,
    count: json["good_count"],
    name: json["good_name"],
    unit: json["good_unit"],
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
    "good_status" : status ? 1 : 0,
    "good_count" : count,
    "good_name" : name,
    "good_unit" : unit,
    'created_at': createdAt != null ? createdAt.toIso8601String() : null,
    'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
    "is_modified": isModified ? 1 : 0,
  };
}
