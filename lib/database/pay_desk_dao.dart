import 'package:enterprise/database/core.dart';
import 'package:enterprise/interfaces/pay_desk_dao_interface.dart';
import 'package:enterprise/models/paydesk.dart';

class PayDeskDAO implements PayDeskInterface{
  final dbProvider = DBProvider.db;

  insert(PayDesk payDesk, {bool isModified = true, sync = true}) async {
    final db = await dbProvider.database;

    String createdAt = isModified ? DateTime.now().toString() : payDesk?.createdAt?.toIso8601String() ?? null;

    String updatedAt = isModified ? DateTime.now().toString() : payDesk?.createdAt?.toIso8601String() ?? null;

    var raw = await db.rawInsert(
        'INSERT Into pay_desk ('
        'id,'
        'pay_desk_type,'
        'currency_acc_id,'
        'cost_item_acc_id,'
        'income_item_acc_id,'
        'from_pay_office_acc_id,'
        'to_pay_office_acc_id,'
        'user_id,'
        'amount,'
        'payment,'
        'document_number,'
        'document_date,'
        'files_quantity,'
        'is_checked,'
        'is_read_only,'
        'created_at,'
        'updated_at,'
        'is_deleted,'
        'is_modified'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          payDesk.id,
          payDesk.payDeskType,
          payDesk.currencyAccID,
          payDesk.costItemAccID,
          payDesk.incomeItemAccID,
          payDesk.fromPayOfficeAccID,
          payDesk.toPayOfficeAccID,
          payDesk.userID,
          payDesk.amount,
          payDesk.payment,
          payDesk.documentNumber,
          payDesk.documentDate != null ? payDesk.documentDate.toIso8601String() : null,
          payDesk.filesQuantity,
          payDesk.isChecked,
          payDesk.isReadOnly,
          createdAt,
          updatedAt,
          payDesk.isDeleted,
          isModified,
        ]);

    if (raw.isFinite && payDesk.id == null && sync) {
      await PayDesk.upload();
    }

    return raw;
  }

  Future<PayDesk> getByMobID(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.query("pay_desk", where: "mob_id = ? ", whereArgs: [mobID]);
    return res.isNotEmpty ? PayDesk.fromMap(res.first) : null;
  }

  Future<int> getIdByMobID(int mobID) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery("SELECT id FROM pay_desk WHERE mob_id = ?", [mobID]);
    return res.isNotEmpty ? res.first["id"] : 0;
  }

  Future<PayDesk> getByID(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("pay_desk", where: "id = ? ", whereArgs: [id]);
    return res.isNotEmpty ? PayDesk.fromMap(res.first) : null;
  }

  Future<bool> update(PayDesk payDesk, {bool isModified = true, sync = true}) async {
    final db = await dbProvider.database;

    if (!isModified) {
      sync = false;
    }

    payDesk.isModified = isModified;
    payDesk.updatedAt = DateTime.now();
    var res = await db.update("pay_desk", payDesk.toMap(), where: "mob_id = ?", whereArgs: [payDesk.mobID]);

    if (res.isFinite && sync) {
      await PayDesk.upload();
    }

    return res.isFinite;
  }

  Future<List<PayDesk>> getUnDeleted() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(''
        'SELECT '
        'pd.mob_id, '
        'pd.id, '
        'pd.pay_desk_type, '
        'pd.currency_acc_id, '
        'c.code AS currency_code, '
        'pd.cost_item_acc_id, '
        'ci.name AS cost_item_name, '
        'pd.income_item_acc_id, '
        'ii.name AS income_item_name, '
        'pd.from_pay_office_acc_id, '
        'fpo.name AS from_pay_office_name, '
        'pd.to_pay_office_acc_id, '
        'tpo.name AS to_pay_office_name, '
        'pd.user_id, '
        'pd.amount, '
        'pd.payment, '
        'pd.document_number, '
        'pd.document_date, '
        'pd.files_quantity, '
        'pd.is_checked, '
        'pd.is_read_only, '
        'pd.created_at, '
        'pd.updated_at, '
        'pd.is_deleted, '
        'pd.is_modified '
        'FROM '
        ' pay_desk pd '
        'LEFT JOIN '
        '   currency c '
        ' ON '
        '   pd.currency_acc_id = c.acc_id '
        'LEFT JOIN '
        '   cost_items ci '
        ' ON '
        '   pd.cost_item_acc_id = ci.acc_id '
        'LEFT JOIN '
        '   income_items ii '
        ' ON '
        '   pd.income_item_acc_id = ii.acc_id '
        'LEFT JOIN '
        '   pay_offices fpo '
        ' ON '
        '   pd.from_pay_office_acc_id = fpo.acc_id '
        'LEFT JOIN '
        '   pay_offices tpo '
        ' ON '
        '   pd.to_pay_office_acc_id = tpo.acc_id '
        'WHERE '
        ' pd.is_deleted = 0 '
        'ORDER BY '
        ' pd.id DESC');

    List<PayDesk> list = res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getDeleted() async {
    final db = await dbProvider.database;
    var res = await db.query("pay_desk", where: 'is_deleted=1', orderBy: "id DESC");

    List<PayDesk> list = res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getTransfer() async {
    final db = await dbProvider.database;
    var res =
    await db.rawQuery(
        'SELECT '
        'pd.mob_id, '
        'pd.id, '
        'pd.pay_desk_type, '
        'pd.currency_acc_id, '
        'c.code AS currency_code, '
        'pd.cost_item_acc_id, '
        'ci.name AS cost_item_name, '
        'pd.income_item_acc_id, '
        'ii.name AS income_item_name, '
        'pd.from_pay_office_acc_id, '
        'fpo.name AS from_pay_office_name, '
        'pd.to_pay_office_acc_id, '
        'tpo.name AS to_pay_office_name, '
        'pd.user_id, '
        'pd.amount, '
        'pd.payment, '
        'pd.document_number, '
        'pd.document_date, '
        'pd.files_quantity, '
        'pd.is_checked, '
        'pd.is_read_only, '
        'pd.created_at, '
        'pd.updated_at, '
        'pd.is_deleted, '
        'pd.is_modified '
        'FROM '
        ' pay_desk pd '
        'LEFT JOIN '
        '   currency c '
        ' ON '
        '   pd.currency_acc_id = c.acc_id '
        'LEFT JOIN '
        '   cost_items ci '
        ' ON '
        '   pd.cost_item_acc_id = ci.acc_id '
        'LEFT JOIN '
        '   income_items ii '
        ' ON '
        '   pd.income_item_acc_id = ii.acc_id '
        'LEFT JOIN '
        '   pay_offices fpo '
        ' ON '
        '   pd.from_pay_office_acc_id = fpo.acc_id '
        'LEFT JOIN '
        '   pay_offices tpo '
        ' ON '
        '   pd.to_pay_office_acc_id = tpo.acc_id '
        'WHERE '
        ' pay_desk_type=2 AND is_checked=0 AND pd.is_deleted=0 '
        'ORDER BY '
        ' pd.id DESC');

    List<PayDesk> list =
    res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getByDate(String date) async {
    date = "$date%";
    final db = await dbProvider.database;
    var res =
    await db.rawQuery(
        'SELECT '
            'pd.mob_id, '
            'pd.id, '
            'pd.pay_desk_type, '
            'pd.currency_acc_id, '
            'c.code AS currency_code, '
            'pd.cost_item_acc_id, '
            'ci.name AS cost_item_name, '
            'pd.income_item_acc_id, '
            'ii.name AS income_item_name, '
            'pd.from_pay_office_acc_id, '
            'fpo.name AS from_pay_office_name, '
            'pd.to_pay_office_acc_id, '
            'tpo.name AS to_pay_office_name, '
            'pd.user_id, '
            'pd.amount, '
            'pd.payment, '
            'pd.document_number, '
            'pd.document_date, '
            'pd.files_quantity, '
            'pd.is_checked, '
            'pd.is_read_only, '
            'pd.created_at, '
            'pd.updated_at, '
            'pd.is_deleted, '
            'pd.is_modified '
            'FROM '
            ' pay_desk pd '
            'LEFT JOIN '
            '   currency c '
            ' ON '
            '   pd.currency_acc_id = c.acc_id '
            'LEFT JOIN '
            '   cost_items ci '
            ' ON '
            '   pd.cost_item_acc_id = ci.acc_id '
            'LEFT JOIN '
            '   income_items ii '
            ' ON '
            '   pd.income_item_acc_id = ii.acc_id '
            'LEFT JOIN '
            '   pay_offices fpo '
            ' ON '
            '   pd.from_pay_office_acc_id = fpo.acc_id '
            'LEFT JOIN '
            '   pay_offices tpo '
            ' ON '
            '   pd.to_pay_office_acc_id = tpo.acc_id '
            'where created_at like ?'
            'ORDER BY '
            ' pd.id DESC' ,
        [
          date,
        ]);

    List<PayDesk> list =
    res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getToUpload() async {
    final db = await dbProvider.database;
    var res = await db.query("pay_desk", where: "is_modified = 1");

    List<PayDesk> list = res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getByType(int typeId) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        'SELECT '
            'pd.mob_id, '
            'pd.id, '
            'pd.pay_desk_type, '
            'pd.currency_acc_id, '
            'c.code AS currency_code, '
            'pd.cost_item_acc_id, '
            'ci.name AS cost_item_name, '
            'pd.income_item_acc_id, '
            'ii.name AS income_item_name, '
            'pd.from_pay_office_acc_id, '
            'fpo.name AS from_pay_office_name, '
            'pd.to_pay_office_acc_id, '
            'tpo.name AS to_pay_office_name, '
            'pd.user_id, '
            'pd.amount, '
            'pd.payment, '
            'pd.document_number, '
            'pd.document_date, '
            'pd.files_quantity, '
            'pd.is_checked, '
            'pd.is_read_only, '
            'pd.created_at, '
            'pd.updated_at, '
            'pd.is_deleted, '
            'pd.is_modified '
            'FROM '
            ' pay_desk pd '
            'LEFT JOIN '
            '   currency c '
            ' ON '
            '   pd.currency_acc_id = c.acc_id '
            'LEFT JOIN '
            '   cost_items ci '
            ' ON '
            '   pd.cost_item_acc_id = ci.acc_id '
            'LEFT JOIN '
            '   income_items ii '
            ' ON '
            '   pd.income_item_acc_id = ii.acc_id '
            'LEFT JOIN '
            '   pay_offices fpo '
            ' ON '
            '   pd.from_pay_office_acc_id = fpo.acc_id '
            'LEFT JOIN '
            '   pay_offices tpo '
            ' ON '
            '   pd.to_pay_office_acc_id = tpo.acc_id '
            'WHERE '
            ' pay_desk_type=? AND is_checked=0 '
            'ORDER BY '
            ' pd.id DESC',
        [typeId]
    );

    List<PayDesk> list = res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getByPayOfficeID(String payOfficeID) async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        'SELECT '
            'pd.mob_id, '
            'pd.id, '
            'pd.pay_desk_type, '
            'pd.currency_acc_id, '
            'c.code AS currency_code, '
            'pd.cost_item_acc_id, '
            'ci.name AS cost_item_name, '
            'pd.income_item_acc_id, '
            'ii.name AS income_item_name, '
            'pd.from_pay_office_acc_id, '
            'fpo.name AS from_pay_office_name, '
            'pd.to_pay_office_acc_id, '
            'tpo.name AS to_pay_office_name, '
            'pd.user_id, '
            'pd.amount, '
            'pd.payment, '
            'pd.document_number, '
            'pd.document_date, '
            'pd.files_quantity, '
            'pd.is_checked, '
            'pd.is_read_only, '
            'pd.created_at, '
            'pd.updated_at, '
            'pd.is_deleted, '
            'pd.is_modified '
            'FROM '
            ' pay_desk pd '
            'LEFT JOIN '
            '   currency c '
            ' ON '
            '   pd.currency_acc_id = c.acc_id '
            'LEFT JOIN '
            '   cost_items ci '
            ' ON '
            '   pd.cost_item_acc_id = ci.acc_id '
            'LEFT JOIN '
            '   income_items ii '
            ' ON '
            '   pd.income_item_acc_id = ii.acc_id '
            'LEFT JOIN '
            '   pay_offices fpo '
            ' ON '
            '   pd.from_pay_office_acc_id = fpo.acc_id '
            'LEFT JOIN '
            '   pay_offices tpo '
            ' ON '
            '   pd.to_pay_office_acc_id = tpo.acc_id '
            'WHERE '
            ' from_pay_office_acc_id=? AND is_checked=0 '
            'ORDER BY '
            ' pd.id DESC',
        [payOfficeID]
    );

    List<PayDesk> list = res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<PayDesk>> getAllExceptTransfer() async {
    final db = await dbProvider.database;
    var res = await db.rawQuery(
        'SELECT '
            'pd.mob_id, '
            'pd.id, '
            'pd.pay_desk_type, '
            'pd.currency_acc_id, '
            'c.code AS currency_code, '
            'pd.cost_item_acc_id, '
            'ci.name AS cost_item_name, '
            'pd.income_item_acc_id, '
            'ii.name AS income_item_name, '
            'pd.from_pay_office_acc_id, '
            'fpo.name AS from_pay_office_name, '
            'pd.to_pay_office_acc_id, '
            'tpo.name AS to_pay_office_name, '
            'pd.user_id, '
            'pd.amount, '
            'pd.payment, '
            'pd.document_number, '
            'pd.document_date, '
            'pd.files_quantity, '
            'pd.is_checked, '
            'pd.is_read_only, '
            'pd.created_at, '
            'pd.updated_at, '
            'pd.is_deleted, '
            'pd.is_modified '
            'FROM '
            ' pay_desk pd '
            'LEFT JOIN '
            '   currency c '
            ' ON '
            '   pd.currency_acc_id = c.acc_id '
            'LEFT JOIN '
            '   cost_items ci '
            ' ON '
            '   pd.cost_item_acc_id = ci.acc_id '
            'LEFT JOIN '
            '   income_items ii '
            ' ON '
            '   pd.income_item_acc_id = ii.acc_id '
            'LEFT JOIN '
            '   pay_offices fpo '
            ' ON '
            '   pd.from_pay_office_acc_id = fpo.acc_id '
            'LEFT JOIN '
            '   pay_offices tpo '
            ' ON '
            '   pd.to_pay_office_acc_id = tpo.acc_id '
            'WHERE '
            ' pay_desk_type!=2 AND is_checked=0 '
            'ORDER BY '
            ' pd.id DESC',
    );

    List<PayDesk> list = res.isNotEmpty ? res.map((c) => PayDesk.fromMap(c)).toList() : [];
    return list;
  }

  Future<void> deleteAll() async {
    final db = await dbProvider.database;
    db.delete("pay_desk");
  }
}
