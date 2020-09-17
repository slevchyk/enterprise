
abstract class PayDeskInterface {
  getByMobID(int mobID) async {}
  getByID(int id) async {}
  getUnDeleted() async {}
  getDeleted() async {}
  getTransfer() async {}
  getByDate(String date) async {}
  getToUpload() async {}
  getByType(int typeId) async {}
  getAllExceptTransfer() async {}
}