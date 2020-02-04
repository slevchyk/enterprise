import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/timing_dao.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contatns.dart';
import '../utils.dart';

class Timing {
  int id;
  String extID;
  String userID;
  DateTime date;
  String operation;
  DateTime startedAt;
  DateTime endedAt;
  double duration;
  bool toUpload;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;

  Timing({
    this.id,
    this.extID,
    this.userID,
    this.date,
    this.operation,
    this.startedAt,
    this.endedAt,
    this.duration,
    this.toUpload,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Timing.fromMap(Map<String, dynamic> json) => new Timing(
        id: json["id"],
        extID: json["ext_id"],
        userID: json["user_id"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        operation: json["operation"],
        startedAt: json["started_at"] != null
            ? DateTime.parse(json["started_at"])
            : null,
        endedAt:
            json["ended_at"] != null ? DateTime.parse(json["ended_at"]) : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "date": date != null ? date.toIso8601String() : null,
        "operation": operation,
        "started_at": startedAt != null ? startedAt.toIso8601String() : null,
        "ended_at": endedAt != null ? endedAt.toIso8601String() : null,
        "created_at": createdAt != null ? createdAt.toIso8601String() : null,
        "updated_at": updatedAt != null ? updatedAt.toIso8601String() : null,
        "deleted_at": deletedAt != null ? deletedAt.toIso8601String() : null,
        "ext_id": extID,
      };

  static upload(userID) async {
    List<Timing> toUpload = await TimingDAO().getToUploadByUserId(userID);

    Map<String, List<Map<String, dynamic>>> jsonData;
    List<Map<String, dynamic>> rows = [];

    for (var _timing in toUpload) {
      rows.add(_timing.toMap());
    }

    jsonData = {'timing': rows};

    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassord = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _serverDB = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String url = 'http://$_serverIP/$_serverDB/hs/m/timing';

    final credentials = '$_serverUser:$_serverPassord';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Response response = await post(
      url,
      headers: headers,
      body: json.encode(jsonData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      for (var _timing in jsonData['processed']) {
        TimingDAO().updateProcessedById(_timing['id'], _timing['ext_id']);
      }
    }
  }

  static void closePastOperation() async {
    List<Timing> openOperation = await TimingDAO()
        .getOpenPastOperation(Utility.beginningOfDay(DateTime.now()));

    for (var _timing in openOperation) {
      DateTime endDate = new DateTime(_timing.startedAt.year,
          _timing.startedAt.month, _timing.startedAt.day, 18, 00, 00);

      if (endDate.millisecondsSinceEpoch >
          _timing.startedAt.millisecondsSinceEpoch) {
        endDate = _timing.startedAt;
      }

      _timing.endedAt = endDate;
      TimingDAO().update(_timing);
    }
  }

//  static Future<List<TimingDayData>> getTimingDayChartData(
//      String userID, DateTime dateTime) async {
//    DateTime beginDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
//
//    List<Timing> listTiming =
//        await DBProvider.db.getUserTiming(beginDay, userID);
//
//    List<TimingDayData> listOperation = [];
//
//    for (var _timing in listTiming) {
//      DateTime endDate = _timing.endDate;
//      if (endDate == null) {
//        endDate = DateTime.now();
//      }
//
//      double time = (endDate.millisecondsSinceEpoch -
//              _timing.startDate.millisecondsSinceEpoch) /
//          3600000;
//
////      DateTime endDate = _timing.endDate = null ? DateTime.now() : _timing.endDate;
////
////      double time = endDate.millisecondsSinceEpoch - _timing.startDate.millisecondsSinceEpoch / 36000000;
//
////      TimingDayData operation = TimingDayData(_timing.operation, time);
//
//      TimingDayData operation = TimingDayData(_timing.operation, 22.0);
//      listOperation.add(operation);
//    }
//
//    return listOperation;
//  }

}
