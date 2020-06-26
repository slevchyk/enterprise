import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/cost_item_dao.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class CostItem {
  int mobID;
  int id;
  String accID;
  String name;
  bool isDeleted;

  CostItem({
    this.mobID,
    this.id,
    this.accID,
    this.name,
    this.isDeleted,
  });

  factory CostItem.fromMap(Map<String, dynamic> json) => CostItem(
        mobID: json["mob_id"],
        id: json["id"],
        accID: json["acc_id"],
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
        'name': name,
        "is_deleted": isDeleted == null ? 0 : isDeleted ? 1 : 0,
      };

  static sync() async {
    CostItem costItem;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/costitems';

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

      for (var jsonCostItem in jsonData) {
        costItem = CostItem.fromMap(jsonCostItem);

        CostItem existCostItem = await CostItemDAO().getByID(costItem.id);

        if (existCostItem != null) {
          costItem.mobID = existCostItem.mobID;
          CostItemDAO().update(costItem);
        } else {
          if (!costItem.isDeleted) {
            CostItemDAO().insert(costItem);
          }
        }
      }
    }
  }
}
