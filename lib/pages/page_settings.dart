import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
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
      drawer: AppDrawer(
        profile: widget.profile,
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: <Widget>[
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: Icon(Icons.dialpad),
                    ),
                    child: SwitchListTile(
                        title: Text('Увімкнути захист додатку ПІН-кодом'),
                        value: isProtectionEnabled,
                        onChanged: (bool value) async {
                          final prefs = await SharedPreferences.getInstance();

                          if (!value) {
                            prefs.setBool(
                                KEY_IS_BIOMETRIC_PROTECTION_ENABLED, value);
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
                        }),
                  );
                },
              ),
              Visibility(
                visible: canCheckBiometrics && isProtectionEnabled,
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        icon: Icon(Icons.fingerprint),
                      ),
                      child: SwitchListTile(
                          title: Text(
                              'Увімкнути захист додатку відбитком пальця ци розпізнаванням обличчя'),
                          value: isBiometricProtectionEnabled,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool(
                                KEY_IS_BIOMETRIC_PROTECTION_ENABLED, value);

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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();

          prefs.setBool(KEY_IS_PROTECTION_ENABLED, isProtectionEnabled);
        },
      ),
    );
  }
}
