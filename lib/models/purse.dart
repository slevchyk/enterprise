import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/purse_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Purse{
  int mobID;
  int id;
  String uid;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  bool isModified;

  Purse({
    this.mobID,
    this.id,
    this.uid,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.isModified
  });

  factory Purse.fromMap(Map<String, dynamic> json) => Purse(
    mobID: json['mob_id'],
    id: json['id'],
    uid: json['user_id'],
    name: json['name'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json["updated_at"])
        : null,
    isModified: json["is_modified"] == null
        ? false
        : json["is_modified"] is int
        ? json["is_modified"] == 1 ? true : false
        : json["is_modified"],
  );

  Map<String, dynamic> toMap() => {
    'mob_id' : mobID,
    'id' : id,
    'user_id' : uid,
    'name' : name,
    'created_at': createdAt != null ? createdAt.toIso8601String() : null,
    'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
    "is_modified": isModified == null ? 0 : isModified ? 1 : 0,
  };

  static sync() async {
    await upload();
    await download();
  }

  static upload() async {
    List<Purse> _listPurse = await PurseDAO().getToUpload();
    Map<String, dynamic> requestData;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/paydesk?from=mobile';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    for (var _purse in _listPurse) {
      requestData = _purse.toMap();

      Response response = await post(
        url,
        headers: headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        if (_purse.id == null) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          _purse.id = jsonData["id"];
        }

        PurseDAO().update(_purse, isModified: false);
      }
    }
  }

  static download() async {
    Purse purse;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _userID = prefs.getString(KEY_USER_ID) ?? "";

    final String url =
        'http://$_serverIP/api/paydesk?for=mobile&userid=$_userID';

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

      for (var jsonExpense in jsonData) {
        purse = Purse.fromMap(jsonExpense);

        bool ok = false;

        Purse existPurse = await PurseDAO().getByID(purse.id);

        if (existPurse != null) {
          purse.mobID = existPurse.mobID;
          ok = await PurseDAO().update(purse, isModified: false);
        } else {
          int mobID = await PurseDAO().insert(purse, isModified: false);

          if (mobID != null) {
            ok = true;
          }
        }

        if (ok) {
          String urlProcessed =
              'http://$_serverIP/api/paydesk/processed?from=mobile&id=${purse.id.toString()}';
          post(urlProcessed, headers: headers);
        }
      }
    }
  }
}