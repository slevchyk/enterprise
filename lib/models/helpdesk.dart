import 'dart:convert';
import 'dart:io';
import 'package:enterprise/database/help_desk_dao.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class HelpDesk {
  int mobID;
  int id;
  String userID;
  String title;
  String body;
  DateTime date;
  String status;
  String answer;
  DateTime answeredAt;
  String answeredBy;
  String filePaths;
  int filesQuantity;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  bool isModified;

  HelpDesk({
    this.mobID,
    this.id,
    this.userID,
    this.title,
    this.body,
    this.date,
    this.status,
    this.answer,
    this.answeredAt,
    this.answeredBy,
    this.filePaths,
    this.filesQuantity,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.isModified,
  });

  factory HelpDesk.fromMap(Map<String, dynamic> json) => new HelpDesk(
        mobID: json['mob_id'],
        id: json["id"],
        userID: json["user_id"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        title: json["title"],
        body: json["body"],
        status: json["status"],
        answer: json["answer"],
        answeredAt: json["answered_at"] != null
            ? DateTime.parse(json["answered_at"])
            : null,
        answeredBy: json["answered_by"],
        filePaths: json['file_paths'],
        filesQuantity: json['files_quantity'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        isDeleted: json["is_deleted"] == null
            ? false
            : json["is_deleted"] is int
                ? json["is_deleted"] == 1 ? true : false
                : json["is_deleted"],
        isModified: json["is_modified"] == null
            ? false
            : json["is_modified"] is int
                ? json["is_modified"] == 1 ? true : false
                : json["is_modified"],
      );

  Map<String, dynamic> toMap() => {
        "mob_id": mobID,
        "id": id,
        "user_id": userID,
        "status": status,
        "date": date != null ? date.toIso8601String() : null,
        "title": title,
        "body": body,
        "answer": answer,
        "answered_at": answeredAt,
        "answered_by": answeredBy,
        "file_paths": filePaths,
        "files_quantity": filesQuantity,
        "created_at": createdAt != null ? createdAt.toIso8601String() : null,
        "updated_at": updatedAt != null ? updatedAt.toIso8601String() : null,
        "is_deleted": isDeleted == null ? 0 : isDeleted ? 1 : 0,
        "is_modified": isModified == null ? 0 : isModified ? 1 : 0,
      };

  static sync() async {
    await upload();
    await download();
  }

  static upload() async {
    List<HelpDesk> _listHelpDesk = await HelpdeskDAO().getToUpload();
    Map<String, dynamic> requestData;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/helpdesk?from=mobile';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    for (var _helpDesk in _listHelpDesk) {
      requestData = _helpDesk.toMap();

      Response response = await post(
        url,
        headers: headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        if (_helpDesk.id == null) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          _helpDesk.id = jsonData["id"];
        }

        HelpdeskDAO().update(_helpDesk, isModified: false);
      }
    }
  }

  static download() async {
    HelpDesk helpDesk;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _userID = prefs.getString(KEY_USER_ID) ?? "";

    final String url =
        'http://$_serverIP/api/helpdesk?for=mobile&userid=$_userID';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Response response = await get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData == null) {
        return;
      }

      for (var jsonPayDesk in jsonData) {
        helpDesk = HelpDesk.fromMap(jsonPayDesk);

        bool ok = false;

        HelpDesk existPayDesk = await HelpdeskDAO().getByID(helpDesk.id);

        if (existPayDesk != null) {
          helpDesk.mobID = existPayDesk.mobID;
          helpDesk.filePaths = existPayDesk.filePaths;
          helpDesk.filesQuantity = existPayDesk.filesQuantity;
          ok = await HelpdeskDAO().update(helpDesk, isModified: false);
        } else {
          int mobID = await HelpdeskDAO().insert(helpDesk, isModified: false);

          if (mobID != null) {
            ok = true;
          }
        }

        if (ok) {
          String urlProcessed =
              'http://$_serverIP/api/helpdesk/processed?from=mobile&id=${helpDesk.id.toString()}';
          post(urlProcessed, headers: headers);
        }
      }
    }
  }
}
