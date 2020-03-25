import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/partners.dart';

class PartnersDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(Partners partners) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
      'INSERT Into partners ('
          'user_id,'
          'partner_name'
          ')'
          'VALUES (?,?)',
      [
        partners.userID,
        partners.name,
      ]
    );
    return raw.isFinite;
  }

  Future<List<Partners>> search(String query) async {
    query = "$query%";
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'select * from partners '
        'where partner_name like ? '
        ,[
          query,
        ]);

    List<Partners> toReturn =
    res.isNotEmpty
        ? res.map((e) => Partners.fromMap(e)).toList()
        : [];
    return toReturn;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("partners" , where: "mob_id = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? Partners.fromMap(res.first) : null;
  }

  Future<List<Partners>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("partners");

    List<Partners> toReturn =
    res.isNotEmpty ? res.map((e) => Partners.fromMap(e)).toList() : [];
    return toReturn;
  }

  update(Partners partners) async {
    final db = await dbProvider.database;
    var res = await db.update("partners", partners.toMap(),
        where: "mob_id = ?", whereArgs: [partners.mobID]);
    return res;
  }
}