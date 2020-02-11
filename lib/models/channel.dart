class Channel {
  int id;
  String userID;
  String title;
  String news;
  DateTime date;
  DateTime starredAt;
  DateTime archivedAt;
  DateTime deletedAt;
  String status;

  Channel({
    this.id,
    this.userID,
    this.title,
    this.news,
    this.date,
    this.starredAt,
    this.archivedAt,
    this.deletedAt,
    this.status,
  });

  factory Channel.fromMap(Map<String, dynamic> json) => new Channel(
        id: json["id"],
        title: json["title"],
        news: json["news"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        starredAt: json["starred_at"] != null
            ? DateTime.parse(json["starred_at"])
            : null,
        archivedAt: json["archived_at"] != null
            ? DateTime.parse(json["archived_at"])
            : null,
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "title": title,
        "news": news,
        "date": date != null ? date.toIso8601String() : null,
        "starred_at": starredAt != null ? starredAt.toIso8601String() : null,
        "archived_at": archivedAt != null ? archivedAt.toIso8601String() : null,
        "deleted_at": deletedAt != null ? deletedAt.toIso8601String() : null,
        "status": status,
      };
}
