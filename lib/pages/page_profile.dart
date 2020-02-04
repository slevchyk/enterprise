import 'package:date_format/date_format.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/database/core.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models.dart';
import 'package:file_picker/file_picker.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _itnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _passportIssuedController = TextEditingController();
  final _passportDateController = TextEditingController();
  final _civilStatusController = TextEditingController();
  final _childrenController = TextEditingController();
  final _positionController = TextEditingController();
  final _educationController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _additionalEducationController = TextEditingController();
  final _lastWorkPlaceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _disabilityController = TextEditingController();
  final _pensionerController = TextEditingController();

  bool isLoadingProfile = true;
  Profile profile;

  setControllers(Profile _pfl) {
    _firstNameController.text = _pfl.firstName;
    _lastNameController.text = _pfl.lastName;
    _middleNameController.text = _pfl.middleName;
    _itnController.text = _pfl.itn;
    _phoneController.text = _pfl.phone;
    _emailController.text = _pfl.email;
    _passportSeriesController.text = _pfl.passportSeries;
    _passportNumberController.text = _pfl.passportNumber;
    _passportIssuedController.text = _pfl.passportIssued;
    _passportDateController.text = _pfl.passportDate;
    _civilStatusController.text = _pfl.civilStatus;
    _childrenController.text = _pfl.children;
    _positionController.text = _pfl.position;
    _educationController.text = _pfl.education.toString();
    _specialtyController.text = _pfl.specialty;
    _additionalEducationController.text = _pfl.additionalEducation;
    _lastWorkPlaceController.text = _pfl.lastWorkPlace;
    _skillsController.text = _pfl.skills;
    _languagesController.text = _pfl.languages;
    _disabilityController.text = _pfl.disability;
    _pensionerController.text = _pfl.pensioner;
  }

  _getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
      _profile = await ProfileDAO().getByUuid(_userID);
    }

    if (_profile != null) {
      setState(() {
        setControllers(_profile);
        profile = _profile;
      });
    }

    setState(() {
      isLoadingProfile = false;
    });
  }

  _downloadProfile(BuildContext context) async {
    Profile profile = await Profile.download(_scaffoldKey);

    setState(() {
      if (profile != null) {
        setControllers(profile);
      }
      isLoadingProfile = false;
    });
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

  Map<String, String> _civilStatuses = {
    CIVIL_STATUS_SINGLE: "Не одружений",
    CIVIL_STATUS_MERRIED: "Одружений",
    CIVIL_STATUS_DIVORCED: "Розлучений",
    CIVIL_STATUS_WIDOWED: "Вдівець",
    CIVIL_STATUS_OTHER: "Інше",
  };

  Map<int, String> _educations = {
    EDUCATION_OTHER: "Інше",
    EDUCATION_HIGHER: "Вища освіта",
    EDUCATION_INCOMPLETE_HIGHER: "Неповна вища освіта",
    EDUCATION_PRIMARY_VOCATIONAL: "Початкова професійна освіта",
    EDUCATION_BASIC_GENERAL: "Основна загальна освіта",
  };

  List<DropdownMenuItem<String>> _getCivilStatuses() {
    List<DropdownMenuItem<String>> _list = [];
    _civilStatuses.forEach((k, v) {
      _list.add(
        DropdownMenuItem<String>(
          value: k,
          child: Text(v),
        ),
      );
    });

    return _list;
  }

  List<DropdownMenuItem<int>> _getEdications() {
    List<DropdownMenuItem<int>> _list = [];
    _educations.forEach((k, v) {
      _list.add(
        DropdownMenuItem<int>(
          value: k,
          child: Text(v),
        ),
      );
    });

    return _list;
  }

  Widget getUserpic(profile) {
    if (profile == null || profile.photo == '') {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        child: Text('фото'),
      );
    } else {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        backgroundImage: ExactAssetImage(profile.photo),
//        child: Image.asset(profile.photo),
      );
    }
  }

  _changeUserPhoto(Profile _profile) async {
    File file = await FilePicker.getFile(
      type: FileType.IMAGE,
    );

    final documentDirectory = await getApplicationDocumentsDirectory();
    file.copy(documentDirectory.path);

    _profile.photo = file.path;
    await ProfileDAO().update(_profile);

    setState(() {
      profile = _profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Профіль'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Container(
            height: isLoadingProfile ? 50 : 0,
            child: Center(
              child:
                  isLoadingProfile ? CircularProgressIndicator() : SizedBox(),
            ),
          ),
          FlatButton(
            onPressed: () {
              _changeUserPhoto(profile);
            },
            child: getUserpic(profile),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Основне:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
//                _firstNameController
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
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
//                _lastNameController
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
                    return null;
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
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
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
                    return null;
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
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[+0-9]"))
                  ],
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали номер телефону';
                    return null;
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
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  'Паспорт:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
                TextFormField(
                  controller: _passportSeriesController,
                  decoration: InputDecoration(
                    icon: Icon(FontAwesomeIcons.passport),
                    hintText: "перші дві літери паспорта",
                    labelText: "Серія",
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали серію паспорта';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passportNumberController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    hintText: "останні шість цифер паспорта",
                    labelText: "Номер",
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали номер паспорта';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passportIssuedController,
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
                    return null;
                  },
                ),
                InkWell(
                  onTap: () {
                    _selectDate(context, _passportDateController);
                  },
                  child: IgnorePointer(
                    child: new TextFormField(
                      controller: _passportDateController,
                      decoration: new InputDecoration(
                        icon: SizedBox(
                          width: 24.0,
                        ),
                        hintText: 'дата коли виданий паспорт',
                        labelText: 'Коли виданий',
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return 'ви не вказали ким виданий паспорт';
                        return null;
                      },
                      // maxLength: 10,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  'Сімейні дані:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        icon: Icon(FontAwesomeIcons.userFriends),
                        hintText: 'оберіть із списку',
                        labelText: 'Сімейний стан',
                        helperText: 'оберіть одне із значень із спику',
                      ),
                      isEmpty: false,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _civilStatusController.text.isEmpty
                              ? CIVIL_STATUS_OTHER
                              : _civilStatusController.text,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _civilStatusController.text = newValue;
                            });
                          },
                          items: _getCivilStatuses(),
                        ),
                      ),
                    );
                  },
                ),
                TextFormField(
                  controller: _childrenController,
                  decoration: InputDecoration(
                      icon: Icon(FontAwesomeIcons.baby),
                      hintText: '12.03.2012, 23.09.2015',
                      labelText: 'Дати народження дітей',
                      helperText: 'заповнювати якщо є діти'),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  'Освіта і інше:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
                TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.work),
                    hintText: 'ваша посада',
                    labelText: 'Посада',
                  ),
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        icon: Icon(Icons.school),
                        hintText: 'оберіть із списку',
                        labelText: 'Освіта',
                        helperText: 'оберіть одне із значень із спику',
                      ),
                      isEmpty: false,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _educationController.text.isEmpty
                              ? EDUCATION_OTHER
                              : int.parse(_educationController.text),
                          isDense: true,
                          onChanged: (int newValue) {
                            setState(() {
                              _educationController.text = newValue.toString();
                            });
                          },
                          items: _getEdications(),
                        ),
                      ),
                    );
                  },
                ),
                TextFormField(
                  controller: _specialtyController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    hintText: 'спеціальність за дипломом',
                    labelText: 'Спеціальність',
                  ),
                ),
                TextFormField(
                  controller: _additionalEducationController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    labelText: 'Додаткова освіта',
                  ),
                ),
                TextFormField(
                  controller: _skillsController,
                  decoration: InputDecoration(
                      icon: SizedBox(
                        width: 24.0,
                      ),
                      labelText: 'Навики',
                      hintText: 'професійні та інші навики'),
                ),
                TextFormField(
                  controller: _languagesController,
                  decoration: InputDecoration(
                      icon: Icon(Icons.language),
                      labelText: 'Знання мов',
                      hintText: 'іноземні мови'),
                ),
                TextFormField(
                  controller: _lastWorkPlaceController,
                  decoration: InputDecoration(
                      icon: Icon(FontAwesomeIcons.building),
                      labelText: 'Останнє місце роботи',
                      hintText: 'місто, компанія, посада'),
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        icon: Icon(FontAwesomeIcons.wheelchair),
                      ),
                      child: SwitchListTile(
                          title: Text('Відомість про інвалідність'),
                          value: _disabilityController.text == 'true',
                          onChanged: (bool value) {
                            setState(() {
                              value == true
                                  ? _disabilityController.text = 'true'
                                  : _disabilityController.text = 'false';
                            });
                          }),
                    );
                  },
                ),
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        icon: Icon(FontAwesomeIcons.blind),
                      ),
                      child: SwitchListTile(
                          title: Text('Пенсіонер'),
                          value: _pensionerController.text == 'true',
                          onChanged: (bool value) {
                            setState(() {
                              value == true
                                  ? _pensionerController.text = 'true'
                                  : _pensionerController.text = 'false';
                            });
                          }),
                    );
                  },
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
          setState(() {
            isLoadingProfile = true;
          });
          _downloadProfile(context);
        },
      ),
    );
  }
}
