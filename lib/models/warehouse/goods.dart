class Goods {
  int mobID;
  int id;
  String userID;
  bool status;
  int count;
  String name;
  String unit;

  Goods({
    this.mobID,
    this.id,
    this.userID,
    this.status,
    this.count,
    this.name,
    this.unit,
  });

  factory Goods.fromMap(Map<String, dynamic> json) => new Goods(
    mobID: json["mob_id"],
    id: json["id"],
    userID: json["user_id"],
    status: json["good_status"] == 1 ? true : false,
    count: json["good_count"],
    name: json["good_name"],
    unit: json["good_unit"],
  );

  Map<String, dynamic> toMap() => {
    "mob_id" : mobID,
    "id" : id,
    "user_id" : userID,
    "good_status" : status ? 1 : 0,
    "good_count" : count,
    "good_name" : name,
    "good_unit" : unit,
  };
}
