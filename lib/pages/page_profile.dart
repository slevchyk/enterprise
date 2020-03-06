import 'package:date_format/date_format.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/pages/auth/page_login.dart';
import 'package:enterprise/widgets/user_photo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageProfile extends StatefulWidget {
  final Profile profile;

  PageProfile({
    this.profile,
  });

  PageProfileState createState() => PageProfileState();
}

class PageProfileState extends State<PageProfile> {
  final GlobalKey<FormState> _formKeyMain = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPassportOriginal = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPassportID = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _readOnly;
  bool _isLoadingProfile = false;
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

  @override
  void initState() {
    super.initState();
    _readOnly = true;
    profile = widget.profile;
    _setControllers();
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
            height: _isLoadingProfile ? 50 : 0,
            child: Center(
              child:
                  _isLoadingProfile ? CircularProgressIndicator() : SizedBox(),
            ),
          ),
          FlatButton(
            onPressed: () {
              _changeUserPhoto();
            },
            child: Container(
              width: 150.0,
              height: 150.0,
              child: UserPhoto(
                profile: profile,
              ),
            ),
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
                          readOnly: _readOnly,
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
                        ),
                        TextFormField(
                          controller: _lastNameController,
                          readOnly: _readOnly,
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
                        ),
                        TextFormField(
                          controller: _middleNameController,
                          readOnly: _readOnly,
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
                          readOnly: _readOnly,
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
                          keyboardType: TextInputType.phone,
                        ),
                        InkWell(
                          onTap: () async {
                            if (_readOnly) {
                              return;
                            }

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
                              readOnly: _readOnly,
                              decoration: new InputDecoration(
                                icon: Icon(FontAwesomeIcons.birthdayCake),
                                suffixIcon:
                                    _clearIconButton(_birthdayController),
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
                          readOnly: _readOnly,
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
                          readOnly: _readOnly,
                          decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.file),
                            suffixIcon: _clearIconButton(_itnController),
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
                                items: _civilStatusesList,
                              ),
                            ),
                          );
                        },
                      ),
                      TextFormField(
                        controller: _childrenController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.baby),
                            suffixIcon: _clearIconButton(_childrenController),
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
                                items: _educationsList,
                              ),
                            ),
                          );
                        },
                      ),
                      TextFormField(
                        controller: _specialtyController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                          icon: SizedBox(
                            width: 24.0,
                          ),
                          suffixIcon: _clearIconButton(_specialtyController),
                          hintText: 'спеціальність за дипломом',
                          labelText: 'Спеціальність',
                        ),
                      ),
                      TextFormField(
                        controller: _additionalEducationController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                          icon: SizedBox(
                            width: 24.0,
                          ),
                          suffixIcon:
                              _clearIconButton(_additionalEducationController),
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
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                          icon: Icon(Icons.work),
                          suffixIcon: _clearIconButton(_jobPositionController),
                          hintText: 'ваша посада',
                          labelText: 'Посада',
                        ),
                      ),
                      TextFormField(
                        controller: _skillsController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                            icon: SizedBox(
                              width: 24.0,
                            ),
                            suffixIcon: _clearIconButton(_skillsController),
                            labelText: 'Навики',
                            hintText: 'професійні та інші навики'),
                      ),
                      TextFormField(
                        controller: _languagesController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                            icon: Icon(Icons.language),
                            suffixIcon: _clearIconButton(_languagesController),
                            labelText: 'Знання мов',
                            hintText: 'іноземні мови'),
                      ),
                      TextFormField(
                        controller: _lastWorkPlaceController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.building),
                            suffixIcon:
                                _clearIconButton(_lastWorkPlaceController),
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
        _readOnly,
        (String value) {
          switch (value) {
            case "update":
              setState(() {
                _isLoadingProfile = true;
              });
              _downloadProfile(context);
              break;
            case "edit":
              setState(() {
                _readOnly = false;
              });
              break;
            case "undo":
              setState(() {
                _readOnly = true;
              });
              _setControllers();
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

  void _setControllers() {
    _firstNameController.text = profile?.firstName;
    _lastNameController.text = profile?.lastName;
    _middleNameController.text = profile?.middleName;
    _genderController.text = profile?.gender;
    _itnController.text = profile?.itn;
    _phoneController.text = profile?.phone;
    _birthdayController.text = profile?.birthday != null
        ? formatDate(profile.birthday, [dd, '-', mm, '-', yyyy])
        : "";
    _emailController.text = profile?.email;
    _passportTypeController.text = profile?.passportType;
    _passportNumberController.text = profile?.passportNumber;
    _passportSeriesController.text = profile?.passportSeries;
    _passportIssuedController.text = profile?.passportIssued;
    _passportDateController.text = profile?.passportDate != null
        ? formatDate(profile.passportDate, [dd, '-', mm, '-', yyyy])
        : "";
    _passportExpiryController.text = profile?.passportExpiry != null
        ? formatDate(profile.passportExpiry, [dd, '-', mm, '-', yyyy])
        : "";
    _civilStatusController.text = profile?.civilStatus;
    _childrenController.text = profile?.children;
    _jobPositionController.text = profile?.jobPosition;
    _educationController.text = profile?.education.toString();
    _specialtyController.text = profile?.specialty;
    _additionalEducationController.text = profile?.additionalEducation;
    _lastWorkPlaceController.text = profile?.lastWorkPlace;
    _skillsController.text = profile?.skills;
    _languagesController.text = profile?.languages;
    _isDisability = profile?.disability;
    _isPensioner = profile?.pensioner;
    _infoCardController.text = profile?.infoCard.toString();
  }

  void _downloadProfile(BuildContext context) async {
    Profile _profile = await Profile.downloadByPhonePin(_scaffoldKey);

    setState(() {
      profile = _profile;
      _isLoadingProfile = false;
    });

    _setControllers();
  }

  void _saveProfile(GlobalKey<ScaffoldState> _scaffoldKey) async {
    if (profile.userID == "") {
      return;
    }

    Profile _profile = Profile(
      id: profile.id,
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

    ProfileDAO().update(_profile);

    _profile.upload(_scaffoldKey).then((ok) {
      if (ok) {
        setState(() {
          _readOnly = true;
          profile = _profile;
        });
      }
    });
  }

  List<DropdownMenuItem<String>> get _civilStatusesList {
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

  List<DropdownMenuItem<int>> get _educationsList {
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

  void _changeUserPhoto() async {
    if (_readOnly) {
      return;
    }

    File file = await FilePicker.getFile(
      type: FileType.IMAGE,
    );

    final documentDirectory = await getApplicationDocumentsDirectory();
    file.copy(documentDirectory.path);

    await ProfileDAO().update(profile);

    setState(() {
      profile.photoName = file.path;
    });
  }

  Widget _clearIconButton(TextEditingController textController) {
    if (_readOnly || textController.text.isEmpty)
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
        if (_readOnly) {
          return;
        }

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
        if (_readOnly) {
          return;
        }

        setState(() {
          _passportTypeController.text = value ? _type : "";
        });
      },
    );
  }

  Widget _passportID(GlobalKey<FormState> _formKey) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _passportNumberController,
            readOnly: _readOnly,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              suffixIcon: _clearIconButton(_passportNumberController),
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
            readOnly: _readOnly,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              suffixIcon: _clearIconButton(_passportIssuedController),
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
              if (_readOnly) {
                return;
              }

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
                readOnly: _readOnly,
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
            readOnly: _readOnly,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              suffixIcon: _clearIconButton(_passportSeriesController),
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
            readOnly: _readOnly,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              suffixIcon: _clearIconButton(_passportNumberController),
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
            readOnly: _readOnly,
            decoration: InputDecoration(
              icon: SizedBox(
                width: 24.0,
              ),
              suffixIcon: _clearIconButton(_passportIssuedController),
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
              if (_readOnly) {
                return;
              }

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
                readOnly: _readOnly,
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
}

class ProfileFAB extends StatefulWidget {
  final bool readOnly;
  final Function(String value) onPressed;

  ProfileFAB(
    this.readOnly,
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
    switch (widget.readOnly) {
      case false:
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
