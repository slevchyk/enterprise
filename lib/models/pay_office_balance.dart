import 'dart:convert';
import 'dart:io';

import 'package:enterprise/models/constants.dart';
import 'package:f_logs/f_logs.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayOfficeBalance{
  String accID;
  int balance;
  DateTime updatedAt;

  PayOfficeBalance({
    this.accID,
    this.balance,
    this.updatedAt,
  });

  factory PayOfficeBalance.fromMap(Map<String, dynamic> json) => PayOfficeBalance(
    accID: json['acc_id'],
    balance: json['balance'],
    updatedAt: json['updated_at'] != null ? DateTime.parse(json["updated_at"]) : null,
  );

  Map<String, dynamic> toMap() => {
    'acc_id' : accID,
    'balance' : balance,
    'updated_at' : updatedAt != null ? updatedAt.toIso8601String() : null,
  };

  static Future<List<PayOfficeBalance>> sync() async {
    PayOfficeBalance payOfficeBalance;
    List<PayOfficeBalance> toReturn = [];

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/payoffices/balance';

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
          return null;
        }

        for (var jsonPayDesk in jsonData) {
          payOfficeBalance = PayOfficeBalance.fromMap(jsonPayDesk);
          toReturn.add(payOfficeBalance);
        }
        return toReturn;
      }  else {
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error",
        );
        return null;
      }
    } catch (e, s){
      FLog.error(
        exception: Exception(e.toString()),
        text: "try block error",
        stacktrace: s,
      );
      return null;
    }
  }
}