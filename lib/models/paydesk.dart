import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:f_logs/f_logs.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class PayDesk {
  int mobID;
  int id;
  int payDeskType;
  String costItemAccID;
  String incomeItemAccID;
  String fromPayOfficeAccID;
  String toPayOfficeAccID;
  String userID;
  double amount;
  String currencyAccID;
  String payment;
  String documentNumber;
  DateTime documentDate;
  String filePaths;
  int filesQuantity;
  bool isChecked = false;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  bool isModified;
  int currencyCode;
  String costItemName;
  String incomeItemName;
  String fromPayOfficeName;
  String toPayOfficeName;
  double percentage;

  PayDesk({
    this.mobID,
    this.id,
    this.payDeskType,
    this.costItemAccID,
    this.incomeItemAccID,
    this.fromPayOfficeAccID,
    this.toPayOfficeAccID,
    this.userID,
    this.amount,
    this.currencyAccID,
    this.payment,
    this.documentNumber,
    this.documentDate,
    this.filePaths,
    this.filesQuantity,
    this.isChecked,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.isModified,
    this.currencyCode,
    this.costItemName,
    this.incomeItemName,
    this.fromPayOfficeName,
    this.toPayOfficeName,
    this.percentage,
  });

  factory PayDesk.fromMap(Map<String, dynamic> json) => PayDesk(
        mobID: json['mob_id'],
        id: json['id'],
        payDeskType: json['pay_desk_type'],
        currencyAccID: json["currency_acc_id"],
        costItemAccID: json['cost_item_acc_id'],
        incomeItemAccID: json['income_item_acc_id'],
        fromPayOfficeAccID: json['from_pay_office_acc_id'],
        toPayOfficeAccID: json['to_pay_office_acc_id'],
        userID: json['user_id'],
        amount: json["amount"] is double ? json["amount"] : json["amount"].toDouble(),
        payment: json["payment"],
        documentNumber: json["document_number"],
        documentDate: json['document_date'] != null ? DateTime.parse(json["document_date"]) : null,
        filePaths: json['file_paths'],
        filesQuantity: json['files_quantity'],
        isChecked: json["is_checked"] == null
            ? false
            : json["is_checked"] is int ? json["is_checked"] == 1 ? true : false : json["is_checked"],
        createdAt: json['created_at'] != null ? DateTime.parse(json["created_at"]) : null,
        updatedAt: json['updated_at'] != null ? DateTime.parse(json["updated_at"]) : null,
        isDeleted: json["is_deleted"] == null
            ? false
            : json["is_deleted"] is int ? json["is_deleted"] == 1 ? true : false : json["is_deleted"],
        isModified: json["is_modified"] == null
            ? false
            : json["is_modified"] is int ? json["is_modified"] == 1 ? true : false : json["is_modified"],
        currencyCode: json["currency_code"],
        costItemName: json["cost_item_name"],
        incomeItemName: json["income_item_name"],
        fromPayOfficeName: json["from_pay_office_name"],
        toPayOfficeName: json["to_pay_office_name"],
      );

  Map<String, dynamic> toMap() => {
        'mob_id': mobID,
        'id': id,
        'pay_desk_type': payDeskType,
        'currency_acc_id': currencyAccID,
        'cost_item_acc_id': costItemAccID,
        'income_item_acc_id': incomeItemAccID,
        'from_pay_office_acc_id': fromPayOfficeAccID,
        'to_pay_office_acc_id': toPayOfficeAccID,
        'user_id': userID,
        'amount': amount,
        'payment': payment,
        'document_number': documentNumber,
        'document_date': documentDate != null ? documentDate.toIso8601String() : null,
        'file_paths': filePaths,
        'files_quantity': filesQuantity,
        'is_checked': isChecked == null ? 0 : isChecked ? 1 : 0,
        'created_at': createdAt != null ? createdAt.toIso8601String() : null,
        'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
        "is_deleted": isDeleted == null ? 0 : isDeleted ? 1 : 0,
        "is_modified": isModified == null ? 0 : isModified ? 1 : 0,
      };

  static sync() async {
    await upload();
    await download();
  }

  static Future<bool> downloadAll() async {
    PayDesk payDesk;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _userID = prefs.getString(KEY_USER_ID) ?? "";

    final String url = 'http://$_serverIP/api/paydesk?user_id=$_userID';

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

        for (var jsonPayDesk in jsonData) {
          payDesk = PayDesk.fromMap(jsonPayDesk);

          PayDesk existPayDesk = await PayDeskDAO().getByID(payDesk.id);

          if (existPayDesk != null) {
            payDesk.mobID = existPayDesk.mobID;
            payDesk.filePaths = existPayDesk.filePaths;
            payDesk.filesQuantity = existPayDesk.filesQuantity;
            PayDeskDAO().update(payDesk, isModified: false);
          } else {
            PayDeskDAO().insert(payDesk, isModified: false);
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

     try{
       Response response = await post(
         url,
         headers: headers,
         body: json.encode(requestData),
       );

       if (response.statusCode == 200) {
         if (_payDesk.id == null) {
           Map<String, dynamic> jsonData = json.decode(response.body);
           _payDesk.id = jsonData["id"];
         }

         PayDeskDAO().update(_payDesk, isModified: false);
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
     }
    }
  }

  static download() async {
    PayDesk payDesk;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _userID = prefs.getString(KEY_USER_ID) ?? "";

    final String url = 'http://$_serverIP/api/paydesk?for=mobile&userid=$_userID';

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
          return;
        }

        for (var jsonPayDesk in jsonData) {
          payDesk = PayDesk.fromMap(jsonPayDesk);

          bool ok = false;

          PayDesk existPayDesk = await PayDeskDAO().getByID(payDesk.id);

          if (existPayDesk != null) {
            payDesk.mobID = existPayDesk.mobID;
            payDesk.filePaths = existPayDesk.filePaths;
            payDesk.filesQuantity = existPayDesk.filesQuantity;
            ok = await PayDeskDAO().update(payDesk, isModified: false);
          } else {
            int mobID = await PayDeskDAO().insert(payDesk, isModified: false);

            if (mobID != null) {
              ok = true;
            }
          }

          if (ok) {
            String urlProcessed = 'http://$_serverIP/api/paydesk/processed?from=mobile&id=${payDesk.id.toString()}';
            post(urlProcessed, headers: headers);
          }
        }
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
    }
  }
}
