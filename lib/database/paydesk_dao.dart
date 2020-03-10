import 'package:enterprise/database/core.dart';
import 'package:enterprise/models/pay.dart';

class PayDeskDAO {
  final dbProvider = DBProvider.db;

   insert(Pay pay) async {
    final db = await dbProvider.database;
    var raw = await db.rawInsert(
        'INSERT Into paydesk ('
            'user_id,'
            'payment_status,'
            'amount,'
            'payment,'
            'confirming,'
            'date,'
            'files'
            ')'
            'VALUES (?,?,?,?,?,?,?)',
        [
          pay.userID,
          pay.paymentStatus,
          pay.amount,
          pay.payment,
          pay.confirming,
          pay.date != null
              ? pay.date.toIso8601String()
              : null,
          pay.files,
        ]);
    return raw.isFinite;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("paydesk", where: "id = ? ",
        whereArgs: [id]);
    return res.isNotEmpty ? Pay.fromMap(res.first) : null;
  }

  getLastId() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery("SELECT id FROM paydesk");
    return _getNumber(res);
  }

  int _getNumber(var text){
     try {
       String test = text.last.toString()
           .replaceAll('{','')
           .replaceAll('}', '')
           .replaceAll(':', '')
           .replaceAll('id', '');
       return int.parse(test);
     } catch (exception) {
       return 0;
     }
  }

  update(Pay pay) async {
    final db = await dbProvider.database;
    var res = await db.update("paydesk", pay.toMap(),
    where: "id = ?", whereArgs: [pay.id]);
    return res;
  }

}