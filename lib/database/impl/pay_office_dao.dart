
import 'package:enterprise/database/currency_dao.dart';
import 'package:enterprise/database/pay_office_dao.dart';
import 'package:enterprise/interfaces/pay_office_dao_interface.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/pay_office.dart';

class ImplPayOfficeDAO implements PayOfficeInterface{
  PayOfficeDAO _payOfficeDAO = PayOfficeDAO();

  @override
  Future<List<PayOffice>> getAll() async {
    List<Currency> _currencyList = await CurrencyDAO().getAll();
    List<PayOffice> _payOfficeList = await _payOfficeDAO.getAll();
    return _setDataToList(_currencyList, _payOfficeList);
  }

  @override
  Future<List<PayOffice>> getAllExceptId(String name, String accID) async {
    List<Currency> _currencyList = await CurrencyDAO().getAll();
    List<PayOffice> _payOfficeList = await _payOfficeDAO.getAllExceptId(name, accID);
    return _setDataToList(_currencyList, _payOfficeList);
  }


  @override
  Future<PayOffice> getByAccId(String accID) async {
    List<Currency> _currencyList = await CurrencyDAO().getAll();
    PayOffice _payOffice = await _payOfficeDAO.getByAccId(accID);
    return _setData(_currencyList, _payOffice);
  }

  @override
  Future<List<PayOffice>> getByCurrencyAccID(String currencyAccID) async {
    List<Currency> _currencyList = await CurrencyDAO().getAll();
    List<PayOffice> _payOfficeList = await _payOfficeDAO.getByCurrencyAccID(currencyAccID);
    return _setDataToList(_currencyList, _payOfficeList);
  }

  @override
  Future<PayOffice> getByID(int id) async {
    List<Currency> _currencyList = await CurrencyDAO().getAll();
    PayOffice _payOffice = await _payOfficeDAO.getByID(id);
    return _setData(_currencyList, _payOffice);
  }

  @override
  Future<PayOffice> getByMobId(int mobID) async {
  List<Currency> _currencyList = await CurrencyDAO().getAll();
  PayOffice _payOffice = await _payOfficeDAO.getByMobId(mobID);
  return _setData(_currencyList, _payOffice);
  }

  @override
  Future<List<PayOffice>> getUnDeleted() async {
    List<Currency> _currencyList = await CurrencyDAO().getAll();
    List<PayOffice> _payOfficeList = await _payOfficeDAO.getUnDeleted();
    return _setDataToList(_currencyList, _payOfficeList);
  }

  List<PayOffice> _setDataToList(List<Currency> _currencyList, List<PayOffice> _payOfficeList){
    List<PayOffice> toReturn = [];
    _currencyList.forEach((currency) {
      _payOfficeList.where((payOffice) => payOffice.currencyAccID == currency.accID)
          .forEach((payOffice) {
        payOffice.currencyName = CURRENCY_NAME[currency.code];
        toReturn.add(payOffice);
      });
    });
    return toReturn;
  }

  PayOffice _setData(List<Currency> _currencyList, PayOffice _payOffice){
    PayOffice toReturn = _payOffice;
    _currencyList.where((currency) => _payOffice.currencyAccID == currency.accID)
        .forEach((currencyOutput) {
          toReturn.currencyName = CURRENCY_NAME[currencyOutput.code];
    });
    return toReturn;
  }


}