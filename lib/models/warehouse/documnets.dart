class Documents {
  int mobID;
  int id;
  String userID;
  bool status;
  int number;
  DateTime date;
  String partner;

  Documents({
    this.mobID,
    this.id,
    this.userID,
    this.status,
    this.number,
    this.date,
    this.partner,
  });

  factory Documents.fromMap(Map<String, dynamic> json) => new Documents(
    mobID: json["mob_id"],
    id: json["id"],
    userID: json["user_id"],
    status: json["document_status"] == 1 ? true : false,
    number: json["document_number"],
    date: DateTime.parse(json["document_date"]),
    partner: json["document_partner"],
  );

  Map<String, dynamic> toMap() => {
    "mob_id" : mobID,
    "id" : id,
    "user_id" : userID,
    "document_status" : status ? 1 : 0,
    "document_number" : number,
    "document_date" : date.toIso8601String(),
    "document_partner" : partner,
  };
}