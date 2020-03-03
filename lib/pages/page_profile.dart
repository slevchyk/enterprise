import 'package:date_format/date_format.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/page_login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageProfile extends StatefulWidget {
  PageProfileState createState() => PageProfileState();
}

class PageProfileState extends State<PageProfile> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getProfileFromDB());
  }

  final GlobalKey<FormState> _formKeyMain = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPassportOriginal = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPassportID = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isEditing;
  bool isLoadingProfile = true;
  Profile profile;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _itnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportTypeController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _passportIssuedController = TextEditingController();
  final _passportDateController = TextEditingController();
  final _passportExpiryController = TextEditingController();
  final _civilStatusController = TextEditingController();
  final _childrenController = TextEditingController();
  final _jobPositionController = TextEditingController();
  final _educationController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _additionalEducationController = TextEditingController();
  final _lastWorkPlaceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _languagesController = TextEditingController();
  bool _isPensioner;
  bool _isDisability;
  final _infoCardController = TextEditingController();

  void setControllers(Profile _pfl) {
    _firstNameController.text = _pfl.firstName;
    _lastNameController.text = _pfl.lastName;
    _middleNameController.text = _pfl.middleName;
    _genderController.text = _pfl.gender;
    _itnController.text = _pfl.itn;
    _phoneController.text = _pfl.phone;
    _birthdayController.text = _pfl.birthday != null
        ? formatDate(_pfl.birthday, [dd, '-', mm, '-', yyyy])
        : "";
    _emailController.text = _pfl.email;
    _passportTypeController.text = _pfl.passportType;
    _passportNumberController.text = _pfl.passportNumber;
    _passportSeriesController.text = _pfl.passportSeries;
    _passportIssuedController.text = _pfl.passportIssued;
    _passportDateController.text = _pfl.passportDate != null
        ? formatDate(_pfl.passportDate, [dd, '-', mm, '-', yyyy])
        : "";
    _passportExpiryController.text = _pfl.passportExpiry != null
        ? formatDate(_pfl.passportExpiry, [dd, '-', mm, '-', yyyy])
        : "";
    _civilStatusController.text = _pfl.civilStatus;
    _childrenController.text = _pfl.children;
    _jobPositionController.text = _pfl.jobPosition;
    _educationController.text = _pfl.education.toString();
    _specialtyController.text = _pfl.specialty;
    _additionalEducationController.text = _pfl.additionalEducation;
    _lastWorkPlaceController.text = _pfl.lastWorkPlace;
    _skillsController.text = _pfl.skills;
    _languagesController.text = _pfl.languages;
    _isDisability = _pfl.disability;
    _isPensioner = _pfl.pensioner;
    _infoCardController.text = _pfl.infoCard.toString();
  }

  void _getProfileFromDB() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
      _profile = await ProfileDAO().getByUserId(_userID);
    }

    if (_profile != null) {
      setState(() {
        setControllers(_profile);
        profile = _profile;
        isLoadingProfile = false;
      });
    } else {
      setState(() {
        profile = Profile(
          userID: _userID,
        );
        isLoadingProfile = false;
      });
    }
  }

  void _downloadProfile(BuildContext context) async {
    Profile profile = await Profile.downloadByPhonePin(_scaffoldKey);

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

  List<DropdownMenuItem<String>> _getCivilStatuses() {
    List<DropdownMenuItem<String>> _list = [];
    civilStatusesAlias.forEach((k, v) {
      _list.add(
        DropdownMenuItem<String>(
          value: k,
          child: Text(v),
        ),
      );
    });

    return _list;
  }

  List<DropdownMenuItem<int>> _getEducations() {
    List<DropdownMenuItem<int>> _list = [];
    educationsAlias.forEach((k, v) {
      _list.add(
        DropdownMenuItem<int>(
          value: k,
          child: Text(v),
        ),
      );
    });

    return _list;
  }

  Widget _userPhoto(profile) {
    if (profile == null ||
        profile.photoName == null ||
        profile.photoName == '') {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        child: Text('фото'),
      );
    } else {
      return CircleAvatar(
        minRadius: 75,
        maxRadius: 100,
        backgroundImage: ExactAssetImage(profile.photoName),
      );
    }
  }

  void _changeUserPhoto(Profile _profile) async {
    File file = await FilePicker.getFile(
      type: FileType.IMAGE,
    );

    final documentDirectory = await getApplicationDocumentsDirectory();
    file.copy(documentDirectory.path);

    _profile.photoName = file.path;
    await ProfileDAO().update(_profile);

    setState(() {
      profile = _profile;
    });
  }

  Widget _genderChoiceChip(String _gender, Color _color, IconData _icon) {
    return ChoiceChip(
      padding: EdgeInsets.all(5.0),
      label: Row(
        children: <Widget>[
          Icon(
            _icon,
            color: _genderController.text == _gender
                ? Colors.white
                : Theme.of(context).iconTheme.color,
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(
            genderAlias[_gender],
            style: TextStyle(
              color: _genderController.text == _gender
                  ? Colors.white
                  : Theme.of(context).textTheme.title.color,
            ),
          ),
        ],
      ),
      backgroundColor:
          _genderController.text == "" ? _color : Colors.grey.shade100,
      selectedColor: Colors.green,
      selected: _genderController.text == _gender,
      onSelected: (bool value) {
        setState(() {
          _genderController.text = value ? _gender : "";
        });
      },
    );
  }

  Widget _passportTypeChoiceChip(String _type, IconData _icon) {
    return ChoiceChip(
      padding: EdgeInsets.all(5.0),
      label: Row(
        children: <Widget>[
          Icon(
            _icon,
            color: _passportTypeController.text == _type
                ? Colors.white
                : Theme.of(context).iconTheme.color,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            passportTypesAlias[_type],
            style: TextStyle(
              color: _passportTypeController.text == _type
                  ? Colors.white
                  : Theme.of(context).textTheme.title.color,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.green,
      selected: _passportTypeController.text == _type,
      onSelected: (bool value) {
        setState(() {
          _passportTypeController.text = value ? _type : "";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Профіль'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              FontAwesomeIcons.signOutAlt,
              color: Colors.white,
            ),
            onPressed: () async {
              singInOutDialog(context);
            },
          )
        ],
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
            child: _userPhoto(profile),
          ),
          Form(
            key: _formKeyMain,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Основне',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Column(
                      children: <Widget>[
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
                            if (value.isEmpty)
                              return 'ви не вказали по-батькові';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        FormField<String>(
                            builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              icon: Icon(FontAwesomeIcons.venusMars),
                              border: InputBorder.none,
                              labelText: 'Стать',
                            ),
                            child: Row(
                              children: <Widget>[
                                _genderChoiceChip(
                                    GENDER_FEMALE,
                                    Colors.pinkAccent.shade100,
                                    FontAwesomeIcons.female),
                                SizedBox(
                                  width: 10.0,
                                ),
                                _genderChoiceChip(
                                    GENDER_MALE,
                                    Colors.blueAccent.shade100,
                                    FontAwesomeIcons.male)
                              ],
                            ),
                          );
                        }),
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
                            if (value.isEmpty)
                              return 'ви не вказали номер телефону';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          keyboardType: TextInputType.phone,
                        ),
                        InkWell(
                          onTap: () async {
                            DateTime picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(DateTime.now().year - 80),
                                initialDate: profile.birthday != null
                                    ? profile.birthday
                                    : DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1));

                            if (picked != null)
                              setState(() {
                                profile.birthday = picked;
                                _birthdayController.text = formatDate(
                                    picked, [dd, '-', mm, '-', yyyy]);
                              });
                          },
                          child: IgnorePointer(
                            child: new TextFormField(
                              controller: _birthdayController,
                              decoration: new InputDecoration(
                                icon: Icon(FontAwesomeIcons.birthdayCake),
                                labelText: 'Дата народження',
                              ),
                              validator: (value) {
                                if (_passportTypeController.text ==
                                        PASSPORT_TYPE_ID &&
                                    value.isEmpty)
                                  return 'ви не вказали дату свого народження';
                                return null;
                              },
                              // maxLength: 10,
                            ),
                          ),
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
                      ],
                    )),
                SizedBox(
                  height: 24.0,
                ),
                Text(
                  'Документи',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _itnController,
                          decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.file),
                            labelText: 'ІПН',
                            hintText: 'ваш індивідуальний податковий номер',
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'ви не вказали ІПН';
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Вид документа, що засвідчує особу',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            _passportTypeChoiceChip(
                                PASSPORT_TYPE_ID, FontAwesomeIcons.idCard),
                            SizedBox(
                              width: 10.0,
                            ),
                            _passportTypeChoiceChip(PASSPORT_TYPE_ORIGINAL,
                                FontAwesomeIcons.passport)
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: _passportID(_formKeyPassportID),
                          secondChild:
                              _passportOriginal(_formKeyPassportOriginal),
                          crossFadeState:
                              _passportTypeController.text == PASSPORT_TYPE_ID
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 500),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 24.0,
                ),
                Text(
                  'Сім\'я',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: <Widget>[
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              icon: Icon(FontAwesomeIcons.ring),
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
                    ],
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Text(
                  'Освіта',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: <Widget>[
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
                                    _educationController.text =
                                        newValue.toString();
                                  });
                                },
                                items: _getEducations(),
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
                    ],
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Text(
                  'Інше',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _jobPositionController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.work),
                          hintText: 'ваша посада',
                          labelText: 'Посада',
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
                                value: _isDisability == null
                                    ? false
                                    : _isDisability,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isDisability = value;
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
                                value:
                                    _isPensioner == null ? false : _isPensioner,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isPensioner = value;
                                  });
                                }),
                          );
                        },
                      ),
                      TextFormField(
                        controller: _infoCardController,
                        readOnly: true,
                        decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.idBadge),
                          labelText: 'Інфокартка',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ProfileFAB(
        isEditing,
        (String value) {
          switch (value) {
            case "update":
              setState(() {
                isLoadingProfile = true;
              });
              _downloadProfile(context);
              break;
            case "edit":
              setState(() {
                isEditing = true;
              });
              break;
            case "undo":
              setState(() {
                isLoadingProfile = true;
                isEditing = false;
              });
              _getProfileFromDB();
              break;
            case "save":
              if (_formKeyMain.currentState.validate() &&
                  _formKeyPassportID.currentState.validate() &&
                  _formKeyPassportOriginal.currentState.validate()) {
                _saveProfile(_scaffoldKey);
              }
          }
        },
      ),
    );
  }

  Widget _passportID(GlobalKey<FormState> _formKey) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _passportNumberController,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              hintText: "документ №",
              labelText: "Документ №",
            ),
            validator: (value) {
              if (_passportTypeController.text == PASSPORT_TYPE_ID &&
                  value.isEmpty) return 'ви не вказали № документа';

              return null;
            },
          ),
          TextFormField(
            controller: _passportIssuedController,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              hintText: "орган, що видав ID картку",
              labelText: "Орган що видає",
            ),
            validator: (value) {
              if (_passportTypeController.text == PASSPORT_TYPE_ID &&
                  value.isEmpty)
                return 'ви не вказали орган, що видав ID картку';
              return null;
            },
          ),
          InkWell(
            onTap: () async {
              DateTime picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year - 10),
                  initialDate: profile.passportDate != null
                      ? profile.passportExpiry
                      : DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 10));

              if (picked != null)
                setState(() {
                  profile.passportExpiry = picked;
                  _passportExpiryController.text =
                      formatDate(picked, [dd, '-', mm, '-', yyyy]);
                });
            },
            child: IgnorePointer(
              child: new TextFormField(
                controller: _passportExpiryController,
                decoration: new InputDecoration(
                  icon: SizedBox(
                    width: 24.0,
                  ),
                  hintText: 'дата до якої дійсна ID картка',
                  labelText: 'Дійсний до',
                ),
                validator: (value) {
                  if (_passportTypeController.text == PASSPORT_TYPE_ID &&
                      value.isEmpty)
                    return 'ви не вказали дату до якої дійсна ID картка';
                  return null;
                },
                // maxLength: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passportOriginal(GlobalKey<FormState> _formKey) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _passportSeriesController,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              hintText: "перші дві літери паспорта",
              labelText: "Серія",
            ),
            validator: (value) {
              if (_passportTypeController.text == PASSPORT_TYPE_ORIGINAL &&
                  value.isEmpty) return 'ви не вказали серію паспорта';
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
              if (_passportTypeController.text == PASSPORT_TYPE_ORIGINAL &&
                  value.isEmpty) return 'ви не вказали номер паспорта';
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
              if (_passportTypeController.text == PASSPORT_TYPE_ORIGINAL &&
                  value.isEmpty) return 'ви не вказали ким виданий паспорт';
              return null;
            },
          ),
          InkWell(
            onTap: () async {
              DateTime picked = await showDatePicker(
                  context: context,
                  firstDate: new DateTime(1991),
                  initialDate: profile.passportDate != null
                      ? profile.passportDate
                      : DateTime.now(),
                  lastDate: new DateTime(DateTime.now().year + 1));

              if (picked != null)
                setState(() {
                  profile.passportDate = picked;
                  _passportDateController.text =
                      formatDate(picked, [dd, '-', mm, '-', yyyy]);
                });
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
                  if (_passportTypeController.text == PASSPORT_TYPE_ORIGINAL &&
                      value.isEmpty) return 'ви не вказали ким виданий паспорт';
                  return null;
                },
                // maxLength: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile(GlobalKey<ScaffoldState> _scaffoldKey) async {
    if (profile.userID == "") {
      return;
    }

    Profile _profile = Profile(
      blocked: profile?.blocked,
      userID: profile.userID,
      pin: profile?.pin,
      infoCard: profile?.infoCard,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      middleName: _lastNameController.text,
      phone: _phoneController.text,
      birthday: profile.birthday,
      itn: _itnController.text,
      email: _emailController.text,
      gender: _genderController.text,
      passportType: _passportTypeController.text,
      passportSeries: _passportSeriesController.text,
      passportNumber: _passportNumberController.text,
      passportIssued: _passportIssuedController.text,
      passportDate: profile.passportDate,
      passportExpiry: profile.passportExpiry,
      civilStatus: _civilStatusController.text,
      children: _childrenController.text,
      jobPosition: _jobPositionController.text,
      education: int.parse(_educationController.text),
      specialty: _specialtyController.text,
      additionalEducation: _additionalEducationController.text,
      lastWorkPlace: _lastWorkPlaceController.text,
      skills: _skillsController.text,
      languages: _languagesController.text,
      disability: _isDisability,
      pensioner: _isPensioner,
    );

    if (profile == null) {
      ProfileDAO().insert(_profile);
    } else {
      _profile.id = profile.id;
      ProfileDAO().update(_profile);
    }

    _profile.upload(_scaffoldKey).then((value) {
      if (value) {
        setState(() {
          isEditing = false;
        });
      }
    });
  }
}

class ProfileFAB extends StatefulWidget {
  final bool isEditing;
  final Function(String value) onPressed;

  ProfileFAB(
    this.isEditing,
    this.onPressed,
  );

  @override
  _ProfileFABState createState() => _ProfileFABState();
}

class _ProfileFABState extends State<ProfileFAB> {
  String currentTimingStatus;

  SpeedDialChild editSDC() {
    return SpeedDialChild(
      label: "Редагувати",
      child: Icon(Icons.edit),
      onTap: () {
        widget.onPressed("edit");
      },
    );
  }

  SpeedDialChild updateSDC() {
    return SpeedDialChild(
      label: "Оновити",
      child: Icon(Icons.update),
      onTap: () {
        widget.onPressed("update");
      },
    );
  }

  SpeedDialChild saveSDC() {
    return SpeedDialChild(
      label: "Зберегти",
      child: Icon(Icons.save),
      onTap: () {
        widget.onPressed("save");
      },
    );
  }

  SpeedDialChild undoSDC() {
    return SpeedDialChild(
      label: "Відмінити",
      child: Icon(Icons.undo),
      onTap: () {
        widget.onPressed("undo");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.isEditing) {
      case true:
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            saveSDC(),
            undoSDC(),
          ],
        );
      default:
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            updateSDC(),
            editSDC(),
          ],
        );
    }
  }
}

class ProfileTitle extends SliverPersistentHeaderDelegate {
  final double minSize;
  final double maxSize;
  final Widget child;

  ProfileTitle({
    this.minSize,
    this.maxSize,
    this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return child;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => maxSize;

  @override
  // TODO: implement minExtent
  double get minExtent => minSize;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
