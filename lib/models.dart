import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/utils.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Profile profileFromJson(String str) {
  final jsonData = json.decode(str);
  return Profile.fromMap(jsonData);
}

//Profile profileFromJsonApi(String str) {
//  final jsonData = json.decode(str);
//  return Profile.fromMap(jsonData["application"]);
//}

//String profiletToJson(Profile data) {
//  final dyn = data.toMap();
//  return json.encode(dyn);
//}

class Profile {
  int id;
  String uuid;
  String firstName;
  String lastName;
  String middleName;
  String phone;
  String itn;
  String email;
  String photo;
  String photoData;
  String sex;
  bool blocked;
  String passportType;
  String passportSeries;
  String passportNumber;
  String passportIssued;
  String passportDate;
  String passportExpiry;
  String civilStatus;
  String children;
  String position;
  int education;
  String specialty;
  String additionalEducation;
  String lastWorkPlace;
  String skills;
  String languages;
  String disability;
  String pensioner;

  Profile(
      {this.id,
      this.uuid,
      this.firstName,
      this.lastName,
      this.middleName,
      this.phone,
      this.itn,
      this.email,
      this.photo,
      this.photoData,
      this.sex,
      this.blocked,
      this.passportType,
      this.passportSeries,
      this.passportNumber,
      this.passportIssued,
      this.passportDate,
      this.passportExpiry,
      this.civilStatus,
      this.children,
      this.position,
      this.education,
      this.specialty,
      this.additionalEducation,
      this.lastWorkPlace,
      this.skills,
      this.languages,
      this.disability,
      this.pensioner});

  factory Profile.fromMap(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        uuid: json["uuid"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        phone: json["phone"],
        itn: json["itn"],
        email: json["email"],
        photo: json["photo_name"],
        photoData: json["photo_data"],
        sex: json["sex"],
        blocked: json["blocked"] == 1,
        passportType: json["passport_type"],
        passportSeries: json["passport_series"],
        passportNumber: json["passport_number"],
        passportIssued: json["passport_issued"],
        passportDate: json["passport_date"],
        passportExpiry: json["passport_expiry"],
        civilStatus: json["civil_status"],
        children: json["children"],
        position: json["position"],
        education: int.parse(json['education']),
        specialty: json['specialty'],
        additionalEducation: json['additional_education'],
        lastWorkPlace: json["last_work_place"],
        skills: json["skills"],
        languages: json["languages"],
        disability: json["disability"],
        pensioner: json["pensioner"],
      );

  factory Profile.fromDB(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        uuid: json["uuid"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        phone: json["phone"],
        itn: json["itn"],
        email: json["email"],
        photo: json["photo"],
        sex: json["sex"],
        blocked: json["blocked"] == 1,
        passportType: json["passport_type"],
        passportSeries: json["passport_series"],
        passportNumber: json["passport_number"],
        passportIssued: json["passport_issued"],
        passportDate: json["passport_date"],
        passportExpiry: json["passport_expiry"],
        civilStatus: json["civil_status"],
        children: json["children"],
        position: json["position"],
        education: json['education'],
        specialty: json['specialty'],
        additionalEducation: json['additional_education'],
        lastWorkPlace: json["last_work_place"],
        skills: json["skills"],
        languages: json["languages"],
        disability: json["disability"],
        pensioner: json["pensioner"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "uuid": uuid,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "phone": phone,
        "itn": itn,
        "email": email,
        "photo": photo,
        "photo_data": photoData,
        "sex": sex,
        "blocked": blocked,
        "passport_type": passportType,
        "passport_series": passportSeries,
        "passport_number": passportNumber,
        "passport_issued": passportIssued,
        "passport_date": passportDate,
        "passport_expiry": passportExpiry,
        "civil_status": civilStatus,
        "children": children,
        "position": position,
        "education": education,
        "specialty": specialty,
        "additional_education": additionalEducation,
        "last_work_place": lastWorkPlace,
        "skills": skills,
        "languages": languages,
        "disability": disability,
        "pensioner": pensioner,
      };

  Map<String, dynamic> toDB() => {
        "id": id,
        "uuid": uuid,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "phone": phone,
        "itn": itn,
        "email": email,
        "photo": photo,
        "sex": sex,
        "blocked": blocked,
        "passport_type": passportType,
        "passport_series": passportSeries,
        "passport_number": passportNumber,
        "passport_issued": passportIssued,
        "passport_date": passportDate,
        "passport_expiry": passportExpiry,
        "civil_status": civilStatus,
        "children": children,
        "position": position,
        "education": education,
        "specialty": specialty,
        "additional_education": additionalEducation,
        "last_work_place": lastWorkPlace,
        "skills": skills,
        "languages": languages,
        "disability": disability,
        "pensioner": pensioner,
      };

  static Future<Profile> download(GlobalKey<ScaffoldState> _scaffoldKey) async {
    Profile profile;

    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassord = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _serverDB = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String _userPhone = prefs.get(KEY_USER_PHONE);
    final String _userPin = prefs.get(KEY_USER_PIN);

    final String url =
        'http://$_serverIP/$_serverDB/hs/m/profile?phone=$_userPhone&pin=$_userPin';

    final credentials = '$_serverUser:$_serverPassord';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

    Response response = await get(url, headers: headers);

    int statusCode = response.statusCode;

    if (statusCode != 200) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('не вдалось з\'єднатись із сервером'),
        backgroundColor: Colors.redAccent,
      ));
      return profile;
    }

    String body = utf8.decode(response.bodyBytes);

    var jsonData = json.decode(body);

    if (jsonData['status'] != 200) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('обліковий запис не знайдено'),
        backgroundColor: Colors.redAccent,
      ));
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

    Profile existProfile = await DBProvider.db.getProfile(profile.uuid);
    if (existProfile == null) {
      await DBProvider.db.newProfile(profile);
    } else {
      profile.id = existProfile.id;
      await DBProvider.db.updateProfile(profile);
    }

    if (profile != null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('ваш обліовий запис оновлено'),
        backgroundColor: Colors.green,
      ));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('не вдалось поновити обліковий запис'),
        backgroundColor: Colors.green,
      ));
    }

    return profile;
  }
}

class Timing {
  int id;
  String extID;
  String userID;
  DateTime date;
  String operation;
  DateTime startedAt;
  DateTime endedAt;
  double duration;
  bool toUpload;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;

  Timing({
    this.id,
    this.extID,
    this.userID,
    this.date,
    this.operation,
    this.startedAt,
    this.endedAt,
    this.duration,
    this.toUpload,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Timing.fromMap(Map<String, dynamic> json) => new Timing(
        id: json["id"],
        extID: json["ext_id"],
        userID: json["user_id"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        operation: json["operation"],
        startedAt: json["started_at"] != null
            ? DateTime.parse(json["started_at"])
            : null,
        endedAt:
            json["ended_at"] != null ? DateTime.parse(json["ended_at"]) : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "date": date != null ? date.toIso8601String() : null,
        "operation": operation,
        "started_at": startedAt != null ? startedAt.toIso8601String() : null,
        "ended_at": endedAt != null ? endedAt.toIso8601String() : null,
        "created_at": createdAt != null ? createdAt.toIso8601String() : null,
        "updated_at": updatedAt != null ? updatedAt.toIso8601String() : null,
        "deleted_at": deletedAt != null ? deletedAt.toIso8601String() : null,
        "ext_id": extID,
      };

  static upload(userID) async {
    List<Timing> toUpload = await DBProvider.db.getTimingToUpload(userID);

    Map<String, List<Map<String, dynamic>>> jsonData;
    List<Map<String, dynamic>> rows = [];

    for (var _timing in toUpload) {
      rows.add(_timing.toMap());
    }

    jsonData = {'timing': rows};

    final prefs = await SharedPreferences.getInstance();

    final String _serverIP = prefs.getString(KEY_SERVER_IP) ?? "";
    final String _serverUser = prefs.getString(KEY_SERVER_USER) ?? "";
    final String _serverPassord = prefs.getString(KEY_SERVER_PASSWORD) ?? "";
    final String _serverDB = prefs.getString(KEY_SERVER_DATABASE) ?? "";

    final String url = 'http://$_serverIP/$_serverDB/hs/m/timing';

    final credentials = '$_serverUser:$_serverPassord';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    Response response = await post(
      url,
      headers: headers,
      body: json.encode(jsonData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      for (var _timing in jsonData['precessed']) {
        DBProvider.db.updateTimingProcessed(_timing['id'], _timing['ext_id']);
      }
    }
  }

  static void closePastOperation() async {
    List<Timing> openOperation = await DBProvider.db
        .getTimingOpenPastOperation(Utility.beginningOfDay(DateTime.now()));

    for (var _timimg in openOperation) {
      DateTime endDate = new DateTime(_timimg.startedAt.year,
          _timimg.startedAt.month, _timimg.startedAt.day, 18, 00, 00);

      if (endDate.millisecondsSinceEpoch >
          _timimg.startedAt.millisecondsSinceEpoch) {
        endDate = _timimg.startedAt;
      }

      _timimg.endedAt = endDate;
      DBProvider.db.updateTiming(_timimg);
    }
  }

//  static Future<List<TimingDayData>> getTimingDayChartData(
//      String userID, DateTime dateTime) async {
//    DateTime beginDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
//
//    List<Timing> listTiming =
//        await DBProvider.db.getUserTiming(beginDay, userID);
//
//    List<TimingDayData> listOperation = [];
//
//    for (var _timing in listTiming) {
//      DateTime endDate = _timing.endDate;
//      if (endDate == null) {
//        endDate = DateTime.now();
//      }
//
//      double time = (endDate.millisecondsSinceEpoch -
//              _timing.startDate.millisecondsSinceEpoch) /
//          3600000;
//
////      DateTime endDate = _timing.endDate = null ? DateTime.now() : _timing.endDate;
////
////      double time = endDate.millisecondsSinceEpoch - _timing.startDate.millisecondsSinceEpoch / 36000000;
//
////      TimingDayData operation = TimingDayData(_timing.operation, time);
//
//      TimingDayData operation = TimingDayData(_timing.operation, 22.0);
//      listOperation.add(operation);
//    }
//
//    return listOperation;
//  }

}

class Chanel {
  int id;
  String userID;
  String title;
  String news;
  DateTime date;
  DateTime star;
  DateTime archive;
  DateTime delete_at;

  Chanel({
    this.id,
    this.userID,
    this.title,
    this.news,
    this.date,
    this.star,
    this.archive,
    this.delete_at,
  });

  factory Chanel.fromMap(Map<String, dynamic> json) => new Chanel(
        id: json["id"],
        title: json["title"],
        news: json["news"],
        date: json["date"] != null ? DateTime.parse(json["date"]) : null,
        star: json["star"] != null ? DateTime.parse(json["star"]) : null,
        archive:
            json["archive"] != null ? DateTime.parse(json["archive"]) : null,
        delete_at: json["delete_at"] != null
            ? DateTime.parse(json["delete_at"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "title": title,
        "news": news,
        "date": date != null ? date.toIso8601String() : null,
        "star": star != null ? star.toIso8601String() : null,
        "archive": archive != null ? archive.toIso8601String() : null,
        "delete_at": delete_at != null ? delete_at.toIso8601String() : null,
      };
}

class ChartData {
  String title;
  double value;

  ChartData({
    this.title,
    this.value,
  });
}
