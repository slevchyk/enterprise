import 'package:enterprise/database/channel_dao.dart';

class Channel {
  int id;
  String userID;
  String title;
  String news;
  DateTime date;
  DateTime starredAt;
  DateTime archivedAt;
  DateTime deletedAt;
  String type;

  Channel({
    this.id,
    this.userID,
    this.title,
    this.news,
    this.date,
    this.starredAt,
    this.archivedAt,
    this.deletedAt,
    this.type,
  });

  factory Channel.fromMap(Map<String, dynamic> json) => new Channel(
        id: json["id"],
        userID: json["user_id"],
        type: json["type"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        title: json["title"],
        news: json["news"],
        starredAt: json["starred_at"] != null
            ? DateTime.parse(json["starred_at"])
            : null,
        archivedAt: json["archived_at"] != null
            ? DateTime.parse(json["archived_at"])
            : null,
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "type": type,
        "date": date != null ? date.toIso8601String() : null,
        "title": title,
        "news": news,
        "starred_at": starredAt != null ? starredAt.toIso8601String() : null,
        "archived_at": archivedAt != null ? archivedAt.toIso8601String() : null,
        "deleted_at": deletedAt != null ? deletedAt.toIso8601String() : null,
      };

  processDownloads() async {
    Channel existChannel = await ChannelDAO().getById(this.id);

    if (existChannel != null) {
      this.starredAt = existChannel.starredAt;
      this.deletedAt = existChannel.deletedAt;
      this.archivedAt = existChannel.archivedAt;
      ChannelDAO().update(this);
    } else {
      ChannelDAO().insert(this);
    }
  }
}
