class Helpdesk {
  int id;
  String userID;
  String title;
  String description;
  DateTime date;
  String status;
  DateTime answeredAt;
  String answeredBy;
  String answer;

  Helpdesk({
    this.id,
    this.userID,
    this.title,
    this.description,
    this.date,
    this.status,
    this.answeredAt,
    this.answeredBy,
    this.answer,
  });

  factory Helpdesk.fromMap(Map<String, dynamic> json) => new Helpdesk(
        id: json["id"],
        userID: json["user_id"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        title: json["title"],
        description: json["description"],
        status: json["status"],
        answeredAt: json["answered_at"] != null
            ? DateTime.parse(json["answered_at"])
            : null,
        answeredBy: json["answered_by"],
        answer: json["ansver"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "type": status,
        "date": date != null ? date.toIso8601String() : null,
        "title": title,
        "news": description,
        "answered_at": answeredAt != null ? answeredAt.toIso8601String() : null,
        "answered_by": answeredBy,
        "answer": answer,
      };
}
