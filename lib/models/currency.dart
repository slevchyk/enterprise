import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/currency_dao.dart';
import 'package:f_logs/f_logs.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class Currency {
  int mobID;
  int id;
  String accID;
  int code;
  String name;
  bool isDeleted;

  Currency({
    this.mobID,
    this.id,
    this.accID,
    this.code,
    this.name,
    this.isDeleted,
  });

  factory Currency.fromMap(Map<String, dynamic> json) => Currency(
        mobID: json["mob_id"],
        id: json["id"],
        accID: json["acc_id"],
        code: json["code"],
        name: json["name"],
        isDeleted: json["is_deleted"] == null
            ? false
            : json["is_deleted"] is int
                ? json["is_deleted"] == 1 ? true : false
                : json["is_deleted"],
      );

  Map<String, dynamic> toMap() => {
        'mob_id': mobID,
        'id': id,
        'acc_id': accID,
        'code': code,
        'name': name,
        "is_deleted": isDeleted == null ? 0 : isDeleted ? 1 : 0,
      };

  static Future<bool> sync() async {
    Currency currency;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/currency';

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

        for (var jsonCurrency in jsonData) {
          currency = Currency.fromMap(jsonCurrency);

          Currency existCurrency = await CurrencyDAO().getByID(currency.id);

          if (existCurrency != null) {
            currency.mobID = existCurrency.mobID;
            CurrencyDAO().update(currency);
          } else {
            if (!currency.isDeleted) {
              CurrencyDAO().insert(currency);
            }
          }
        }
        return true;
      } else {
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error",
        );
        return false;
      }
    } catch (e, s){
      FLog.error(
        exception: Exception(e.toString()),
        text: "try block error",
        stacktrace: s,
      );
      return false;
    }
  }
}
