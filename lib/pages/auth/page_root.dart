import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:enterprise/database/core.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class PageRoot extends StatefulWidget {
  @override
  _PageRootState createState() => _PageRootState();
}

class _PageRootState extends State<PageRoot> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initState());
  }

  Future<Map<String, String>> _mapDeviceNameAndModel() async {
    DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> _deviceData;
    try {
      if (Platform.isAndroid) {
        _deviceData = _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      _deviceData = <String, String>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return _deviceData;
  }

  Map<String, String> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, String>{
      'name': build.brand,
      'model': build.model,
      'id' : build.androidId,
    };
  }

  Map<String, String> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, String>{
      'name': data.name,
      'model': data.model,
      'id' : data.identifierForVendor,
    };
  }

  _initState() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    bool _isProtectionEnabled =
        prefs.getBool(KEY_IS_PROTECTION_ENABLED) ?? false;

    if (_userID != "") {
      Profile profile = await ProfileDAO().getByUserId(_userID);

      Map<String, String> _phoneInfo = await _mapDeviceNameAndModel();

      final mainSrvIP = SERVER_IP;
      final mainSrvUsername = SERVER_USER;
      final mainSrvPassword = SERVER_PASSWORD;

      final credentials = '$mainSrvUsername:$mainSrvPassword';
      final stringToBase64 = utf8.fuse(base64);
      final encodedCredentials = stringToBase64.encode(credentials);

      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
        HttpHeaders.contentTypeHeader: "application/json",
      };

      String url = 'http://$mainSrvIP/api/access';

      Map<String, String> requestMap = {
        "user_imei" : _phoneInfo["id"]!= null ? _phoneInfo["id"] : " ",
      };

      String requestJSON = json.encode(requestMap);

      try {
        Response response = await post(url, headers: headers, body: requestJSON);
        if (response.statusCode==200){
          if(response.body=="false"){
            Navigator.of(context).pushReplacementNamed(
              "/sign_in_out",
              arguments: "",
            );
            DBProvider.db.deleteDB();
            EnterpriseApp.deleteApplicationFileDir();
            prefs.clear();
            return;
          }
        }
      } catch (e, s){
        FLog.error(
          exception: Exception(e.toString()),
          text: "response error",
          stacktrace: s,
        );
      }


      if (profile != null) {
        RouteArgs args = RouteArgs(profile: profile);

        if (_isProtectionEnabled) {
          Navigator.of(context).pushReplacementNamed(
            "/auth",
            arguments: args,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
            "/home",
            arguments: args,
          );
        }
      } else {
        Navigator.of(context).pushReplacementNamed(
          "/sign_in_out",
          arguments: "",
        );
      }
    } else {
      Navigator.of(context).pushReplacementNamed(
        "/sign_in_out",
        arguments: "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
