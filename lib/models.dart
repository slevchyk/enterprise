import 'dart:convert';

Profile profileFromJson(String str) {
  final jsonData = json.decode(str);
  return Profile.fromMap(jsonData);
}

String profiletToJson(Profile data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Profile {
  int id;
  String firstName;
  String lastName;
  String middleName;
  String phone;
  String itn;
  String email;
  String photo;
  bool blocked;

  Profile({
    this.id,
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.itn,
    this.email,
    this.photo,
    this.blocked,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        phone: json["phone"],
        itn: json["itn"],
        email: json["email"],
        photo: json["photo"],
        blocked: json["blocked"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "phone": phone,
        "itn": itn,
        "email": email,
        "photo": photo,
        "blocked": blocked,
      };
}
