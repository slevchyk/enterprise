import 'dart:io';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/route_generator.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(EnterpriseApp());

class EnterpriseApp extends StatefulWidget {
  _EnterpriseAppState createState() => _EnterpriseAppState();

  static Future<bool> checkInternet({bool showSnackBar, GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        if(showSnackBar!=null && scaffoldKey!=null && showSnackBar){
          ShowSnackBar.show(scaffoldKey, "Інтернет з'єднання відсутнє", Colors.red, duration: Duration(seconds: 1));
        }
        return false;
      }
    } on SocketException catch (_) {
      if(showSnackBar!=null && scaffoldKey!=null && showSnackBar){
        ShowSnackBar.show(scaffoldKey, "Інтернет з'єднання відсутнє", Colors.red, duration: Duration(seconds: 1));
      }
      return false;
    }
  }

  static deleteApplicationFileDir() async {
    Directory _externalFileDir = Directory(APPLICATION_FILE_PATH);
    if(_externalFileDir.existsSync()){
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      _externalFileDir.deleteSync(recursive: true);
    }
  }

  static deleteSelectedDir(Directory dir) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if(dir.existsSync()){
      dir.deleteSync(recursive: true);
    }
    dir.createSync(recursive: true);
  }

  static createApplicationFileDir({String action, GlobalKey<ScaffoldState> scaffoldKey}) async {
    Directory _externalFileDir = Directory(APPLICATION_FILE_PATH);
    if(!_externalFileDir.existsSync()){
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      _externalFileDir.createSync();
    }
    if(action!=null){
      switch (action) {
        case "pay_desk":
          Directory _payDeskImageDir = Directory(APPLICATION_FILE_PATH_PAY_DESK_IMAGE);
          if(!_payDeskImageDir.existsSync()){
            var status = await Permission.storage.status;
            switch (status){
              case PermissionStatus.undetermined:
                await Permission.storage.request();
                break;
              case PermissionStatus.granted:
                await Permission.storage.request();
                break;
              case PermissionStatus.denied:
                if(scaffoldKey==null){
                  return;
                }
                await Permission.storage.request();
                ShowSnackBar.show(scaffoldKey, "Надайте доступ на запис файлів в дозволах додатку ", Colors.red, duration: Duration(seconds: 2));
                break;
              case PermissionStatus.restricted:
                if(scaffoldKey==null){
                  return;
                }
                await Permission.storage.request();
                ShowSnackBar.show(scaffoldKey, "Надайте доступ на запис файлів в дозволах додатку ", Colors.red, duration: Duration(seconds: 2));
                break;
              case PermissionStatus.permanentlyDenied:
                if(scaffoldKey==null){
                  return;
                }
                await Permission.storage.request();
                ShowSnackBar.show(scaffoldKey, "Надайте доступ на запис файлів в дозволах додатку ", Colors.red, duration: Duration(seconds: 2));
                break;
            }
            _payDeskImageDir.createSync();
            Directory _noMedia = Directory("${_payDeskImageDir.path}/.nomedia");
            _noMedia.createSync();
            return;
          }
          Directory _noMedia = Directory("${_payDeskImageDir.path}/.nomedia");
          if(!_noMedia.existsSync()){
            _noMedia.createSync();
          }
          break;
      }
    }
  }
}

class _EnterpriseAppState extends State<EnterpriseApp> {
  @override
  void initState() {
    super.initState();
    EnterpriseApp.createApplicationFileDir();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        primaryColorDark: Colors.grey.shade700,
        primaryColor: Colors.grey.shade600,
        primaryColorLight: Colors.grey.shade100,
        accentColor: Colors.lightGreen.shade700,
        dividerColor: Colors.grey.shade400,
      ),
    );
  }

}
