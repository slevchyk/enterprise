class Goods {
  int mobID;
  int id;
  String accID;
  bool isDeleted;
  String name;

  Goods({
    this.mobID,
    this.id,
    this.accID,
    this.isDeleted,
    this.name,
  });

  factory Goods.fromMap(Map<String, dynamic> json) => new Goods(
        mobID: json["mob_id"],
        id: json["id"],
        accID: json["acc_id"],
        isDeleted: json["is_deleted"] == 1 ? true : false,
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "mob_id": mobID,
        "id": id,
        "acc_id": accID,
        "is_deleted": isDeleted ? 1 : 0,
        "name": name,
      };
}
