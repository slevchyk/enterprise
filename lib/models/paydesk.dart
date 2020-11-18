import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/database/pay_desk_image_dao.dart';
import 'package:enterprise/models/paydesk_image.dart';
import 'package:enterprise/models/sha256_check.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
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
  int filesQuantity;
  bool isChecked = false;
  bool isReadOnly = false;
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
    this.filesQuantity,
    this.isChecked,
    this.isReadOnly,
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
        filesQuantity: json['files_quantity'],
        isChecked: json["is_checked"] == null
            ? false
            : json["is_checked"] is int ? json["is_checked"] == 1 ? true : false : json["is_checked"],
        isReadOnly: json["is_read_only"] == null
            ? false
            : json["is_read_only"] is int ? json["is_read_only"] == 1 ? true : false : json["is_read_only"],
        createdAt: json['created_at'] != null ? DateTime.parse(json["created_at"]) : json['document_date'] != null ? DateTime.parse(json["document_date"]) : null,
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
        'files_quantity': filesQuantity,
        'is_checked': isChecked == null ? 0 : isChecked ? 1 : 0,
        'is_read_only' : isReadOnly == null ? 0 : isReadOnly ? 1 : 0,
        'created_at': createdAt != null ? createdAt.toIso8601String() : null,
        'updated_at': updatedAt != null ? updatedAt.toIso8601String() : null,
        "is_deleted": isDeleted == null ? 0 : isDeleted ? 1 : 0,
        "is_modified": isModified == null ? 0 : isModified ? 1 : 0,
      };

  // static Future<bool> downloadAll(String id) async {
  //   PayDesk payDesk;
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
  //   final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
  //   final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
  //
  //   final String url = 'http://$_serverIP/api/paydesk?pay_office_id=$id';
  //
  //   final credentials = '$_serverUser:$_serverPassword';
  //   final stringToBase64 = utf8.fuse(base64);
  //   final encodedCredentials = stringToBase64.encode(credentials);
  //
  //   Map<String, String> headers = {
  //     HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
  //     HttpHeaders.contentTypeHeader: "application/json",
  //   };
  //
  //   try {
  //     Response response = await get(
  //       url,
  //       headers: headers,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var jsonData = json.decode(response.body);
  //
  //       if (jsonData == null) {
  //         return true;
  //       }
  //
  //       for (var jsonPayDesk in jsonData) {
  //         payDesk = PayDesk.fromMap(jsonPayDesk);
  //
  //         PayDesk existPayDesk = await PayDeskDAO().getByID(payDesk.id);
  //
  //         if (existPayDesk != null) {
  //           payDesk.mobID = existPayDesk.mobID;
  //           payDesk.filePaths = existPayDesk.filePaths;
  //           payDesk.filesQuantity = existPayDesk.filesQuantity;
  //           PayDeskDAO().update(payDesk, isModified: false);
  //         } else {
  //           PayDeskDAO().insert(payDesk, isModified: false);
  //         }
  //       }
  //       return true;
  //     } else {
  //       FLog.error(
  //         exception: Exception(response.statusCode),
  //         text: "status code error",
  //       );
  //       return false;
  //     }
  //   } catch (e, s){
  //     FLog.error(
  //       exception: Exception(e.toString()),
  //       text: "response error",
  //       stacktrace: s,
  //     );
  //     return false;
  //   }
  // }

  static upload() async {
    if(!await EnterpriseApp.checkInternet()){
      return null;
    }
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
           int _id = jsonData["id"];
           _payDesk.id = _id;
         }

         List<PayDeskImage> _pdi = await PayDeskImageDAO().getByMobID(_payDesk.mobID);
         if(_pdi!=null){
           await PayDeskImageDAO().setPidByMobID(_payDesk.id, _pdi.first.mobID);
         }

         PayDeskDAO().update(_payDesk, isModified: false);
         uploadImages(_payDesk);
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
         text: "response error",
         stacktrace: s,
       );
     }
    }
  }

  static uploadImages(PayDesk payDesk) async {
    List<PayDeskImage> _listPayDeskImages = await PayDeskImageDAO().getByMobID(payDesk.mobID);

    if (payDesk.filesQuantity == null && _listPayDeskImages.isEmpty){
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/upload?type=paydesk';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Map<String, dynamic> body;

    for (PayDeskImage _image in _listPayDeskImages){
      File _fileWrite = File(_image.path);
      if(_image.isDeleted) {
        body = {
          "PID" : _image.pid,
          "image_name" : basename(_image.path),
          "is_deleted" : _image.isDeleted,
        };
      } else {
        body = {
          "PID" : _image.pid,
          "image_name" : basename(_image.path),
          "file" : _fileWrite.existsSync() ? base64Encode(_fileWrite.readAsBytesSync()) : null,
          "sha256" : _fileWrite.existsSync() ? (await sha256.bind(_fileWrite.openRead()).first).toString() : null,
          "is_deleted" : _image.isDeleted,
        };
      }

      try {
        Response response = await post(
          url,
          headers: headers,
          body: json.encode(body),
        );

        if (response.statusCode != 200) {
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error",
          );
          return;
        }
      } catch (e, s){
        FLog.error(
          exception: Exception(e.toString()),
          text: "response error",
          stacktrace: s,
        );
        return;
      }
    }
  }

  static Future<bool> downloadImagesByPdi(PayDesk payDesk, GlobalKey<ScaffoldState> scaffoldKey) async {
    if(!await EnterpriseApp.checkInternet()){
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/download?type=paydesk&pid=${payDesk.id}';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    await EnterpriseApp.createApplicationFileDir(action: "pay_desk", scaffoldKey: scaffoldKey);

    if(!await _checkImagesAndDir(headers, payDesk, _serverIP)){
      try {
        Response response = await get(
          url,
          headers: headers,
        );

        if (response.statusCode == 200) {

          var jsonData = json.decode(response.body);

          if (jsonData == null) {
            return false;
          }

          await PayDeskImageDAO().delete(payDesk.id);
          for (var data in jsonData){
            PayDeskImage _payDeskImage = PayDeskImage.fromMap(data);
            File _writeFile = File("$APPLICATION_FILE_PATH_PAY_DESK_IMAGE/${payDesk.mobID}/${_payDeskImage.imageName}");
            _payDeskImage.path = _writeFile.path;
            _payDeskImage.mobID = payDesk.mobID;
            PayDeskImageDAO().insert(_payDeskImage);
            _writeFile.writeAsBytes(base64Decode(data["file"]));
          }
          return true;
        } else {
          FLog.error(
            exception: Exception("${response.statusCode} with body ${response.body}"),
            text: "status code error",
          );
          return false;
        }

      } catch (e, s) {
        FLog.error(
          exception: Exception(e.toString()),
          text: "response error",
          stacktrace: s,
        );
        return false;
      }
    }
    return true;

  }

  static downloadByPayOfficeID(String id) async {
    if(!await EnterpriseApp.checkInternet()){
      return;
    }
    PayDesk payDesk;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/paydesk?pay_office_id=$id';

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
        text: "response error",
        stacktrace: s,
      );
    }
  }

  static Future<bool> _checkImagesAndDir(Map<String, String> headers, PayDesk pdi, String serverIP) async { //if return true all ok, else delete files and download again

    final String urlCheck = 'http://$serverIP/api/download?type=check&types=paydesk&pid=${pdi.id}';

    Directory _currentPayDeskDir = Directory("$APPLICATION_FILE_PATH_PAY_DESK_IMAGE/${pdi.mobID}");

    if(_currentPayDeskDir.existsSync()){
      try {
        Response response = await get(
          urlCheck,
          headers: headers,
        );

        if(response.statusCode==200){
          var jsonData = json.decode(response.body);
          List<FileSystemEntity> _listFileSystemEntity = _currentPayDeskDir.listSync();

          if(_listFileSystemEntity == null || jsonData == null){
            await EnterpriseApp.deleteSelectedDir(_currentPayDeskDir);
            return false;
          }
          if(_listFileSystemEntity.length == jsonData.length){
            for (var data in jsonData){
              Sha256Check _sha256check = Sha256Check.fromMap(data);
              var _where = _listFileSystemEntity.where((element) => basename(element.path) == _sha256check.imageName);
              if((await sha256.bind(File(_where.first.path).openRead()).first).toString() != _sha256check.sha256){
                await EnterpriseApp.deleteSelectedDir(_currentPayDeskDir);
                return false;
              }
            }
          } else {
            await EnterpriseApp.deleteSelectedDir(_currentPayDeskDir);
            return false;
          }
          return true;
        } else {
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error",
          );
          return false;
        }
      } catch (e, s) {
          FLog.error(
            exception: Exception(e.toString()),
            text: "response error",
            stacktrace: s,
          );
          return false;
        }
    } else {
      await EnterpriseApp.deleteSelectedDir(_currentPayDeskDir);
      return false;
    }
  }
}
