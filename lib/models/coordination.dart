import 'dart:convert';
import 'dart:io';

import 'package:enterprise/models/constants.dart';
import 'package:http/http.dart';

class Coordination{
  String iD;
  String name;
  DateTime date;

  Coordination({
    this.iD,
    this.name,
    this.date,
  });

  factory Coordination.fromMap(Map<String, dynamic> json) => Coordination(
    iD: json["id"],
    name: json["name"],
    date: json["date"] != null ? DateTime.parse(json["date"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id" : iD,
    "name" : name,
    "date" : date != null ? date.toIso8601String() : null,
  };

  static Future<List<Coordination>> getCoordinationList() async {
    Coordination coordination;

    List<Coordination> toReturn = [];

    final String _urlToken = "https://api.quickshop.in.ua/test_bk/hs/mobileApi/login";
    final String _urlGetTask = "https://api.quickshop.in.ua/test_bk/hs/mobileApi/getTask/";
    final String _token = await _getToken(_urlToken);

    try{
      if(_token==null){
        print('no token');
        return null;
      }

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
         toReturn.add(coordination);
       }
       return toReturn;
     } else {
       return null;
     }
   } catch (e) {
     print(e);
     return null;
    }
  }

  static Future<String> _getToken(String url) async {
    final String _apiUser = API_USER;
    final String _apiPassword = API_PASSWORD;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Map<String, String> body = {
      "email" : _apiUser,
      "password" : _apiPassword,
    };

    try{
      Response response = await post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return response.body.split(":").last.replaceAll('"', "").replaceAll("}", "");
      } else {
        print('error code ${response.statusCode}');
        return null;
      }
    } catch (e){
      print(e);
      return null;
    }
  }
}