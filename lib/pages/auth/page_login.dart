import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class PageSignInOut extends StatefulWidget {
  @override
  _PageSignInOutState createState() => _PageSignInOutState();
}

class _PageSignInOutState extends State<PageSignInOut> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userPhoneController = TextEditingController();
  final _userPinController = TextEditingController();
  final MaskTextInputFormatter maskTextInputFormatter =
  MaskTextInputFormatter(mask: '## ### ####', filter: { "#": RegExp(r'[0-9]') });

  @override
  void initState() {
    super.initState();
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Widget signInOutDebug() {
    if (this.isInDebugMode) {
      return FlatButton(
        onPressed: () {
          RouteArgs _args = RouteArgs();
          Navigator.of(context).pushNamed("/home", arguments: _args);
        },
        child: Text('Продовжити. debug'),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                child: Image.asset("assets/logo_512.png"),
                minRadius: 25,
                maxRadius: 50,
                backgroundColor: Colors.white,
              ),
              TextFormField(
                autofocus: true,
                controller: _userPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Номер телефону",
                    prefixStyle: TextStyle(color: Colors.black, fontSize: 16),
                    prefixText: "+38 0",
                    icon: Icon(Icons.phone)),
                inputFormatters: [
                  maskTextInputFormatter,
                ],
                validator: (value) {
                  if (value.isEmpty) {
                    return "ви не вказали номер телефону";
                  } else if (!maskTextInputFormatter.isFill()) {
                    return "невірний формат";
                  }
                  return null;
                },
              ),
              TextFormField(
                  controller: _userPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "PIN",
                    hintText: "пін код карти перепустки",
                    icon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "ви не вказали секретний pin";
                    }
                    return null;
                  }),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Увійти'),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _getLocalServerSettingsProfile(_scaffoldKey);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  signInOutDebug(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
    };
  }

  Map<String, String> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, String>{
      'name': data.name,
      'model': data.model,
    };
  }

  void _getLocalServerSettingsProfile(
      GlobalKey<ScaffoldState> _scaffoldKey) async {
    if(!await EnterpriseApp.checkInternet(showSnackBar: true, scaffoldKey: _scaffoldKey)){
      return;
    }

    Map<String, String> _phoneInfo = await _mapDeviceNameAndModel();

    final String _imei = await ImeiPlugin.getImei();

    Map<String, String> requestMap = {
      "phone" : "+380${maskTextInputFormatter.getUnmaskedText()}",
      "pin" : _userPinController.text,
      "name" : _phoneInfo["name"] != null ? _phoneInfo["name"] : " ",
      "model" : _phoneInfo["model"] != null ? _phoneInfo["model"] : " ",
      "imei" : _imei,
    };


    String requestJSON = json.encode(requestMap);

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

    String url = 'http://$mainSrvIP/api/getdbsettings';

    try{
      Response response = await post(url, headers: headers, body: requestJSON);

      String body = response.body;

      if (response.statusCode == 200) {
        Map<String, dynamic> responseJSON = json.decode(body);

        final String localSrvIP = responseJSON["srv_ip"];
        final String localSrvUser = responseJSON["srv_user"];
        final String localSrvPassword = responseJSON["srv_password"];

        final prefs = await SharedPreferences.getInstance();

        prefs.setString(KEY_USER_PHONE, "+380${maskTextInputFormatter.getUnmaskedText()}");
        prefs.setString(KEY_USER_PIN, _userPinController.text);

        prefs.setString(KEY_SERVER_IP, localSrvIP);
        prefs.setString(KEY_SERVER_USER, localSrvUser);
        prefs.setString(KEY_SERVER_PASSWORD, localSrvPassword);

        Profile _profile = await Profile.downloadByPhonePin(_scaffoldKey);

        if (_profile != null) {
          if (_profile.userID != "") {
            RouteArgs args = RouteArgs(profile: _profile);

            prefs.setString(KEY_USER_ID, _profile.userID);
            FLog.info(
                text: "login user ${_profile.userID}"
            );
            Navigator.of(context).pushReplacementNamed(
              '/',
              arguments: args,
            );
          }
        }

        return;
      }

      switch (response.statusCode){
        case 400:
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error, incorrect parameters licence server $body",
          );
          ShowSnackBar.show(_scaffoldKey, 'Невірні параметри сервера ліцензування\n$body', Colors.redAccent);
          return;
        case 401:
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error, error licence server $body",
          );
          ShowSnackBar.show(_scaffoldKey, 'Помилка сервера сервера ліцензування:\n$body', Colors.redAccent);
          return;
        case 404:
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error, not found user on licence server with this parameters",
          );
          ShowSnackBar.show(_scaffoldKey, 'Не знайдено обілковий запис сервера ліцензування з такими параметрами', Colors.redAccent);
          return;
        case 406:
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error, not found user on licence server with this parameters",
          );
          ShowSnackBar.show(_scaffoldKey, 'Невірні параметри сервера ліцензування, доступ вiдхилено', Colors.redAccent);
          return;
        case 500:
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error, error licence server $body",
          );
          ShowSnackBar.show(_scaffoldKey, 'Помилка сервера ліцензування:\n$body', Colors.redAccent);
          return;
        default:
          FLog.error(
            exception: Exception(response.statusCode),
            text: "status code error, can't get settings from licence server",
          );
          ShowSnackBar.show(_scaffoldKey, 'Не вдалось отримати налаштування сервера ліцензування', Colors.redAccent);
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

singInOutDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ви дійсно бажаєте вийти?"),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ні"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Так"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                FLog.info(
                    text: "logout user ${prefs.getString(KEY_USER_ID)}"
                );
                prefs.setString(KEY_USER_ID, "");
                DBProvider.db.deleteDB();
                EnterpriseApp.deleteApplicationFileDir();

                Navigator.of(context).pushNamedAndRemoveUntil("/sign_in_out", (Route<dynamic> route) => false);
              },
            )
          ],
        );
      });
}
