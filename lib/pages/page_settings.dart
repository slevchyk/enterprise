import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageSettings extends StatefulWidget {
  final Profile profile;
  PageSettings({
    this.profile,
  });

  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool canCheckBiometrics = false;
  bool isProtectionEnabled = false;
  bool isBiometricProtectionEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAsync());
  }

  initAsync() async {
    bool _isProtectionEnabled = false;
    bool _isBiometricProtectionEnabled = false;
    bool _canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;

    final prefs = await SharedPreferences.getInstance();

    _isProtectionEnabled = prefs.getBool(KEY_IS_PROTECTION_ENABLED) ?? false;

    if (_canCheckBiometrics) {
      _isBiometricProtectionEnabled =
          prefs.getBool(KEY_IS_BIOMETRIC_PROTECTION_ENABLED) ?? false;
    } else {
      prefs.setBool(KEY_IS_BIOMETRIC_PROTECTION_ENABLED, false);
    }

    setState(() {
      canCheckBiometrics = _canCheckBiometrics;
      isProtectionEnabled = _isProtectionEnabled;
      isBiometricProtectionEnabled = _isBiometricProtectionEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Налаштування"),
      ),
      // Enable menu
      // drawer: AppDrawer(
      //   profile: widget.profile,
      // ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Захист',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              icon: Icon(Icons.dialpad),
                            ),
                            child: SwitchListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Захист додатку ПІН-кодом'),
                                  Text(
                                    isProtectionEnabled
                                        ? 'увімкнуто'
                                        : 'вимкнуто',
                                    style:
                                        TextStyle(color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              value: isProtectionEnabled,
                              onChanged: (bool value) async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                if (!value) {
                                  prefs.setBool(
                                      KEY_IS_BIOMETRIC_PROTECTION_ENABLED,
                                      value);
                                  prefs.setString(KEY_AUTH_PIN, "");
                                } else {
                                  String _authPin =
                                      prefs.getString(KEY_AUTH_PIN) ?? "";
                                  if (_authPin == "") {
                                    Navigator.of(context).pushNamed("/set_pin");
                                    return;
                                  }
                                }

                                prefs.setBool(KEY_IS_PROTECTION_ENABLED, value);

                                setState(() {
                                  isProtectionEnabled = value;
                                  if (!value) {
                                    isBiometricProtectionEnabled = value;
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                      FlatButton(
                          onPressed: null, child: Text('змінити ПІН-код')),
                      Visibility(
                        visible: canCheckBiometrics && isProtectionEnabled,
                        child: FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                icon: Icon(Icons.fingerprint),
                              ),
                              child: SwitchListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          'Захист додатку відбитком пальця ци розпізнаванням обличчя'),
                                      Text(
                                        isBiometricProtectionEnabled
                                            ? 'увімкнуто'
                                            : 'вимкнуто',
                                        style: TextStyle(
                                            color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                  value: isBiometricProtectionEnabled,
                                  onChanged: (bool value) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool(
                                        KEY_IS_BIOMETRIC_PROTECTION_ENABLED,
                                        value);

                                    setState(() {
                                      isBiometricProtectionEnabled = value;
                                    });
                                  }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Лог-файл',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 5),
                  child: Text("Лог-файл - це файли, які містять системну інформацію про роботу телефона та певні дії користувача або програми.", style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.black, width: 0.2),
                        ),
                        color: Colors.grey[200],
                        onPressed: () async {
                          try {
                            FLog.clearLogs();
                            final _dir = await getExternalStorageDirectory();
                            File _logFile = File("${_dir.path}/FLogs/flog.txt");
                            if(_logFile.existsSync()){
                              _logFile.deleteSync();
                            }
                            ShowSnackBar.show(_scaffoldKey, "Лог видалено", Colors.green);
                          } catch (e, s) {
                            FLog.error(
                              exception: Exception(e.toString()),
                              text: "Error while deleting logs",
                              stacktrace: s,
                            );
                          }
                        },
                        child: Text("Очистити лог-файл", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.black, width: 0.2),
                        ),
                        color: Colors.grey[200],
                        onPressed: () async {
                          try {
                            final _dir = await getExternalStorageDirectory();
                            FLog.info(
                              className: "Device info",
                              methodName: "Device info",
                              text: await _getDeviceInfo(),
                            );
                            FLog.exportLogs();
                            if(await _sendLogFile("${_dir.path}/FLogs/flog.txt")){
                              ShowSnackBar.show(_scaffoldKey, "Лог відправлений", Colors.green);
                            } else {
                              ShowSnackBar.show(_scaffoldKey, "Помилка при вiдправленнi лога", Colors.orange);
                            }
                          } catch (e, s) {
                            FLog.error(
                              exception: Exception(e.toString()),
                              text: "Error while sending log file",
                              stacktrace: s,
                            );
                          }
                        },
                        child: Text("Вiдправити лог-файл", maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _getDeviceInfo() async {
    DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> _deviceData;
    try {
      if (Platform.isAndroid) {
        _deviceData = _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      _deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return _deviceData.toString();
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.release': build.version.release,
      'version.codename': build.version.codename,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'androidId': build.androidId,
      'user' : widget.profile.userID,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
      'user' : widget.profile.userID,
    };
  }

  Future<bool> _sendLogFile(String filePath) async {
    File _logFile = File(filePath);
    if(_logFile.existsSync()){
      //TODO send file
      return true;
    } else {
      FLog.error(
        exception: Exception("File not exist"),
        text: "Error while sending file, no such file",
      );
      return false;
    }
  }
}
