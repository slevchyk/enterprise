import 'package:date_format/date_format.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageProfile extends StatefulWidget {
  PageProfileState createState() => PageProfileState();
}

class PageProfileState extends State<PageProfile> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSettings());
  }

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _itnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportSeries = TextEditingController();
  final _passportNumber = TextEditingController();
  final _passportIssued = TextEditingController();
  final _passportDate = TextEditingController();

  bool isLoadingProfile = true;
  Profile profile;

  setControllers(Profile _pfl) {
    _firstNameController.text = _pfl.firstName;
    _lastNameController.text = _pfl.lastName;
    _middleNameController.text = _pfl.middleName;
    _itnController.text = _pfl.itn;
    _phoneController.text = _pfl.phone;
    _emailController.text = _pfl.email;
    _passportSeries.text = _pfl.passport.series;
    _passportNumber.text = _pfl.passport.number;
    _passportIssued.text = _pfl.passport.issued;
    _passportDate.text = _pfl.passport.date;
  }

  _getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
      _profile = await DBProvider.db.getProfile(_userID);
    }

    setState(() {
      if (_profile != null) {
        setControllers(_profile);
      }

      profile = _profile;
      isLoadingProfile = false;
    });
  }

  _downloadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final String _ip = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _user = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _password = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _db = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String _userID = prefs.get(KEY_USER_ID);

    final String url =
        'http://$_ip/$_db/hs/m/profile?infocard=$_userID&photo=true';

    final credentials = '$_user:$_password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    Response response = await get(url, headers: headers);

    int statusCode = response.statusCode;

    if (statusCode != 200) {
//      Scaffold.of(this.context).showSnackBar(SnackBar(
//        content: Text('Не вдалось отримати дані профілю'),
//        backgroundColor: Colors.redAccent,
//      ));
      return;
    }

    String body = utf8.decode(response.bodyBytes);

    Profile profile = profileFromJsonApi(body);

    if (profile.photo != '') {
      final documentDirectory = await getApplicationDocumentsDirectory();
      File file = new File(join(documentDirectory.path, profile.photo));

      var strPhoto = profile.photoData;
      strPhoto = strPhoto.replaceAll("\r", "");
      strPhoto = strPhoto.replaceAll("\n", "");

      final _bytePhoto = base64Decode(strPhoto);
      file.writeAsBytes(_bytePhoto);

      profile.photo = file.path;
      prefs.setString(KEY_USER_PICTURE, file.path);
    }

    await DBProvider.db.newProfile(profile);

    if (profile != null) {
      setState(() {
        setControllers(profile);
      });
    }

//    Scaffold.of(this.context).showSnackBar(SnackBar(
//      content: Text('Оновлена'),
//      backgroundColor: Colors.green,
//    ));
  }

  Widget _clearIconButton(TextEditingController textController) {
    if (textController.text.isEmpty)
      return null;
    else
      return IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              textController.clear();
            });
          });
  }

  Future _selectDate(
      BuildContext context, TextEditingController textController) async {
    DateTime picked = await showDatePicker(
        context: context,
        firstDate: new DateTime(1991),
        initialDate: new DateTime.now(),
        lastDate: new DateTime(DateTime.now().year + 1));

    if (picked != null)
      setState(() {
        textController.text = formatDate(picked, [yyyy, '-', mm, '-', dd]);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профіль'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Основне:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    suffixIcon: _clearIconButton(_firstNameController),
                    hintText: 'ваше ім\'я',
                    labelText: 'Ім\'я *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали ім\'я';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    suffixIcon: _clearIconButton(_lastNameController),
                    hintText: 'ваше прізвище',
                    labelText: 'Прізвище *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали прізвище';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                TextFormField(
                  controller: _middleNameController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    suffixIcon: _clearIconButton(_middleNameController),
                    hintText: 'по-батькові',
                    labelText: 'По-батькові *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали по-батькові';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _itnController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    labelText: 'ІПН',
                    hintText: 'ваш ІПН (якщо немає, то серія і номер паспорта',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали ІПН/Паспорт';
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone),
                    suffixIcon: _clearIconButton(_phoneController),
                    hintText: 'номер вашого мобільного телефону',
                    labelText: 'Телефон *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали номер телефону';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    suffixIcon: _clearIconButton(_emailController),
                    hintText: 'ваш email',
                    labelText: 'Email *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали email';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Паспорт:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
                TextFormField(
                  controller: _passportSeries,
                  decoration: InputDecoration(
                    icon: Icon(FontAwesomeIcons.passport),
                    hintText: "перші дві літери паспорта",
                    labelText: "Серія",
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали серію паспорта';
                  },
                ),
                TextFormField(
                  controller: _passportNumber,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    hintText: "останні шість цифер паспорта",
                    labelText: "Номер",
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали номер паспорта';
                  },
                ),
                TextFormField(
                  controller: _passportIssued,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    hintText: "установа якою виданий паспорт",
                    labelText: "Ким виданий",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      return 'ви не вказали ким виданий паспорт';
                  },
                ),
                InkWell(
                  onTap: () {
                    _selectDate(context, _passportDate);
                  },
                  child: IgnorePointer(
                    child: new TextFormField(
                      controller: _passportDate,
                      decoration: new InputDecoration(
                        icon: SizedBox(
                          width: 24.0,
                        ),
                        hintText: 'дата коли виданий паспорт',
                        labelText: 'Коли виданий',
                      ),
                      maxLength: 10,
                      // validator: validateDob,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Налаштування збережено'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  },
                  child: Text('Save'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.update),
        onPressed: () {
          _downloadProfile();
        },
      ),
    );
  }
}
