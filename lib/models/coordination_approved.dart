import 'dart:convert';

import 'package:enterprise/models/coordination.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../main.dart';

class CoordinationApproved {
  String id;
  String comment;
  bool result;

  CoordinationApproved({
    this.id,
    this.comment,
    this.result,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'comment': comment,
        'result': result,
      };

  static Future<bool> setResult(CoordinationApproved result,
      GlobalKey<ScaffoldState> scaffoldKey, String action) async {
    if (!await EnterpriseApp.checkInternet(
        showSnackBar: true, scaffoldKey: scaffoldKey)) {
      return false;
    }

    final String _urlConfirmTask =
        "https://bot.barkom.ua/test/hs/mobileApi/confirmTask/";
    final String _token = await Coordination.token;

    try {
      if (_token == null) {
        ShowSnackBar.show(
            scaffoldKey, "Помилка отримання токену", Colors.orange);
        FLog.error(
          exception: Exception("token exception"),
          text: "no token",
        );
        return false;
      }

      Response response = await post(
        _urlConfirmTask,
        headers: {
          "Content-Type": "application/json",
          "Token": "$_token",
        },
        body: json.encode(result.toMap()),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData == null) {
          ShowSnackBar.show(
              scaffoldKey, "Помилка погодження задачi", Colors.orange);
          FLog.error(
            exception: Exception("jsonData $jsonData"),
            text: "error in approved task",
          );
          return false;
        }

        ShowSnackBar.show(scaffoldKey, "Задачу $action", Colors.green,
            duration: Duration(seconds: 1));
        return jsonData["result"];
      } else {
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error with token $_token}",
        );
        ShowSnackBar.show(
            scaffoldKey, "Помилка погодження задачi", Colors.orange);
        return false;
      }
    } catch (e, s) {
      FLog.error(
        exception: Exception(e.toString()),
        text: "response error",
        stacktrace: s,
      );
      ShowSnackBar.show(
          scaffoldKey, "Помилка погодження задачi", Colors.orange);
      return false;
    }
  }
}
