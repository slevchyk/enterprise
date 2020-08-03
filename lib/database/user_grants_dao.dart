import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/user_grants.dart';

class UserGrantsDAO{
  final dbProvider = DBProvider.db;

  insert(UserGrants userGrants) async {
    final db = await dbProvider.database;

    var raw = await db.rawInsert(
        'INSERT into user_grants ('
        'user_id,'
        'odject_type,'
        'odject_acc_id,'
        'is_visible,'
        'is_available,'
        'is_receiver'
        ')'
        'VALUES (?,?,?,?,?,?)',
        [
          userGrants.userID,
          userGrants.objectType,
          userGrants.objectAccID,
          userGrants.isVisible,
          userGrants.isAvailable,
          userGrants.isReceiver,
        ]
    );
    return raw;
  }

  Future<List<UserGrants>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("user_grants", orderBy: "user_id");
    List<UserGrants> toReturn = res.isNotEmpty ? res.map((ci) => UserGrants.fromMap(ci)).toList() : [];
    return toReturn;
  }

  Future<UserGrants> getByObjectAccID(String objectAccID) async {
    final db = await dbProvider.database;
    var res = await db.query("user_grants", where: "odject_acc_id = ?", whereArgs: [objectAccID]);
    return res.isNotEmpty ? UserGrants.fromMap(res.first) : null;
  }

  Future<bool> update(UserGrants userGrants) async {
    final db = await dbProvider.database;
    var res = await db.update("user_grants", userGrants.toMap(), where: "odject_acc_id = ?", whereArgs: [userGrants.objectAccID]);
    return res.isFinite;
  }
}