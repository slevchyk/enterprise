import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/goods.dart';

class GoodsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(Goods goods) async {
    final db = await dbProvider.database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(mob_id)+1 as mob_id FROM goods");

    if (goods.mobID == null || goods.mobID == 0) {
      goods.mobID = table.first["mob_id"];
    }

    //insert to the table using the new id
    var raw = await db.rawInsert(
        'INSERT Into goods ('
        'mob_id,'
        'id,'
        'acc_id,'
        'is_deleted,'
        'name'
        ')'
        'VALUES (?,?,?,?,?)',
        [goods.mobID, goods.id, goods.accID, goods.isDeleted, goods.name]);
    goods.mobID = raw;
    return raw;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("goods");
  }

  getByMobId(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.query("goods", where: "mob_id = ?", whereArgs: [mobID]);
    return res.isNotEmpty ? Goods.fromMap(res.first) : null;
  }

  Future<List<Goods>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query(
      "goods",
    );

    List<Goods> list =
        res.isNotEmpty ? res.map((c) => Goods.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Goods>> getByName(String query) async {
    query = "%$query%";

    final db = await dbProvider.database;
    var res = await db.query(
      "goods",
      where: "name like ?",
      whereArgs: [query],
    );

    List<Goods> list =
        res.isNotEmpty ? res.map((c) => Goods.fromMap(c)).toList() : [];
    return list;
  }
}
