import 'package:enterprise/database/warehouse/core.dart';
import 'package:enterprise/models/warehouse/goods.dart';

class UserGoodsDAO {
  final dbProvider = DBWarehouseProvider.db;

  insert(Goods goods, {bool isModified = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified
        ? DateTime.now().toString()
        : goods?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified
        ? DateTime.now().toString()
        : goods?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into user_goods ('
            'user_id,'
            'good_status,'
            'good_count,'
            'good_name,'
            'good_unit,'
            'created_at,'
            'updated_at,'
            'is_modified'
            ')'
            'VALUES (?,?,?,?,?,?,?,?)',
        [
          goods.userID,
          goods.status,
          goods.count,
          goods.name,
          goods.unit,
          createdAt,
          updatedAt,
          isModified,
        ]);
    return raw.isFinite;
  }

  Future<Goods>getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("user_goods" , where: "mob_id = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? Goods.fromMap(res.first) : null;
  }

  Future<List<Goods>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query("user_goods");

    List<Goods> toReturn =
    res.isNotEmpty ? res.map((e) => Goods.fromMap(e)).toList() : [];
    return toReturn;
  }

  Future<List<Goods>> search(String query) async {
    query = "$query%";
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'select * from user_goods '
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

  getLastId() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'SELECT * FROM user_goods ORDER BY mob_id DESC LIMIT 1');

    int toReturn =
    res.isNotEmpty
        ? res.map((e) => Goods.fromMap(e).mobID).toList().first +1
        : 1;
    return toReturn;
  }

  update(Goods goods, {bool isModified = true}) async {
    final db = await dbProvider.database;
    goods.isModified = isModified;
    goods.updatedAt = DateTime.now();
    var res = await db.update("user_goods", goods.toMap(),
        where: "mob_id = ?", whereArgs: [goods.mobID]);
    return res.isFinite;
  }

  deleteById(int docID) async {
    final db = await dbProvider.database;
    var res = await db.delete("user_goods",
        where: "document_id = ?",
        whereArgs: [docID]
    );
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("user_goods");
  }

}
