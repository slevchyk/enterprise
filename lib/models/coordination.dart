import 'dart:convert';
import 'dart:io';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../main.dart';

class Coordination{
  String id;
  String name;
  String url;
  DateTime date;
  CoordinationTypes status;
  static String _token;

  Coordination({
    this.id,
    this.name,
    this.url,
    this.date,
    this.status,
  });

  factory Coordination.fromMap(Map<String, dynamic> json) => Coordination(
    id: json["id"],
    name: json["name"],
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    status: json["status"] != null ? _setType(json["status"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id" : id,
    "name" : name,
    "date" : date != null ? date.toIso8601String() : null,
    "status" : status,
  };

  static CoordinationTypes _setType(String input){
    switch (input){
      case "none":
        return CoordinationTypes.none;
      case "approved":
        return CoordinationTypes.approved;
      case "reject":
        return CoordinationTypes.reject;
      default:
        return CoordinationTypes.none;
    }
  }


  static Future<String> get token async {
    if(_token==null){
      _token = await _getToken();
    }
    return _token;
  }

  static Future<List<Coordination>> getCoordinationList(GlobalKey<ScaffoldState> scaffoldKey) async {
    if(!await EnterpriseApp.checkInternet(showSnackBar: true, scaffoldKey: scaffoldKey)){
      return null;
    }
    Coordination coordination;

    List<Coordination> toReturn = [];

    final String _urlGetTask = "https://bot.barkom.ua/test/hs/mobileApi/getTask/";
    final String _token = await token;
    try{
      Response response = await get(
       _urlGetTask,
       headers: {
         "Content-Type" : "application/json; charset=utf-8",
         "Accept-Charset" :  "utf-8",
         "Token" : "$_token",
       },
     );

     if (response.statusCode == 200) {
       var jsonData = json.decode(response.body);

       if (jsonData == null) {
         return null;
       }

       for (var jsonCostItem in jsonData) {
         coordination = Coordination.fromMap(jsonCostItem);
         coordination.url = "https://bot.barkom.ua/test/hs/mobileApi/getDoc?docType=price&docID=${coordination.id}";
         toReturn.add(coordination);
       }
       ShowSnackBar.show(scaffoldKey, "Данi оновлено", Colors.green);
       return toReturn;
     } else {
       FLog.error(
         exception: Exception(response.statusCode),
         text: "status code error, with token $_token}",
       );
       ShowSnackBar.show(scaffoldKey, "Помилка оновлення даних", Colors.orange);
       return null;
     }
   } catch (e, s) {
     FLog.error(
       exception: Exception(e.toString()),
       text: "response error",
       stacktrace: s,
     );
     ShowSnackBar.show(scaffoldKey, "Помилка оновлення даних", Colors.orange);
     return null;
    }
  }

  static Future<String> _getToken() async {
    final String _apiUser = API_USER;
    final String _apiPassword = API_PASSWORD;
    final String _url = API_URL_TOKEN;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Map<String, String> body = {
      "email" : _apiUser,
      "password" : _apiPassword,
    };

    try{
      Response response = await post(
        _url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        FLog.info(
          text: "Token received ${jsonData["token"]}",
        );
        return jsonData["token"];
      } else {
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error",
        );
        return null;
      }
    } catch (e, s){
      FLog.error(
        exception: Exception(e.toString()),
        text: "response error",
        stacktrace: s,
      );
      return null;
    }
  }
}