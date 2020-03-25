import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/timing_dao.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import '../utils.dart';

class Timing {
  int mobID;
  int id;
  String accID;
  String userID;
  DateTime date;
  String status;
  DateTime startedAt;
  DateTime endedAt;
  double duration;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  bool isModified;
  bool isTurnstile;

  Timing({
    this.mobID,
    this.id,
    this.accID,
    this.userID,
    this.date,
    this.status,
    this.startedAt,
    this.endedAt,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isModified,
    this.isTurnstile,
  });

  factory Timing.fromMap(Map<String, dynamic> json) => new Timing(
        mobID: json["mob_id"],
        id: json["id"],
        accID: json["acc_id"],
        userID: json["user_id"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        status: json["status"],
        startedAt: json["started_at"] != null
            ? DateTime.parse(json["started_at"])
            : null,
        endedAt: json["ended_at"] != null && json["ended_at"] != ""
            ? DateTime.parse(json["ended_at"])
            : null,
        createdAt: json["created_at"] != null && json["created_at"] != ""
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null && json["updated_at"] != ""
            ? DateTime.parse(json["updated_at"])
            : null,
        deletedAt: json["deleted_at"] != null && json["deleted_at"] != ""
            ? DateTime.parse(json["deleted_at"])
            : null,
        isModified: json["is_modified"] == 1 ? true : false,
        isTurnstile: json["is_turnstile"] == 1 ? true : false,
      );

  Map<String, dynamic> toMap() => {
        "mob_id": mobID,
        "id": id,
        "acc_id": accID,
        "user_id": userID,
        "date": date != null ? date.toIso8601String() : null,
        "status": status,
        "started_at": startedAt != null ? startedAt.toIso8601String() : null,
        "ended_at": endedAt != null ? endedAt.toIso8601String() : null,
        "created_at": createdAt != null ? createdAt.toIso8601String() : null,
        "updated_at": updatedAt != null ? updatedAt.toIso8601String() : null,
        "deleted_at": deletedAt != null ? deletedAt.toIso8601String() : null,
        "is_modified": isModified ? 1 : 0,
        "is_turnstile": isTurnstile ? 1 : 0,
      };

  static upload(String userID) async {
    List<Timing> toUpload = await TimingDAO().getToUploadByUserId(userID);
    List<Map<String, dynamic>> requestData = [];

    for (var _timing in toUpload) {
      requestData.add(_timing.toMap());
    }

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/timing?from=mobile';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Response response = await post(
      url,
      headers: headers,
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      for (var _timingMap in jsonData["timing"]) {
        var _timing = Timing.fromMap(_timingMap);

        if (_timing.mobID == null || _timing.mobID == 0) {
          TimingDAO().insert(_timing, isModified: false);
        } else {
          Timing _existingTiming = await TimingDAO().getByMobId(_timing.mobID);

          if (_existingTiming == null) {
            TimingDAO().insert(_timing, isModified: false);
          } else {
            TimingDAO().updateByMobID(_timing, isModified: false);
          }
        }
      }
    }
  }

  static downloadByDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();

    final String _userID = prefs.getString(KEY_USER_ID) ?? "";

    final String _srvIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _srvUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _srvPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    String strDate = formatDate(date, [yyyy, mm, dd]);

    final String url =
        'http://$_srvIP/api/timing?type=dateuser&userid=$_userID&date=$strDate';

    final credentials = '$_srvUser:$_srvPassword';
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
      Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData["timing"] == null) {
        return;
      }

      for (var _timingMap in jsonData["timing"]) {
        var _timing = Timing.fromMap(_timingMap);

        if (_timing.mobID == null || _timing.mobID == 0) {
          Timing _existingTiming = await TimingDAO().getById(_timing.id);

          if (_existingTiming == null) {
            TimingDAO().insert(_timing);
          } else {
            TimingDAO().updateByID(_timing);
          }
        } else {
          Timing _existingTiming = await TimingDAO().getByMobId(_timing.mobID);

          if (_existingTiming == null) {
            TimingDAO().insert(_timing, isModified: false);
          } else {
            TimingDAO().updateByMobID(_timing, isModified: false);
          }
        }
      }
    }
  }

  static syncTurnstile() async {
    List<Timing> toUpload = await TimingDAO().getToUploadTurnstile();

    Map<String, List<Map<String, dynamic>>> jsonData;
    List<Map<String, dynamic>> rows = [];

    for (var _timing in toUpload) {
      rows.add(_timing.toMap());
    }

    jsonData = {'timing': rows};

    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _serverDB = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String url = 'http://$_serverIP/$_serverDB/hs/m/turnstile';

    final credentials = '$_serverUser:$_serverPassword';
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

      for (var _timingMap in jsonData['processed']) {
        var _timing = Timing.fromMap(_timingMap);

        if (_timing.mobID == null || _timing.mobID == 0) {
          TimingDAO().insert(_timing, isModified: false);
        } else {
          Timing _existingTiming = await TimingDAO().getByMobId(_timing.mobID);

          if (_existingTiming == null) {
            TimingDAO().insert(_timing, isModified: false);
          } else {
            TimingDAO().updateByMobID(_timing, isModified: false);
          }
        }
      }
    }
  }

  static void closePastTiming() async {
    List<Timing> openOperation = await TimingDAO()
        .getOpenPastStatus(Utility.beginningOfDay(DateTime.now()));

    for (var _timing in openOperation) {
      DateTime endDate = new DateTime(_timing.startedAt.year,
          _timing.startedAt.month, _timing.startedAt.day, 18, 00, 00);

      if (endDate.millisecondsSinceEpoch >
          _timing.startedAt.millisecondsSinceEpoch) {
        endDate = _timing.startedAt;
      }

      _timing.endedAt = endDate;
      TimingDAO().updateByMobID(_timing);
    }
  }

  Color color() {
    switch (status) {
      case TIMING_STATUS_JOB:
        return Colors.green.shade600;
      case TIMING_STATUS_LANCH:
        return Colors.green.shade500;
      case TIMING_STATUS_BREAK:
        return Colors.green.shade400;
      default:
        return Colors.green.shade400;
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
