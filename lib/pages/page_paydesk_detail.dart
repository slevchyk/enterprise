import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/currency_dao.dart';
import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/database/pay_office_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/attachments_carousel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PagePayDeskDetail extends StatefulWidget {
  final PayDesk payDesk;
  final Profile profile;

  PagePayDeskDetail({
    this.payDesk,
    this.profile,
  });

  @override
  createState() => _PagePayDeskDetailState();
}

class _PagePayDeskDetailState extends State<PagePayDeskDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _currencyController = TextEditingController();
  final _paymentController = TextEditingController();
  final _costItemController = TextEditingController();
  final _incomeItemController = TextEditingController();
  final _fromPayOfficeController = TextEditingController();
  final _toPayOfficeController = TextEditingController();
  final _documentDateController = TextEditingController();
  final _documentTimeController = TextEditingController();
//  final _documentNumberController = TextEditingController();
//  final _documentDateController = TextEditingController();

//  Future<List<Currency>> _currencyList;
  Future<List<CostItem>> _costItemsList;
  Future<List<IncomeItem>> _incomeItemsList;
  Future<List<PayOffice>> _payOfficeList;

  PayDesk _payDesk;
  Profile profile;

  double _amount, _currentValue;
//  DateTime _documentDate;
  String _appPath;

  Currency _currency;
  CostItem _costItem;
  IncomeItem _incomeItem;
  PayOffice _fromPayOffice, _toPayOffice;

  PayDeskTypes _currentType;

  bool _readOnly = false;

  final List<IconData> _icons = const [Icons.image, FontAwesomeIcons.filePdf, Icons.photo_camera];

  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAsync());

    _currentValue = 0;
//    _currencyList = CurrencyDAO().getUnDeleted();
    _costItemsList = CostItemDAO().getUnDeleted();
    _incomeItemsList = IncomeItemDAO().getUnDeleted();
    _payOfficeList = ImplPayOfficeDAO().getAll();
    _payDesk = widget.payDesk ?? PayDesk();
    _readOnly = _payDesk?.mobID != null;
    profile = widget.profile;
    _setControllers();
    _setDefaultPayOffice();
  }
  _setDefaultPayOffice(){
     _payOfficeList.then((payOfficeList) {
       try{
         _setPayOfficeAndCurrency(payOfficeList.first);
       } catch (e){
         print("no items $e");
      }
     });
  }

  _setPayOfficeAndCurrency(PayOffice input){
    _fromPayOfficeController.text = input.name;
    _fromPayOffice = input;
    CurrencyDAO().getByAccId(input.currencyAccID).then((currency) =>
        setState((){
          _currency = currency;
        })
    );
  }

  Future<void> initAsync() async {
    getApplicationDocumentsDirectory().then((value) {
      setState(() {
        _appPath = value.path;
      });
    });

    Currency _c;
    CostItem _ci;
    IncomeItem _ii;
    PayOffice _fpo;
    PayOffice _tpo;

    if (_payDesk?.currencyAccID == null) {
      _c = Currency();
    } else {
      _c = await CurrencyDAO().getByAccId(_payDesk.currencyAccID);
    }

    if (_payDesk?.costItemAccID == null) {
      _ci = CostItem();
    } else {
      _ci = await CostItemDAO().getByAccId(_payDesk.costItemAccID);
    }

    if (_payDesk?.incomeItemAccID == null) {
      _ii = IncomeItem();
    } else {
      _ii = await IncomeItemDAO().getByAccId(_payDesk.incomeItemAccID);
    }

    if (_payDesk?.fromPayOfficeAccID == null) {
      _fpo = PayOffice();
    } else {
      _fpo = await PayOfficeDAO().getByAccId(_payDesk.fromPayOfficeAccID);
    }

    if (_payDesk?.toPayOfficeAccID == null) {
      _tpo = PayOffice();
    } else {
      _tpo = await PayOfficeDAO().getByAccId(_payDesk.toPayOfficeAccID);
    }

    setState(() {
      _currency = _c;
      _costItem = _ci;
      _incomeItem = _ii;
      _fromPayOffice = _fpo;
      _toPayOffice = _tpo;
    });

    _currencyController.text = _currency?.name ?? '';
//    _costItemController.text = _costItem?.name ?? '';
    _costItemController.text = _setField(_costItem?.name ?? '');
    _incomeItemController.text = _incomeItem?.name ?? '';
    _fromPayOfficeController.text = _fromPayOffice?.name ?? '';
    _toPayOfficeController.text = _toPayOffice?.name ?? '';
  }

  _setField(String input){
    if(input.length>=35 && MediaQuery.of(this.context).orientation == Orientation.portrait){
      return "${input.substring(0,35)}...";
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Операція',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _paymentType(PayDeskTypes.costs),
                    SizedBox(
                      width: 10.0,
                    ),
                    _paymentType(PayDeskTypes.income),
                    SizedBox(
                      width: 10.0,
                    ),
                    _paymentType(PayDeskTypes.transfer),
                  ],
                ),
                SizedBox(
                  height: 24.0,
                ),
                Text(
                  'Основне',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: <Widget>[
//                      InkWell(
//                        onTap: () {
//                          if (!_readOnly)
//                            showGeneralDialog(
//                              barrierLabel: "currency",
//                              barrierDismissible: true,
//                              barrierColor: Colors.black.withOpacity(0.5),
//                              transitionDuration: Duration(milliseconds: 250),
//                              context: this.context,
//                              pageBuilder: (context, anim1, anim2) {
//                                return _selectionDialog(
//                                    _currencyController, _currencyList, payDeskVariablesTypes.currency, _scaffoldKey);
//                              },
//                              transitionBuilder: (context, anim1, anim2, child) {
//                                return SlideTransition(
//                                  position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
//                                  child: child,
//                                );
//                              },
//                            );
//                        },
//                        child: IgnorePointer(
//                          child: TextFormField(
//                            enabled: !_readOnly,
//                            controller: _currencyController,
//                            decoration: InputDecoration(
//                                icon: Icon(FontAwesomeIcons.moneyBillAlt),
//                                labelText: 'Валюта*',
//                                hintText: 'Оберiть валюту'),
//                            validator: (value) {
//                              if (value.trim().isEmpty) return 'Ви не вибради валюту';
//                              return null;
//                            },
//                          ),
//                        ),
//                      ),
                      Container(
                        child: InkWell(
                          onTap: () {
                            if (!_readOnly)
                              showGeneralDialog(
                                barrierLabel: "fromPayOffices",
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration: Duration(milliseconds: 250),
                                context: context,
                                pageBuilder: (context, anim1, anim2) {
                                  return _selectionDialog(
                                    _fromPayOfficeController,
                                    _payOfficeList,
                                    payDeskVariablesTypes.fromPayOffice,
                                    _scaffoldKey,
                                  );
                                },
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                                    child: child,
                                  );
                                },
                              );
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              enabled: !_readOnly,
                              controller: _fromPayOfficeController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_balance_wallet),
                                  labelText: 'Гаманець *',
                                  hintText: 'Оберiть гаманець'),
                              validator: (value) {
                                if (value.trim().isEmpty) return 'Ви не обрали гаманець';
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _currentType == PayDeskTypes.transfer,
                        child: InkWell(
                          onTap: () {
                            if (!_readOnly)
                              showGeneralDialog(
                                barrierLabel: "toPayOffices",
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration: Duration(milliseconds: 250),
                                context: this.context,
                                pageBuilder: (context, anim1, anim2) {
                                  return _selectionDialog(
                                    _toPayOfficeController,
                                    ImplPayOfficeDAO().getAllExceptId(_fromPayOffice.name, _fromPayOffice.currencyAccID),
                                    payDeskVariablesTypes.toPayOffice,
                                    _scaffoldKey,
                                  );
                                },
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                                    child: child,
                                  );
                                },
                              );
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              enabled: !_readOnly,
                              controller: _toPayOfficeController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_balance_wallet),
                                  labelText: 'Гаманець отримувач*',
                                  hintText: 'Оберiть гаманець отримувача'),
                              validator: (value) {
                                if (value.trim().isEmpty) return 'Ви не гаманець отримувач';
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        enabled: !_readOnly,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        controller: _amountController,
                        decoration: InputDecoration(
                          icon: SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: Text(
                              CURRENCY_SYMBOL[_currency?.code] == null ? '' : CURRENCY_SYMBOL[_currency.code],
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(FontAwesomeIcons.calculator, size: 22,),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Wrap(
                                            children: <Widget>[
                                              SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.5,
                                                child: _calc(context),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: MediaQuery.of(context).size.width/2,
                                                    child: RaisedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                        _currentValue = 0;
                                                      },
                                                      child: Text("Вiдмiнити"),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width/2,
                                                    child: RaisedButton(
                                                      color: Colors.green,
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                        if(_currentValue!=0){
                                                          _amount = _currentValue;
                                                          _amountController.text = _currentValue.toStringAsFixed(2);
                                                          _currentValue = 0;
                                                        }
                                                      },
                                                      child: Text("Додати", style: TextStyle(color: Colors.white),),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          );
                                        });
                                  }),
                              _clearIconButton(_amountController)!=null
                                  ? _clearIconButton(_amountController)
                                  : Container(),
                            ],
                          ),
                          hintText: 'Вкажiть суму',
                          labelText: 'Сума*',
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        validator: (value) {
                          String _input = value.trim().replaceAll(',', '.');
                          if (_input.isEmpty) return 'Ви не вказали суму';
                          if (_isNotNumber(_input)) return 'Ви ввели не число';
                          if (_isNotCorrectAmount(_input)) return 'Некоректно введена сума';
                          _amount = double.parse(_input);
                          return null;
                        },
                      ),
                      Visibility(
                        visible: _currentType == PayDeskTypes.costs,
                        child: InkWell(
                          onTap: () {
                            if (!_readOnly)
                              showGeneralDialog(
                                barrierLabel: "costItems",
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration: Duration(milliseconds: 250),
                                context: this.context,
                                pageBuilder: (context, anim1, anim2) {
                                  return _selectionDialog(
                                    _costItemController,
                                    _costItemsList,
                                    payDeskVariablesTypes.costItem,
                                    _scaffoldKey,
                                  );
                                },
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                                    child: child,
                                  );
                                },
                              );
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              enabled: !_readOnly,
                              controller: _costItemController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_balance_wallet),
                                  labelText: 'Стаття витрат*',
                                  hintText: 'Оберiть статтю витрат'),
                              validator: (value) {
                                if (value.trim().isEmpty) return 'Ви не обрали статтю витрат';
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _currentType == PayDeskTypes.income,
                        child: InkWell(
                          onTap: () {
                            if (!_readOnly)
                              showGeneralDialog(
                                barrierLabel: "incomeItems",
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration: Duration(milliseconds: 250),
                                context: this.context,
                                pageBuilder: (context, anim1, anim2) {
                                  return _selectionDialog(
                                    _incomeItemController,
                                    _incomeItemsList,
                                    payDeskVariablesTypes.incomeItem,
                                    _scaffoldKey,
                                  );
                                },
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                                    child: child,
                                  );
                                },
                              );
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              enabled: !_readOnly,
                              controller: _incomeItemController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_balance_wallet),
                                  labelText: 'Стаття доходів*',
                                  hintText: 'Оберiть статтю доходів'),
                              validator: (value) {
                                if (value.trim().isEmpty) return 'Ви не обрали статтю доходів';
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        enabled: !_readOnly,
                        controller: _paymentController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.pen),
                          suffixIcon: _clearIconButton(_paymentController),
                          hintText: 'Вкажiть призначення платежу',
                          labelText: 'Призначення платежу*',
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        validator: (value) {
//                          if (value.isEmpty) return 'Ви не вказали призначення платежу';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text("Дата операції",
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
                ),
                Container(
                  padding: EdgeInsets.only(left: 25, right: MediaQuery.of(context).orientation==Orientation.portrait? 50 : 100 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 125,
                        child: InkWell(
                          onTap: () async {
                            if (_readOnly) {
                              return;
                            }
                            FocusScope.of(this.context).unfocus();
                            DateTime picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(DateTime.now().year - 1),
                                initialDate: _payDesk?.documentDate != null ? _payDesk.documentDate : DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1));

                            if (picked != null) {
                              if(picked.isAfter(DateTime.now())){
                                _displaySnackBar("Дата операції не повинна перевищувати поточну дату",  Colors.amber.shade700);
                                return;
                              }
                              setState(() {
                                MaterialLocalizations localizations = MaterialLocalizations.of(context);
                                String formattedTime = localizations.formatTimeOfDay(
                                    TimeOfDay.now(),
                                    alwaysUse24HourFormat: true
                                );
                                _documentDateController.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                                _documentTimeController.text = formattedTime;
                              });
                            }

                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _documentDateController,
                              enabled: !_readOnly,
                              decoration: InputDecoration(
                                  icon: Icon(FontAwesomeIcons.calendar),
                                  labelText: "Дата"
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 85,
                        child: InkWell(
                          onTap: () async {
                            if (_readOnly) {
                              return;
                            }
                            FocusScope.of(this.context).unfocus();
                            TimeOfDay selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if(selectedTime==null){
                              return;
                            }

                            MaterialLocalizations localizations = MaterialLocalizations.of(context);
                            String formattedTime = localizations.formatTimeOfDay(
                                selectedTime,
                                alwaysUse24HourFormat: true
                            );

                            if (DateFormat("dd.MM.yyyy").parse("${_documentDateController.text}").isAtSameMomentAs(DateFormat("yyyy-MM-dd").parse(DateTime.now().toString())) && (selectedTime.hour * 60 + selectedTime.minute) > (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute)){
                              _displaySnackBar("Час операції не повинен перевищувати поточний час",  Colors.amber.shade700);
                              return;
                            }

                            if (formattedTime != null) {
                              setState(() {
                                _documentTimeController.text = formattedTime;
                              });
                              }
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _documentTimeController,
                              enabled: !_readOnly,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.timer),
                                  labelText: "Час"
                              ),
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ),
//                SizedBox(
//                  height: 24.0,
//                ),
//                Text(
//                  'Підтверджуючий документ',
//                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//                ),
//                Container(
//                  margin: EdgeInsets.only(left: 20.0),
//                  child: Column(
//                    children: <Widget>[
//                      TextFormField(
//                        enabled: !_readOnly,
//                        controller: _documentNumberController,
//                        decoration: InputDecoration(
//                          icon: SizedBox(
//                            width: 24.0,
//                            child: Text(
//                              '\u2116',
//                              style: TextStyle(
//                                  fontSize: 24.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
//                            ),
//                          ),
//                          suffixIcon: _clearIconButton(_documentNumberController),
//                          hintText: 'номер чеку',
//                          labelText: 'Номер',
//                        ),
//                        onChanged: (_) {
//                          setState(() {});
//                        },
//                      ),
//                      InkWell(
//                        onLongPress: () {
//                          if (!_readOnly) {
//                            _documentDateController.clear();
//                            setState(() {
//                              _payDesk.documentDate = null;
//                              _documentDate = null;
//                            });
//                          }
//                        },
//                        onTap: () async {
//                          if (_readOnly) {
//                            return;
//                          }
//                          FocusScope.of(this.context).unfocus();
//                          DateTime picked = await showDatePicker(
//                              context: context,
//                              firstDate: DateTime(DateTime.now().year - 1),
//                              initialDate: _payDesk?.documentDate != null ? _payDesk.documentDate : DateTime.now(),
//                              lastDate: DateTime(DateTime.now().year + 1));
//
//                          if (picked != null)
//                            setState(() {
//                              _documentDate = picked;
//                              _documentDateController.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
//                            });
//                        },
//                        child: IgnorePointer(
//                          child: TextFormField(
//                            controller: _documentDateController,
//                            readOnly: _readOnly,
//                            decoration: InputDecoration(
//                              icon: Icon(FontAwesomeIcons.calendar),
//                              labelText: 'Дата',
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
                Visibility(
                  visible: _files.length > 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 24.0,
                      ),
                      Text(
                        'Прикріплені файли',
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      AttachmentsCarousel(
                        files: _files,
                        readOnly: _readOnly,
                        onDelete: (deletedFile) {
                          _files.remove(deletedFile);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.menu),
        onPressed: () {
          _showModalBottomSheet();
        },
      ),
      bottomNavigationBar: _payDesk.payDeskType == 2
          && !_payDesk.isChecked
          && _readOnly ? _confirmButton() : _setNavigationBar(),
    );
  }

  Widget _confirmButton(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 7.0),
      child: ChoiceChip(
        padding: EdgeInsets.all(5.0),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Пiдтвердити",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ],
        ),
        selected: true,
        selectedColor: Colors.green,
        onSelected: (bool value) {
          _confirmingDialog();
        },
      ),
    );
  }

  _confirmingDialog(){
    showGeneralDialog(
      barrierLabel: 'confirmDialog',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: Duration(milliseconds: 250),
      context: _scaffoldKey.currentContext,
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
              begin: Offset(0, 1),
              end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        content: ListTile(
          title: Container(
            height: 60,
            alignment: Alignment.center,
            child: Text("Пiдтвердження переказу", style: TextStyle(
                fontWeight: FontWeight.bold
            ),),
          ),
          subtitle: Container(
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Дата", style: TextStyle(fontWeight: FontWeight.w800),),
                SizedBox(height: 4,),
                Text('${formatDate(
                  _payDesk.createdAt,
                  [dd, '.', mm, '.', yyyy, ' ', HH, ':', nn, ':', ss,],
                )}\n', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                Row(
                  children: <Widget>[
                  ],
                ),
                Text("Сума ", style: TextStyle(fontWeight: FontWeight.w800),),
                SizedBox(height: 4,),
                Text("${_amountController.text} ${String.fromCharCode(0x000020B4)}\n",
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                Row(
                  children: <Widget>[
                  ],
                ),
                Text("З гаманьця ", style: TextStyle(fontWeight: FontWeight.w800),),
                SizedBox(height: 4,),
                Text("${_fromPayOfficeController.text}\n",
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                Text("На гаменець ", style: TextStyle(fontWeight: FontWeight.w800),),
                SizedBox(height: 4,),
                Text("${_toPayOfficeController.text}",
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      color: Color.fromARGB(80, 90, 90, 90),
                      child: Text('Вiдмiнити', style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0))
                      ),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0))
                      ),
                      color: Colors.green,
                      child: Text('Так', style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        _payDesk.isChecked = true;
                        _save().whenComplete(() => _closeWindow(context));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _closeWindow(BuildContext context){
    Navigator.of(context).pop();
    Navigator.pop(_scaffoldKey.currentContext);
  }

  Widget _paymentType(PayDeskTypes _type) {
    return ChoiceChip(
      padding: EdgeInsets.all(5.0),
      label: Row(
        children: <Widget>[
          SizedBox(
            width: 5.0,
          ),
          Text(
            PAY_DESK_TYPES_ALIAS[_type],
            style: TextStyle(
              color: _currentType == _type ? Colors.white : Theme.of(this.context).textTheme.caption.color,
            ),
          ),
        ],
      ),
      backgroundColor: _currentType == _type ? Colors.green : Colors.grey.shade100,
      selectedColor: Colors.green,
      selected: _currentType == _type,
      onSelected: (bool value) {
        if (!_readOnly) {
          setState(() {
            _currentType = _type;

            switch (_type) {
              case PayDeskTypes.costs:
                _incomeItemController.text = '';
                _incomeItem = IncomeItem();
                _toPayOfficeController.text = '';
                _toPayOfficeController.text = '';
                break;
              case PayDeskTypes.income:
                _costItemController.text = '';
                _costItem = CostItem();
                _toPayOfficeController.text = '';
                _toPayOffice = PayOffice();
                break;
              case PayDeskTypes.transfer:
                _incomeItemController.text = "";
                _incomeItem = IncomeItem();
                _toPayOfficeController.text = "";
                _toPayOffice = PayOffice();
                break;
            }
          });
        }
      },
    );
  }

  Widget _clearIconButton(TextEditingController textController) {
    if (_readOnly || textController.text.isEmpty)
      return null;
    else
      return IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              textController.clear();
            });
          });
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      title: Text(!_readOnly ? 'Новий платiж' : 'Платіж'),
      leading: FlatButton(
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        Visibility(
          visible: _payDesk.mobID != null,
          child: FlatButton(
              child: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: _scaffoldKey.currentContext,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    insetPadding: MediaQuery.of(context).orientation == Orientation.landscape ? EdgeInsets.only() : EdgeInsets.only(top: 200, bottom: 200),
                    content: ListTile(
                      title: Container(
                        height: 40,
                        child: Column(
                          children: <Widget>[
                            Text("Інформація про операцiю", style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(height: 2,),
                            Text("${PAY_DESK_TYPES_ALIAS.values.elementAt(_payDesk.payDeskType)}", style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Дата документа: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            formatDate(_payDesk.documentDate, [
                              dd, '-', mm, '-', yyyy, ' ',
                              HH, ':', nn,
                            ]),
                          ),
                          SizedBox(height: 15,),
                          Text(
                            'Документ створено: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            formatDate(_payDesk.createdAt, [
                              dd, '-', mm, '-', yyyy, ' ',
                              HH, ':', nn, ':', ss,
                            ]),
                          ),
                          _payDesk.updatedAt.difference(_payDesk.createdAt).inSeconds > 0
                              ? Column(
                                  children: <Widget>[
                                    SizedBox(height: 15,),
                                    Text(
                                      'Документ був змінений: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5,),
                                    Text(
                                      formatDate(
                                          _payDesk.updatedAt,
                                          [dd, '-', mm, '-', yyyy, ' ',
                                            HH, ':', nn, ':', ss]),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Гаразд'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _setNavigationBar() {
    if (!_readOnly) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_icons.length, (int index) {
          Widget child = Container(
            child: FlatButton(
              child: Icon(_icons[index]),
              onPressed: () {
                if (_files.length >= 4) {
                  _displaySnackBar("Вже досягнута максимальна кількість файлів: 4", Colors.redAccent);
                  return;
                }

                switch (index) {
                  case 0:
                    _getFile(FileType.IMAGE);
                    break;
                  case 1:
                    _getFile(FileType.CUSTOM);
                    break;
                  case 2:
                    _getImageCamera();
                    break;
                  default:
                    _getFile(FileType.IMAGE);
                }
              },
            ),
          );
          return child;
        }),
      );
    }
    return null;
  }

  Widget _selectionDialog(TextEditingController _inputController, Future<List> _input, payDeskVariablesTypes _varType,
      GlobalKey<ScaffoldState> _scaffoldKey) {
    FocusScope.of(this.context).unfocus();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 300,
        child: Material(
            borderRadius: BorderRadius.circular(40),
            child: FutureBuilder<List>(
              future: _input,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.length == 0) {
                    return Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20.0),
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Text(
                          'Немає даних для вибору',
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Container(
                    margin: EdgeInsets.only(top: 0, bottom: 7),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot == null ? 0 : snapshot.data.length,
                      itemBuilder: (context, int index) {
                        var _data = snapshot.data[index];
                        return InkWell(
                          onTap: () {
                            _inputController.text = _data.name;
                            setState(() {
                              switch (_varType) {
                                case payDeskVariablesTypes.currency:
                                  _currency = _data;

                                  if (_fromPayOffice?.currencyAccID != null &&
                                      _fromPayOffice.currencyAccID != _data.accID) {
                                    _fromPayOfficeController.text = "";
                                    _fromPayOffice = PayOffice();

                                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text('Валюта гаманця не відповідає валюті документа. Гаманець очищено'),
                                      backgroundColor: Colors.amber.shade700,
                                    ));
                                  }

                                  if (_toPayOffice?.currencyAccID != null &&
                                      _toPayOffice.currencyAccID != _data.accID) {
                                    _toPayOfficeController.text = "";
                                    _toPayOffice = PayOffice();

                                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                          'Валюта гаманця отримувача не відповідає валюті документа. Гаманець отримувач очищено'),
                                      backgroundColor: Colors.amber.shade700,
                                    ));
                                  }

                                  break;
                                case payDeskVariablesTypes.costItem:
                                  _costItem = _data;
                                  break;
                                case payDeskVariablesTypes.incomeItem:
                                  _incomeItem = _data;
                                  break;
                                case payDeskVariablesTypes.fromPayOffice:
                                  if(_toPayOfficeController.text.isNotEmpty){
                                    _toPayOffice = null;
                                    _toPayOfficeController.text = "";
                                  }
                                  _fromPayOffice = _data;
                                  CurrencyDAO().getByAccId(_data.currencyAccID)
                                      .then((value) => _currency = value);
                                  break;
                                case payDeskVariablesTypes.toPayOffice:
                                  _toPayOffice = _data;
                                  break;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Card(
                            margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                            child: Wrap(
                              children: <Widget>[
                                Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(_data.name.toString().substring(0, 1).toUpperCase()),
                                    ),
                                    title: Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width/(_data.runtimeType == PayOffice ? 2 : 1.8),
                                          child: Text(_data.name,
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        _data.runtimeType == PayOffice ? Container(
                                          width: 35,
                                          child: Text(_data.currencyName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          ),
                                        ) : Container()
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )),
        margin: EdgeInsets.only(top: 50, bottom: 50, left: 12, right: 12),
      ),
    );
  }

  _showModalBottomSheet() {
    ListTile _editLT(BuildContext context) {
      return ListTile(
        leading: Icon(
          Icons.edit,
          color: Theme.of(_scaffoldKey.currentContext).accentColor,
        ),
        title: Text("Редагувати"),
        onTap: () {
          Navigator.of(context).pop();
          _handleBottomSheet("edit");
        },
      );
    }

    ListTile _saveLT(BuildContext context) {
      return ListTile(
        leading: Icon(
          Icons.save,
          color: Theme.of(_scaffoldKey.currentContext).accentColor,
        ),
        title: Text("Зберегти"),
        onTap: () {
          Navigator.of(context).pop();
          _handleBottomSheet("save");
        },
      );
    }

    ListTile _saveExitLT(BuildContext context) {
      return ListTile(
        leading: Icon(
          Icons.check,
          color: Theme.of(_scaffoldKey.currentContext).accentColor,
        ),
        title: Text("Зберегти і закрити"),
        onTap: () {
          Navigator.of(context).pop();
          _handleBottomSheet("saveExit");
        },
      );
    }

    ListTile _undoLT(BuildContext context) {
      return ListTile(
        leading: Icon(
          Icons.undo,
          color: Theme.of(_scaffoldKey.currentContext).accentColor,
        ),
        title: Text("Відмінити"),
        onTap: () {
          Navigator.of(context).pop();
          _handleBottomSheet("undo");
        },
      );
    }

    ListTile _exitLT(BuildContext context) {
      return ListTile(
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(_scaffoldKey.currentContext).accentColor,
        ),
        title: Text("Закрити"),
        onTap: () {
          Navigator.of(context).pop();
          _handleBottomSheet("exit");
        },
      );
    }

    showModalBottomSheet(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) {
        List<ListTile> _menu = [];

        if (_readOnly) {
          _menu.add(_exitLT(context));
          _menu.add(_editLT(context));
        } else {
          _menu.add(_undoLT(context));
          _menu.add(_saveExitLT(context));
          _menu.add(_saveLT(context));
        }

        return Theme(
          data: Theme.of(_scaffoldKey.currentContext).copyWith(canvasColor: Colors.transparent),
          child: Container(
            color: Colors.grey.shade600,
            child: Container(
              padding: EdgeInsets.all(5.0),
              height: _menu.length * 60.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: ListView.builder(
                  itemCount: _menu.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _menu[index];
                  }),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _save() async {
    bool _ok = false;

    if (!_formKey.currentState.validate()) {
      return _ok;
    }

    PayDesk _existPayDesk;
    if (_payDesk.mobID != null) {
      _existPayDesk = await PayDeskDAO().getByMobID(_payDesk.mobID);
    }

    _payDesk.payDeskType = _currentType.index;
    _payDesk.currencyAccID = _currency?.accID;
    _payDesk.costItemAccID = _costItem?.accID;
    _payDesk.incomeItemAccID = _incomeItem?.accID;
    _payDesk.fromPayOfficeAccID = _fromPayOffice?.accID;
    _payDesk.toPayOfficeAccID = _toPayOffice?.accID;
    _payDesk.userID = profile?.userID;
    _payDesk.amount = _amount;
    _payDesk.payment = _paymentController.text;
//    _payDesk.documentNumber = _documentNumberController.text;
    _payDesk.documentDate = DateFormat("dd.MM.yyyy HH:mm")
        .parse("${_documentDateController.text} ${_documentTimeController.text}");

    if (_existPayDesk == null) {
      _payDesk.mobID = await PayDeskDAO().insert(_payDesk, sync: false);
      if (_payDesk.mobID != null) {
        _payDesk = await PayDeskDAO().getByMobID(_payDesk.mobID);
        _ok = true;
      }
    } else {
      _ok = await PayDeskDAO().update(_payDesk, sync: false);
    }

    if (_ok) {
      _saveAttachments();
    } else {
      _displaySnackBar("Помилка збереження в базі", Colors.red);
    }

    return _ok;
  }

  bool _isNotNumber(String input) {
    try {
      double.parse(input.trim());
      return false;
    } on Exception {
      return true;
    }
  }

  bool _isNotCorrectAmount(String value) {
    //Check if the sum is of type *.xx
    // (Two digits after the period)
    List<String> tmp = value.split('.');
    if ((tmp.last.length <= 2 || tmp.length == 1) && double.parse(tmp.first) >= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool _isNotLimitElement(int files) {
    if (files <= 4) {
      return true;
    }
    _showDialog(title: 'Максимальна кількість', body: 'Досягнуто максимальну кількість файлів - 4');
    return false;
  }

  void _setControllers() {
    _files.clear();
    if (_payDesk != null) {
      List<dynamic> _filesPaths = [];
      if (_payDesk.filePaths != null && _payDesk.filePaths.isNotEmpty) _filesPaths = jsonDecode(_payDesk.filePaths);
      _filesPaths.forEach((value) {
        _files.add(File(value));
      });

      _currencyController.text = _currency?.name ?? '';
      _costItemController.text = _costItem?.name ?? '';
      _incomeItemController.text = _incomeItem?.name ?? '';
      _fromPayOfficeController.text = _fromPayOffice?.name ?? '';
      _toPayOfficeController.text = _toPayOffice?.name ?? '';
      _amountController.text = _payDesk?.amount?.toStringAsFixed(2) ?? "";
      _paymentController.text = _payDesk?.payment ?? "";
//      _documentNumberController.text = _payDesk?.documentNumber ?? "";
//      _documentDateController.text =
//          _payDesk?.documentDate == null ? "" : formatDate(_payDesk.documentDate, [dd, '.', mm, '.', yyyy]);
//      _documentDate = _payDesk?.documentDate ?? null;
      _currentType = _payDesk?.payDeskType == null ? PayDeskTypes.costs : PayDeskTypes.values[_payDesk.payDeskType];

      _documentDateController.text = formatDate(
        _payDesk?.documentDate ?? DateTime.now(),
        [dd, '.', mm, '.', yyyy,],
      );
      _documentTimeController.text = formatDate(
        _payDesk?.documentDate ?? DateTime.now(),
        [HH, ':', nn],
      );
    }
  }

  void _handleBottomSheet(String action) async {
    switch (action) {
      case "edit":
        setState(() {
          _readOnly = false;
        });
        break;
      case "undo":
        _setControllers();
        setState(() {
          _readOnly = true;
        });
        break;
      case "exit":
        Navigator.pop(_scaffoldKey.currentContext);
        break;
      case "save":
        _save();
        break;
      case "saveExit":
        bool _ok = await _save();
        if (_ok) Navigator.pop(_scaffoldKey.currentContext);
    }
  }

  void _displaySnackBar(String title, Color color) {
    final snackBar = SnackBar(
      content: Text(title),
      backgroundColor: color,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _getFile(FileType type) async {
    List<File> files;
    switch (type) {
      case FileType.IMAGE:
        files = await FilePicker.getMultiFile(type: FileType.IMAGE);
        break;
      case FileType.CUSTOM:
        files = await FilePicker.getMultiFile(type: FileType.CUSTOM, fileExtension: 'pdf');
        break;
      default:
        files = await FilePicker.getMultiFile(type: FileType.IMAGE);
    }

    if (files != null) {
      if (_isNotLimitElement((files.length + _files.length))) {
        files.forEach((file) => _files.add(file));
      }
      setState(() {});
    }
  }

  void _showDialog({String title, String body}) {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Закрити"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAttachments() async {
    Directory _dir = Directory('$_appPath/paydesk/${_payDesk.mobID}');
    if (_dir.existsSync()) {
      List<FileSystemEntity> _listFileSystemEntity = _dir.listSync();
      for (var _fileSystemEntity in _listFileSystemEntity) {
        if (_fileSystemEntity is File) {
          for (var _f in _files) {
            if (_fileSystemEntity != _f) {
              _fileSystemEntity.deleteSync();
              break;
            }
          }
        }
      }
    } else {
      _dir.createSync(recursive: true);
    }

    List<File> _newFiles = [];

    for (var _file in _files) {
      if (_file.path.contains(_dir.path)) {
        _newFiles.add(_file);
      } else {
        final _extension = extension(_file.path);

        final _fileBytes = _file.readAsBytesSync();
        String _fileHash = sha256.convert(_fileBytes).toString();

        if (_files.where((value) => value.path.contains(_fileHash)).length > 0) {
          _displaySnackBar("Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
          continue;
        }

        if (_newFiles.where((value) => value.path.contains(_fileHash)).length > 0) {
          _displaySnackBar("Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
          continue;
        }

        File _newFile = _file.copySync('${_dir.path}/$_fileHash$_extension');
        _newFiles.add(_newFile);
      }
    }

    List<String> _filesPaths = [];
    _newFiles.forEach((value) {
      _filesPaths.add(value.path);
    });
    _payDesk.filePaths = jsonEncode(_filesPaths);

    _payDesk.filesQuantity = _newFiles.length;

    PayDeskDAO().update(_payDesk, isModified: true, sync: true);

    setState(() {
      _files = _newFiles;
      _readOnly = true;
    });
  }

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (_isNotLimitElement(_files.length + 1)) {
        if (image != null) _files.add(image);
      }
    });
  }

  Widget _calc(BuildContext context){
    return SimpleCalculator(
      value: _currentValue,
      hideExpression: false,
      hideSurroundingBorder: true,
      onChanged: (key, value, expression) {
        setState(() {
          _currentValue = value;
        });
      },
    );
  }
}

enum payDeskVariablesTypes {
  currency,
  costItem,
  incomeItem,
  fromPayOffice,
  toPayOffice,
}
