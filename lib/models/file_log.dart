import 'dart:convert';
import 'dart:io';

import 'package:enterprise/main.dart';
import 'package:enterprise/models/constants.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileLog {
  String userID;
  String fileName;
  String file;
  DateTime date;

  FileLog({
    this.userID,
    this.fileName,
    this.file,
    this.date
  });

  Map<String, dynamic> toMap() => {
    "user_id" : userID,
    "file_name" : fileName,
    "file" : file,
    "date" : date != null ? date.toIso8601String() : null,
  };

  static Future<bool> uploadLogFile(FileLog fileLog) async {
    if(!await EnterpriseApp.checkInternet()){
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/upload?type=log';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Map<String, dynamic> body = fileLog.toMap();

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
        return false;
      }
      return true;
    } catch (e, s){
      FLog.error(
        exception: Exception(e.toString()),
        text: "response error",
        stacktrace: s,
      );
      return false;
    }
  }

}