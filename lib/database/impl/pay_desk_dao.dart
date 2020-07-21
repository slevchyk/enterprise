
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/database/pay_office_dao.dart';
import 'package:enterprise/interfaces/pay_desk_dao_interface.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';

class ImplPayDeskDao implements PayDeskInterface{
  PayDeskDAO _payDeskDAO = PayDeskDAO();

  @override
  Future<PayDesk> getByMobID(int mobID) async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    PayDesk _payDesk = await _payDeskDAO.getByMobID(mobID);
    return _setData(_payOfficeList, _payDesk);
  }

  @override
  Future<PayDesk> getByID(int id) async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    PayDesk _payDesk = await _payDeskDAO.getByID(id);
    return _setData(_payOfficeList, _payDesk);
  }

  @override
  Future<List<PayDesk>> getUnDeleted() async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getUnDeleted();
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  @override
  Future<List<PayDesk>> getDeleted() async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getDeleted();
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  @override
  Future<List<PayDesk>> getTransfer() async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getTransfer();
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  @override
  Future<List<PayDesk>> getByDate(String date) async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getByDate(date);
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  @override
  Future<List<PayDesk>> getToUpload() async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getToUpload();
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  @override
  Future<List<PayDesk>> getAllExceptTransfer() async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getAllExceptTransfer();
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  @override
  Future<List<PayDesk>> getByType(int typeId) async {
    List<PayOffice> _payOfficeList = await PayOfficeDAO().getUnDeleted();
    List<PayDesk> _payDeskList = await _payDeskDAO.getByType(typeId);
    return _setDataTiList(_payOfficeList, _payDeskList);
  }

  List<PayDesk> _setDataTiList(List<PayOffice> _payOfficeList, List<PayDesk> _payDeskList){
    List<PayDesk> toReturn = [];
    _payOfficeList.forEach((payOffice) {
      _payDeskList.where((payDesk) => payDesk.fromPayOfficeAccID == payOffice.accID)
          .forEach((payDeskOutput) {
            payDeskOutput.fromPayOfficeName = payOffice.name;
            toReturn.add(payDeskOutput);
      });
    });
    return toReturn;
  }

  PayDesk _setData(List<PayOffice> _payOfficeList, PayDesk _payDesk){
    PayDesk toReturn = _payDesk;
    _payOfficeList.where((payOffice) => _payDesk.fromPayOfficeAccID == payOffice.accID)
        .forEach((payOfficeOutput) {
          toReturn.fromPayOfficeName = payOfficeOutput.name;
        });
    return toReturn;
  }
}