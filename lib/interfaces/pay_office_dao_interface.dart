abstract class PayOfficeInterface {
  getByID(int id) async {}
  getAllExceptId(String name, String accID) async {}
  getByMobId(int mobID) async {}
  getByAccId(String accID) async {}
  getUnDeletedAndAvailable() async {}
  getAllToTransfer() async {}
  getAll() async {}
  getUnDeleted() async {}
  getByCurrencyAccID(String currencyAccID) async {}
}