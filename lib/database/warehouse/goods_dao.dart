import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/goods.dart';

class GoodsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(Goods goods) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
      'INSERT Into goods ('
          'user_id,'
          'good_status,'
          'good_count,'
          'good_name,'
          'good_unit'
          ')'
          'VALUES (?,?,?,?,?)',
      [
        goods.userID,
        goods.status,
        goods.count,
        goods.name,
        goods.unit
      ]);
    return raw.isFinite;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("goods" , where: "mob_id = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? Goods.fromMap(res.first) : null;
  }

  Future<List<Goods>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("goods");

    List<Goods> toReturn =
    res.isNotEmpty ? res.map((e) => Goods.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<Goods>> search(String query) async {
    query = "$query%";
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'select * from goods '
        'where good_count like ? '
        'OR good_name like ?'
        'OR good_unit like ?'
        ,[
          query,
          query,
          query,
        ]);

    List<Goods> toReturn =
    res.isNotEmpty
        ? res.map((e) => Goods.fromMap(e)).toList()
        : [];
    return toReturn;
  }

  update(Goods goods) async {
    final db = await dbProvider.database;
    var res = await db.update("goods", goods.toMap(),
        where: "mob_id = ?", whereArgs: [goods.mobID]);
    return res;
  }

  deleteById(int id) async {
    final db = await dbProvider.database;
    var res = db.delete("goods", where: "mob_id = ?", whereArgs: [id]);
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("goods");
  }
}
