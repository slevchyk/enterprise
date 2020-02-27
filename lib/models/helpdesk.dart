import 'package:enterprise/database/help_desk_dao.dart';

class Helpdesk {
  int id;
  String userID;
  String title;
  String description;
  DateTime date;
  String status;
  DateTime ansvered_ad;
  String ansvered_by;
  String ansver;

  Helpdesk({
    this.id,
    this.userID,
    this.title,
    this.description,
    this.date,
    this.status,
    this.ansvered_ad,
    this.ansvered_by,
    this.ansver,
  });

  factory Helpdesk.fromMap(Map<String, dynamic> json) => new Helpdesk(
        id: json["id"],
        userID: json["user_id"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        title: json["title"],
        description: json["description"],
        status: json["status"],
        ansvered_ad: json["ansvered_ad"] != null
            ? DateTime.parse(json["ansvered_ad"])
            : null,
        ansvered_by: json["ansvered_by"],
        ansver: json["ansver"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "type": status,
        "date": date != null ? date.toIso8601String() : null,
        "title": title,
        "news": description,
        "ansvered_ad":
            ansvered_ad != null ? ansvered_ad.toIso8601String() : null,
        "ansvered_by": ansvered_by,
        "ansver": ansver,
      };
}
