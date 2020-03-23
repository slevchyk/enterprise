import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/paydesk_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

class PayDesk {
  int mobID;
  int id;
  String userID;
  int paymentStatus;
  double amount;
  String payment;
  String documentNumber;
  DateTime documentDate;
  String files;
  int filesQuantity;
  DateTime createdAt;
  DateTime updatedAt;
  bool isModified;

  PayDesk({
    this.mobID,
    this.id,
    this.userID,
    this.paymentStatus,
    this.amount,
    this.payment,
    this.documentNumber,
    this.documentDate,
    this.files,
    this.filesQuantity,
    this.createdAt,
    this.updatedAt,
    this.isModified,
  });

  factory PayDesk.fromMap(Map<String, dynamic> json) => PayDesk(
        mobID: json['mob_id'],
        id: json['id'],
        userID: json['user_id'],
        paymentStatus: json['payment_status'],
        amount: json["amount"] is double
            ? json["amount"]
            : json["amount"].toDouble(),
        payment: json["payment"],
        documentNumber: json["document_number"],
        documentDate: json['document_date'] != null
            ? DateTime.parse(json["document_date"])
            : null,
        files: json['files'],
        filesQuantity: json['files_quantity'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        isModified: json["is_modified"] == 1 ? true : false,
      );

  Map<String, dynamic> toMap() => {
        'mob_id': mobID,
        'id': id,
        'user_id': userID,
        'payment_status': paymentStatus,
        'amount': amount,
        'payment': payment,
        'document_number': documentNumber,
        'document_date':
            documentDate != null ? documentDate.toIso8601String() : null,
        'files': files,
        'files_quantity': filesQuantity,
        'created_at': createdAt != null ? createdAt.toIso8601String() : null,
        'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
        "is_modified": isModified ? 1 : 0,
      };

  static sync() async {
    await upload();
    await download();
  }

  static upload() async {
    List<PayDesk> _listPayDesks = await PayDeskDAO().getToUpload();
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

    for (var _payDesk in _listPayDesks) {
      requestData = _payDesk.toMap();

      Response response = await post(
        url,
        headers: headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        _payDesk.id = jsonData["id"];

        PayDeskDAO().update(_payDesk, isModified: false);
      }
    }
  }

  static download() async {
    PayDesk payDesk;
    Map<String, dynamic> requestData;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/paydesk?for=mobile';

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

      for (var jsonPayDesk in jsonData) {
        payDesk = PayDesk.fromMap(jsonPayDesk);

        bool ok = false;

        PayDesk existPayDesk = await PayDeskDAO().getByID(payDesk.id);

        if (existPayDesk != null) {
          ok = await PayDeskDAO().update(payDesk, isModified: false);
        } else {
          int mobID = PayDeskDAO().insert(payDesk, isModified: false);
          if (mobID != null) {
            ok = true;
          }
        }

        if (ok) {
          String urlProcessed =
              'http://$_serverIP/api/paydesk/processed?from=mobile&id=${payDesk.id.toString()}';
          post(urlProcessed, headers: headers);
        }
      }
    }
  }
}
