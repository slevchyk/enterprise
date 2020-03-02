import 'dart:convert';
import 'dart:io';
import 'package:enterprise/database/profile_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:enterprise/models/constants.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  int id;
  bool blocked;
  String userID;
  String pin;
  int infoCard;
  String firstName;
  String lastName;
  String middleName;
  String phone;
  DateTime birthday;
  String itn;
  String email;
  String gender;
  String passportType;
  String passportSeries;
  String passportNumber;
  String passportIssued;
  DateTime passportDate;
  DateTime passportExpiry;
  String civilStatus;
  String children;
  String jobPosition;
  int education;
  String specialty;
  String additionalEducation;
  String lastWorkPlace;
  String skills;
  String languages;
  bool disability;
  bool pensioner;
  String photo;
  String photoData;

  Profile({
    this.id,
    this.blocked,
    this.userID,
    this.pin,
    this.infoCard,
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.birthday,
    this.itn,
    this.email,
    this.gender,
    this.passportType,
    this.passportSeries,
    this.passportNumber,
    this.passportIssued,
    this.passportDate,
    this.passportExpiry,
    this.civilStatus,
    this.children,
    this.jobPosition,
    this.education,
    this.specialty,
    this.additionalEducation,
    this.lastWorkPlace,
    this.skills,
    this.languages,
    this.disability,
    this.pensioner,
    this.photo,
    this.photoData,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        blocked:
            json["blocked"] is int ? json["blocked"] == 1 : json["blocked"],
        userID: json["user_id"],
        pin: json["pin"],
        infoCard: json["info_card"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        phone: json["phone"],
        birthday: json["birthday"] != null && json["birthday"] != ""
            ? DateTime.parse(json["birthday"])
            : null,
        itn: json["itn"],
        email: json["email"],
        gender: json["gender"],
        passportType: json["passport_type"],
        passportSeries: json["passport_series"],
        passportNumber: json["passport_number"],
        passportIssued: json["passport_issued"],
        passportDate:
            json["passport_date"] != null && json["passport_date"] != ""
                ? DateTime.parse(json["passport_date"])
                : null,
        passportExpiry:
            json["passport_expiry"] != null && json["passport_expiry"] != ""
                ? DateTime.parse(json["passport_expiry"])
                : null,
        civilStatus: json["civil_status"],
        children: json["children"],
        jobPosition: json["job_position"],
        education: json['education'] is int
            ? json['education']
            : int.parse(json['education']),
        specialty: json['specialty'],
        additionalEducation: json['additional_education'],
        lastWorkPlace: json["last_work_place"],
        skills: json["skills"],
        languages: json["languages"],
        disability: json["disability"] is int
            ? json["disability"] == 1
            : json["disability"] is String
                ? json["disability"] == "true"
                : json["disability"],
        pensioner: json["pensioner"] is int
            ? json["pensioner"] == 1
            : json["pensioner"] is String
                ? json["pensioner"] == "true"
                : json["pensioner"],
        photo: json["photo"],
//        photoData: json["photo_data"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "blocked": blocked,
        "pin": pin,
        "info_card": infoCard,
        "user_id": userID,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "phone": phone,
        "birthday": birthday != null ? birthday.toIso8601String() : null,
        "itn": itn,
        "email": email,
        "gender": gender,
        "passport_type": passportType,
        "passport_series": passportSeries,
        "passport_number": passportNumber,
        "passport_issued": passportIssued,
        "passport_date":
            passportDate != null ? passportDate.toIso8601String() : null,
        "passport_expiry":
            passportExpiry != null ? passportExpiry.toIso8601String() : null,
        "civil_status": civilStatus,
        "children": children,
        "job_position": jobPosition,
        "education": education,
        "specialty": specialty,
        "additional_education": additionalEducation,
        "last_work_place": lastWorkPlace,
        "skills": skills,
        "languages": languages,
        "disability": disability,
        "pensioner": pensioner,
        "photo": photo,
//        "photo_data": photoData,
      };

  static Future<Profile> downloadByPhonePin(
      GlobalKey<ScaffoldState> _scaffoldKey) async {
    Profile profile;

    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _localSrvUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _localSrvPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    String _userPhone = prefs.get(KEY_USER_PHONE);
    String _userPin = prefs.get(KEY_USER_PIN);

    _userPhone = _userPhone.replaceAll("+", "");

    final String url =
        'http://$_serverIP/api/profile?phone=$_userPhone&pin=$_userPin';

    final credentials = '$_localSrvUser:$_localSrvPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    Response response = await get(url, headers: headers);

    int statusCode = response.statusCode;

    if (statusCode != 200) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('не вдалось з\'єднатись із локальним сервером'),
        backgroundColor: Colors.redAccent,
      ));
      return profile;
    }

    String body = utf8.decode(response.bodyBytes);

    var jsonData = json.decode(body);

    profile = Profile.fromMap(jsonData);

    if (profile.photo != '') {
      final documentDirectory = await getApplicationDocumentsDirectory();
      File file = new File(join(documentDirectory.path, profile.photo));

      var base64Photo = profile.photoData;
      base64Photo = base64Photo.replaceAll("\r", "");
      base64Photo = base64Photo.replaceAll("\n", "");

      final _bytePhoto = base64Decode(base64Photo);
      file.writeAsBytes(_bytePhoto);

      profile.photo = file.path;
      prefs.setString(KEY_USER_PICTURE, file.path);
    }

    Profile existProfile = await ProfileDAO().getByUserId(profile.userID);
    if (existProfile == null) {
      await ProfileDAO().insert(profile);
    } else {
      profile.id = existProfile.id;
      await ProfileDAO().update(profile);
    }

    if (profile != null) {
      prefs.setString(KEY_USER_ID, profile.userID);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('отримано ваш обліковий запис'),
        backgroundColor: Colors.green,
      ));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('не вдалось отримати ваш обліковий запис'),
        backgroundColor: Colors.green,
      ));
    }

    return profile;
  }

  Future<bool> upload(GlobalKey<ScaffoldState> _scaffoldKey) async {
    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _localSrvUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _localSrvPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";

    final String url = 'http://$_serverIP/api/profile';

    final credentials = '$_localSrvUser:$_localSrvPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, dynamic> jsonData = this.toMap();

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Response response =
        await post(url, headers: headers, body: json.encode(jsonData));

    int statusCode = response.statusCode;

    if (statusCode == 200) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('ваш профіль оновлено'),
        backgroundColor: Colors.green,
      ));

      return true;
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('не вдалось поновити профіль'),
        backgroundColor: Colors.redAccent,
      ));

      return false;
    }
  }

  static Future<Profile> downloadByInfoCard(String infoCard) async {
    Profile profile;

    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassword = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _serverDB = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String url =
        'http://$_serverIP/$_serverDB/hs/m/profile?action=card&infocard=$infoCard';

    final credentials = '$_serverUser:$_serverPassword';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    Response response = await get(url, headers: headers);

    int statusCode = response.statusCode;

    if (statusCode != 200) {
      return profile;
    }

    String body = utf8.decode(response.bodyBytes);

    var jsonData = json.decode(body);

    if (jsonData['status'] != 200) {
      return profile;
    }

    profile = Profile.fromMap(jsonData["application"]);

    if (profile.photo != '') {
      final documentDirectory = await getApplicationDocumentsDirectory();
      File file = new File(join(documentDirectory.path, profile.photo));

      var base64Photo = profile.photoData;
      base64Photo = base64Photo.replaceAll("\r", "");
      base64Photo = base64Photo.replaceAll("\n", "");

      final _bytePhoto = base64Decode(base64Photo);
      file.writeAsBytes(_bytePhoto);

      profile.photo = file.path;
      prefs.setString(KEY_USER_PICTURE, file.path);
    }

    Profile existProfile = await ProfileDAO().getByUserId(profile.userID);
    if (existProfile == null) {
      await ProfileDAO().insert(profile);
    } else {
      profile.id = existProfile.id;
      await ProfileDAO().update(profile);
    }

    return profile;
  }

  static downloadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassord = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _serverDB = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String url = 'http://$_serverIP/$_serverDB/hs/m/profile?action=all';

    final credentials = '$_serverUser:$_serverPassord';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    Response response = await get(url, headers: headers);

    int statusCode = response.statusCode;

    if (statusCode != 200) {
      return;
    }

    String body = utf8.decode(response.bodyBytes);

    var jsonData = json.decode(body);

    if (jsonData['status'] != 200) {
      return;
    }

    for (var jsonRow in jsonData["cards"]) {
      downloadByInfoCard(jsonRow["info_card"]);
    }
  }
}
