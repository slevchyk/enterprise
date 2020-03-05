import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAsync());
  }

  initAsync() async {
    bool _isProtectionEnabled = false;
    bool _canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;

    final prefs = await SharedPreferences.getInstance();

    if (_canCheckBiometrics) {
      _isProtectionEnabled = prefs.getBool(KEY_IS_PROTECTION_ENABLED) ?? false;
    } else {
      prefs.setBool(KEY_IS_PROTECTION_ENABLED, false);
    }

    setState(() {
      canCheckBiometrics = _canCheckBiometrics;
      isProtectionEnabled = _isProtectionEnabled;
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
              Visibility(
                visible: canCheckBiometrics,
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        icon: Icon(Icons.fingerprint),
                      ),
                      child: SwitchListTile(
                          title: Text(
                              'Увімкнути захист додатку відбитком пальця ци розпізнаванням обличчя'),
                          value: isProtectionEnabled,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            String _authPin =
                                prefs.getString(KEY_AUTH_PIN) ?? "";
                            if (_authPin == "") {
                              Navigator.of(context).pushNamed("/set_pin");
                              return;
                            }

                            setState(() {
                              isProtectionEnabled = value;
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
