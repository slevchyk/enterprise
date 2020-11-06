import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/user_grants_dao.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'constants.dart';

class UserGrants{
  String userID;
  int objectType;
  String objectAccID;
  bool isVisible;
  bool isAvailable;
  bool isReceiver;

  UserGrants({
    this.userID,
    this.objectType,
    this.objectAccID,
    this.isVisible,
    this.isAvailable,
    this.isReceiver,
  });

  factory UserGrants.fromMap(Map<String, dynamic> json) => UserGrants(
    userID: json['user_id'],
    objectType: json['odject_type'],
    objectAccID: json['odject_acc_id'],
    isVisible: json["is_visible"] == null
        ? false
        : json["is_visible"] is int
        ? json["is_visible"] == 1 ? true : false
        : json["is_visible"],
    isAvailable: json["is_available"] == null
        ? false
        : json["is_available"] is int
        ? json["is_available"] == 1 ? true : false
        : json["is_available"],
    isReceiver: json["is_receiver"] == null
        ? false
        : json["is_receiver"] is int
        ? json["is_receiver"] == 1 ? true : false
        : json["is_receiver"],
  );

  Map<String, dynamic> toMap() => {
    'user_id' : userID,
    'odject_type' : objectType,
    'odject_acc_id' : objectAccID,
    "is_visible" : isVisible == null ? 0 : isVisible ? 1 : 0,
    "is_available" : isAvailable == null ? 0 : isAvailable ? 1 : 0,
    "is_receiver" : isReceiver == null ? 0 : isReceiver ? 1 : 0,
  };

  static Future<bool> sync({GlobalKey<ScaffoldState> scaffoldKey}) async {
    if(!await EnterpriseApp.checkInternet(showSnackBar: true, scaffoldKey: scaffoldKey)){
      return false;
    }
    UserGrants userGrants;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _userID = prefs.getString(KEY_USER_ID);

    final String url = 'http://$_serverIP/api/usergrants?userid=$_userID';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try {
      Response response = await get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData == null) {
          return true;
        }

        for (var jsonPayOffice in jsonData) {
          userGrants = UserGrants.fromMap(jsonPayOffice);

          UserGrants existUserGrants = await UserGrantsDAO().getByObjectAccID(userGrants.objectAccID);

          if (existUserGrants != null) {
            UserGrantsDAO().update(userGrants);
          } else {
            UserGrantsDAO().insert(userGrants);
          }
        }
        await PayOffice.sync();
        ShowSnackBar.show(scaffoldKey, "Дані оновлено", Colors.green);
        return true;
      }  else {
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error",
        );
        ShowSnackBar.show(scaffoldKey, "Помилка оновлення даних", Colors.orange);
        return false;
      }
    } catch (e, s) {
      FLog.error(
        exception: Exception(e.toString()),
        text: "response error",
        stacktrace: s,
      );
      ShowSnackBar.show(scaffoldKey, "Помилка оновлення даних", Colors.orange);
      return false;
    }
  }
}