import 'dart:convert';
import 'dart:io';

import 'package:enterprise/database/pay_office_dao.dart';
import 'package:enterprise/database/user_grants_dao.dart';
import 'package:enterprise/models/pay_office_balance.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:f_logs/f_logs.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'constants.dart';

class PayOffice {
  int mobID;
  int id;
  double amount;
  String accID;
  String currencyAccID;
  String name;
  String currencyName;
  DateTime updatedAt;
  bool isDeleted;
  bool isVisible;
  bool isAvailable;
  bool isReceiver;
  bool isShow;

  PayOffice({
    this.mobID,
    this.id,
    this.amount,
    this.accID,
    this.currencyAccID,
    this.name,
    this.currencyName,
    this.updatedAt,
    this.isDeleted,
    this.isVisible,
    this.isAvailable,
    this.isReceiver,
    this.isShow = true,
  });

  factory PayOffice.fromMap(Map<String, dynamic> json) => PayOffice(
        mobID: json["mob_id"],
        id: json["id"],
        amount: json["amount"] != null ? json["amount"].toDouble() : 0.00,
        accID: json["acc_id"],
        currencyAccID: json["currency_acc_id"],
        name: json["name"],
        isDeleted: json["is_deleted"] == null
            ? false
            : json["is_deleted"] is int
                ? json["is_deleted"] == 1 ? true : false
                : json["is_deleted"],
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
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'mob_id': mobID,
        'id': id,
        'amount' : amount,
        'acc_id': accID,
        'currency_acc_id': currencyAccID,
        'name': name,
        "is_deleted": isDeleted == null ? 0 : isDeleted ? 1 : 0,
        "is_visible" : isVisible == null ? 0 : isVisible ? 1 : 0,
        "is_available" : isAvailable == null ? 0 : isAvailable ? 1 : 0,
        "is_receiver" : isReceiver == null ? 0 : isReceiver ? 1 : 0,
        'updated_at' : updatedAt != null ? updatedAt.toIso8601String() : null,
      };

  static sync() async {
    if(!await EnterpriseApp.checkInternet()){
      return;
    }
    PayOffice payOffice;

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/payoffices';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try{
      Response response = await get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData == null) {
          return;
        }

        List<UserGrants> _listUserGrants = await UserGrantsDAO().getAll();
        List<PayOfficeBalance> _listPayOfficeBalance = await PayOfficeBalance.sync();

        for (var jsonPayOffice in jsonData) {
          payOffice = PayOffice.fromMap(jsonPayOffice);

          List<UserGrants> _currentUserGrants = _listUserGrants
              .where((userGrant) => userGrant.objectAccID == payOffice.accID)
              .toList();

          List<PayOfficeBalance> _currentPayOfficeBalance = _listPayOfficeBalance
              .where((payOfficeBalance) => payOfficeBalance.accID == payOffice.accID)
              .toList();

          PayOffice existPayOffice = await PayOfficeDAO().getByID(payOffice.id);

          if(_currentUserGrants.length!=0){
            if(_currentPayOfficeBalance.length!=0){
              payOffice.amount = _currentPayOfficeBalance.first.balance;
              payOffice.updatedAt = _currentPayOfficeBalance.first.updatedAt;
            }
            payOffice.isVisible = _currentUserGrants.first.isVisible;
            payOffice.isAvailable = _currentUserGrants.first.isAvailable;
            payOffice.isReceiver = _currentUserGrants.first.isReceiver;

            if (existPayOffice != null) {
              payOffice.mobID = existPayOffice.mobID;
              PayOfficeDAO().update(payOffice);
            } else if (!payOffice.isDeleted){
              PayOfficeDAO().insert(payOffice);
            }

            if(payOffice.isVisible){
              PayDesk.downloadByPayOfficeID(payOffice.accID);
            }

          } else if(existPayOffice != null) {
            PayOfficeDAO().delete(existPayOffice);
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
}
