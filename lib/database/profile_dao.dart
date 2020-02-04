import '../models.dart';
import 'core.dart';

class ProfileDAO {
  final dbProvider = DBProvider.db;

  Future insert(Profile newProfile) async {
    final db = await dbProvider.database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Profile");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        'INSERT Into Profile ('
        'id, '
        'uuid, '
        'first_name,'
        'last_name,'
        'middle_name,'
        'phone,'
        'itn,'
        'email,'
        'photo,'
        'sex,'
        'blocked,'
        'passport_type,'
        'passport_series,'
        'passport_number,'
        'passport_issued,'
        'passport_date,'
        'passport_expiry,'
        'civil_status,'
        'children,'
        'position,'
        'education,'
        'specialty,'
        'additional_education,'
        'last_work_place,'
        'skills,'
        'languages,'
        'disability,'
        'pensioner'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          id,
          newProfile.uuid,
          newProfile.firstName,
          newProfile.lastName,
          newProfile.middleName,
          newProfile.phone,
          newProfile.itn,
          newProfile.email,
          newProfile.photo,
          newProfile.sex,
          newProfile.blocked,
          newProfile.passportType,
          newProfile.passportSeries,
          newProfile.passportNumber,
          newProfile.passportIssued,
          newProfile.passportDate,
          newProfile.passportExpiry,
          newProfile.civilStatus,
          newProfile.children,
          newProfile.position,
          newProfile.education,
          newProfile.specialty,
          newProfile.additionalEducation,
          newProfile.lastWorkPlace,
          newProfile.skills,
          newProfile.languages,
          newProfile.disability,
          newProfile.pensioner
        ]);
    return raw;
  }

  block(Profile profile) async {
    final db = await dbProvider.database;
    Profile blocked = await getByUuid(profile.uuid);
    blocked.blocked = true;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  unblock(Profile profile) async {
    final db = await dbProvider.database;
    Profile blocked = await getByUuid(profile.uuid);
    blocked.blocked = false;
    var res = await db.update("Profile", blocked.toMap(),
        where: "id = ?", whereArgs: [profile.id]);
    return res;
  }

  update(Profile newProfile) async {
    final db = await dbProvider.database;
    var res = await db.update("Profile", newProfile.toDB(),
        where: "id = ?", whereArgs: [newProfile.id]);
    return res;
  }

  Future<Profile> getByUuid(String uuid) async {
    final db = await dbProvider.database;
    var res = await db.query("profile", where: "uuid = ?", whereArgs: [uuid]);
    return res.isNotEmpty ? Profile.fromDB(res.first) : null;
  }

  Future<List<Profile>> getBlocked() async {
    final db = await dbProvider.database;

    print("works");
    var res = await db.query("Profile", where: "blocked = ? ", whereArgs: [1]);

    List<Profile> list =
        res.isNotEmpty ? res.map((c) => Profile.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Profile>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("Profile");
    List<Profile> list =
        res.isNotEmpty ? res.map((c) => Profile.fromMap(c)).toList() : [];
    return list;
  }

  deleteById(int id) async {
    final db = await dbProvider.database;
    return db.delete("profile", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("profile");
  }
}
