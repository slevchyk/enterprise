import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/cost_item_dao.dart';
import 'package:enterprise/database/currency_dao.dart';
import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/income_item_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/database/pay_desk_image_dao.dart';
import 'package:enterprise/database/pay_office_dao.dart';
import 'package:enterprise/main.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/paydesk_image.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/attachments_carousel.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class PagePayDeskDetail extends StatefulWidget {
  final PayDesk payDesk;
  final Profile profile;
  final PayDeskTypes type;
  final Function callback;

  PagePayDeskDetail({
    this.payDesk,
    this.profile,
    this.type,
    this.callback,
  });

  @override
  createState() => _PagePayDeskDetailState();
}

class _PagePayDeskDetailState extends State<PagePayDeskDetail> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController();
  final _paymentController = TextEditingController();
  final _costItemController = TextEditingController();
  final _incomeItemController = TextEditingController();
  final _fromPayOfficeController = TextEditingController();
  final _toPayOfficeController = TextEditingController();
  final _documentDateController = TextEditingController();
  final _documentTimeController = TextEditingController();

  Future<List<CostItem>> _costItemsList;
  Future<List<IncomeItem>> _incomeItemsList;
  Future<List<PayOffice>> _payOfficeList;

  PayDesk _payDesk;
  Profile profile;

  double _amount, _currentValue;
  DateTime _now;

  Currency _currency;
  CostItem _costItem;
  IncomeItem _incomeItem;
  PayOffice _fromPayOffice, _toPayOffice;

  PayDeskTypes _currentType;

  bool _readOnly = false;

  List<File> _files = [];
  List<bool> _isError = [false];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAsync());

    _currentValue = 0;
    _costItemsList = CostItemDAO().getUnDeleted();
    _incomeItemsList = IncomeItemDAO().getUnDeleted();
    _payOfficeList = ImplPayOfficeDAO().getUnDeletedAndAvailable();
    _payDesk = widget.payDesk ?? PayDesk();
    _readOnly = _payDesk?.mobID != null;
    profile = widget.profile;
    _setControllers();
    _setDefaultPayOffice();
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(this.context).unfocus();
      },
      child: Scaffold(
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
                                      ImplPayOfficeDAO()
                                          .getAllExceptId(_fromPayOffice.name, _fromPayOffice.currencyAccID),
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
                                Visibility(
                                  visible: !_readOnly,
                                  child: IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.calculator,
                                        size: 22,
                                      ),
                                      onPressed: () {
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
                                                        width: MediaQuery.of(context).size.width / 2,
                                                        child: RaisedButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            _currentValue = 0;
                                                          },
                                                          child: Text("Вiдмiнити"),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(context).size.width / 2,
                                                        child: RaisedButton(
                                                          color: Colors.lightGreen,
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            if (_currentValue != 0) {
                                                              _amount = _currentValue;
                                                              _amountController.text = _currentValue.toStringAsFixed(2);
                                                              _currentValue = 0;
                                                            }
                                                          },
                                                          child: Text(
                                                            "Додати",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            });
                                      }),
                                ),
                                _clearIconButton(_amountController) != null
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
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      "Дата операції",
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 25, right: MediaQuery.of(context).orientation == Orientation.portrait ? 50 : 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 130,
                          child: InkWell(
                            onTap: () async {
                              if (_readOnly) {
                                return;
                              }
                              FocusScope.of(this.context).unfocus();
                              DateTime picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(_now.year - 1),
                                  initialDate: _payDesk?.documentDate != null ? _payDesk.documentDate : DateFormat('dd.MM.yyyy').parse(_documentDateController.text),
                                  lastDate: DateTime(_now.year, _now.month, _now.day));

                              if (picked != null) {
                                setState(() {
                                  MaterialLocalizations localizations = MaterialLocalizations.of(context);
                                  String formattedTime =
                                  localizations.formatTimeOfDay(TimeOfDay.now(), alwaysUse24HourFormat: true);
                                  _documentDateController.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
                                  _documentTimeController.text = formattedTime;
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _documentDateController,
                                enabled: !_readOnly,
                                decoration: InputDecoration(icon: Icon(FontAwesomeIcons.calendar), labelText: "Дата"),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            width: 90,
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
                                if (selectedTime == null) {
                                  return;
                                }

                                MaterialLocalizations localizations = MaterialLocalizations.of(context);
                                String formattedTime =
                                localizations.formatTimeOfDay(selectedTime, alwaysUse24HourFormat: true);

                                if (DateFormat("dd.MM.yyyy")
                                    .parse("${_documentDateController.text}")
                                    .isAtSameMomentAs(DateFormat("yyyy-MM-dd").parse(_now.toString())) &&
                                    (selectedTime.hour * 60 + selectedTime.minute) >
                                        (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute)) {
                                  ShowSnackBar.show(_scaffoldKey,
                                      "Час операції не повинен перевищувати поточний час", Colors.amber.shade700, duration: Duration(milliseconds: 1500));
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
                                  decoration: InputDecoration(icon: Icon(Icons.timer), labelText: "Час"),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
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
                          isError: _isError,
                          onError: _loadImages,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _floatingButton(context),
        bottomSheet: _payDesk.payDeskType == 2 && !_payDesk.isChecked && _readOnly && _toPayOffice != null && _toPayOffice.isAvailable != null && _toPayOffice.isAvailable ? _confirmButton() : SizedBox(),
      ),
    );
  }

  void _setPayOfficeAndCurrency(PayOffice input) {
    _fromPayOfficeController.text = input.name;
    _fromPayOffice = input;
    CurrencyDAO().getByAccId(input.currencyAccID).then((currency) => setState(() {
          _currency = currency;
        }));
  }

  void _setDefaultPayOffice() {
    _payOfficeList.then((payOfficeList) {
      try {
        _setPayOfficeAndCurrency(payOfficeList.first);
      } catch (e, s) {
        FLog.error(
          exception: Exception(e.toString()),
          text: "No items to set as default",
          stacktrace: s,
        );
      }
    });
  }

  void _confirmingDialog() {
    showGeneralDialog(
      barrierLabel: 'confirmDialog',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: Duration(milliseconds: 250),
      context: _scaffoldKey.currentContext,
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: ListTile(
          title: Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              "Пiдтвердження переказу",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Container(
            height: 330,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Дата",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '${formatDate(
                    _payDesk.documentDate,
                    [dd, '.', mm, '.', yyyy, ' ',
                      HH, ':', nn, ':', ss,],
                  )}\n',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Row(
                  children: <Widget>[],
                ),
                Text(
                  "Сума ",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${_amountController.text} ${String.fromCharCode(0x000020B4)}\n",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Row(
                  children: <Widget>[],
                ),
                Text(
                  "З гаманьця ",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${_fromPayOfficeController.text}\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  "На гаменець ",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${_toPayOfficeController.text}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      color: Color.fromARGB(80, 90, 90, 90),
                      child: Text(
                        'Вiдмiнити',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      color: Colors.lightGreen,
                      child: Text(
                        'Так',
                        style: TextStyle(color: Colors.white),
                      ),
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

  void _closeWindow(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.pop(_scaffoldKey.currentContext);
  }

  Widget _confirmButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 7.0),
      child: ChoiceChip(
        padding: EdgeInsets.all(5.0),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Пiдтвердити",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        selected: true,
        selectedColor: Colors.lightGreen,
        onSelected: (bool value) {
          _confirmingDialog();
        },
      ),
    );
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
      backgroundColor: _currentType == _type ? Colors.lightGreen : Colors.grey.shade100,
      selectedColor: Colors.lightGreen,
      selected: _currentType == _type,
      onSelected: (bool value) {
        if (!_readOnly) {
          setState(() {
            _currentType = _type;
            switch (_type) {
              case PayDeskTypes.costs:
                _payOfficeList.then((payOfficeList) {
                  try {
                    _setPayOfficeAndCurrency(payOfficeList.first);
                  } catch (e) {
                    print("no items $e");
                  }
                });
                _incomeItemController.text = '';
                _incomeItem = IncomeItem();
                _toPayOfficeController.text = '';
                _toPayOfficeController.text = '';
                break;
              case PayDeskTypes.income:
                _payOfficeList.then((payOfficeList) {
                  try {
                    _setPayOfficeAndCurrency(payOfficeList.first);
                  } catch (e) {
                    print("no items $e");
                  }
                });
                _costItemController.text = '';
                _costItem = CostItem();
                _toPayOfficeController.text = '';
                _toPayOffice = PayOffice();
                break;
              case PayDeskTypes.transfer:
                _payOfficeList.then((payOfficeList) {
                  try {
                    _setPayOfficeAndCurrency(payOfficeList.first);
                  } catch (e) {
                    print("no items $e");
                  }
                });
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
                _infoDialog();
              }),
        ),
      ],
    );
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
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      itemCount: snapshot == null ? 0 : snapshot.data.length,
                      itemBuilder: (context, int index) {
                        var _data = snapshot.data[index];
                        if(_data.runtimeType == PayOffice){
                          if(_data.amount!=null){
                            _amountFormatter.text = _data.amount.toStringAsFixed(2);
                          } else {
                            _amountFormatter.text = "0.00";
                          }
                        }
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

                                    ShowSnackBar.show(_scaffoldKey,
                                        'Валюта гаманця не відповідає валюті документа. Гаманець очищено', Colors.amber.shade700);
                                  }

                                  if (_toPayOffice?.currencyAccID != null &&
                                      _toPayOffice.currencyAccID != _data.accID) {
                                    _toPayOfficeController.text = "";
                                    _toPayOffice = PayOffice();

                                    ShowSnackBar.show(_scaffoldKey,
                                        'Валюта гаманця отримувача не відповідає валюті документа. Гаманець отримувач очищено', Colors.amber.shade700);
                                  }

                                  break;
                                case payDeskVariablesTypes.costItem:
                                  _costItem = _data;
                                  break;
                                case payDeskVariablesTypes.incomeItem:
                                  _incomeItem = _data;
                                  break;
                                case payDeskVariablesTypes.fromPayOffice:
                                  if (_toPayOfficeController.text.isNotEmpty) {
                                    _toPayOffice = null;
                                    _toPayOfficeController.text = "";
                                  }
                                  _fromPayOffice = _data;
                                  CurrencyDAO().getByAccId(_data.currencyAccID).then((value) => _currency = value);
                                  break;
                                case payDeskVariablesTypes.toPayOffice:
                                  _toPayOffice = _data;
                                  break;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.lightGreen, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(20.0))),
                            margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                            child: Wrap(
                              children: <Widget>[
                                Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: _data.runtimeType == PayOffice ? Text(_data.currencyName) : Text(_data.name.toString().substring(0, 1).toUpperCase()),
                                    ),
                                    title: Column(
                                      children: [
                                        Container(
                                          child: Text(
                                            _data.name,
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        _data.runtimeType == PayOffice && _data.isAvailable
                                            ? Container(
                                          child: Column(
                                            children: [
                                              // Divider(),
                                              Container(height: 1, color: Colors.lightGreen, margin: EdgeInsets.all(5),),
                                              Text(
                                                "Баланс: ${_data.amount.isNegative ? "-" : ""}${_amountFormatter.text} ${CURRENCY_SYMBOL_BY_NAME[_data.currencyName]}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ],
                                          ),
                                        )
                                            : Container()
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

  Widget _floatingButton(BuildContext context){
    return FabCircularMenu(
      fabColor: Colors.lightGreen,
      animationDuration: Duration(milliseconds: 400),
      ringDiameter: 280,
      fabMargin: _readOnly ? EdgeInsets.only(bottom: 50, right: 10) : EdgeInsets.all(16.0),
      ringWidth: 70,
      ringColor: Colors.transparent,
      fabOpenIcon: Icon(Icons.menu, color: Colors.white,),
      fabCloseIcon: Icon(Icons.close, color: Colors.white,),
      children: [
        CircularButton(
          color: Colors.lightGreen,
          width: 55,
          height: 55,
          icon: Icon(
            Icons.undo,
            color: Colors.white,
          ),
          onClick: (){
            Navigator.of(context).pop();
          },
        ),
        _readOnly ? SizedBox() : CircularButton(
          color: Colors.lightGreen,
          width: 40,
          height: 40,
          icon: Icon(
            Icons.photo_camera,
            color: Colors.white,
          ),
          onClick: () {
            if (_files.length >= 4) {
              ShowSnackBar.show(_scaffoldKey, "Вже досягнута максимальна кількість файлів: 4", Colors.redAccent);
              return;
            }
            _getImageCamera();
          },
        ),
        _readOnly ? SizedBox() : CircularButton(
          color: Colors.lightGreen,
          width: 40,
          height: 40,
          icon: Icon(
            Icons.image,
            color: Colors.white,
          ),
          onClick: () async {
            if (_files.length >= 4) {
              ShowSnackBar.show(_scaffoldKey, "Вже досягнута максимальна кількість файлів: 4", Colors.redAccent);
              return;
            }
            var status = await Permission.storage.status;
            switch (status){
              case PermissionStatus.undetermined:
                await Permission.storage.request();
                break;
              case PermissionStatus.granted:
                FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image, allowCompression: true);
                if(result != null){
                  if(_files.length + result.paths.length <=4){
                    result.paths.map((path) => _files.add(File(path))).toList();
                    setState(() {});
                  } else {
                    ShowSnackBar.show(_scaffoldKey, "Вже досягнута максимальна кількість файлів: 4", Colors.redAccent);
                  }
                }
                break;
              case PermissionStatus.denied:
                ShowSnackBar.show(_scaffoldKey, "Надайте доступ на запис файлів в дозволах додатку ", Colors.red, duration: Duration(seconds: 2));
                break;
              case PermissionStatus.restricted:
                ShowSnackBar.show(_scaffoldKey, "Надайте доступ на запис файлів в дозволах додатку ", Colors.red, duration: Duration(seconds: 2));
                break;
              case PermissionStatus.permanentlyDenied:
                ShowSnackBar.show(_scaffoldKey, "Надайте доступ на запис файлів в дозволах додатку ", Colors.red, duration: Duration(seconds: 2));
                break;
            }
          },
        ),
        Visibility(
          visible: _payDesk.mobID==null ? true : !_payDesk.isReadOnly,
          child: CircularButton(
            color: Colors.lightGreen,
            width: 55,
            height: 55,
            icon: Icon(
              _readOnly ? Icons.edit : Icons.save,
              color: Colors.white,
            ),
            onClick: (){
              _readOnly ? _handleBottomSheet("edit") :
              _handleBottomSheet("saveExit");
            },
          ),
        ),
      ],
    );
  }

  Widget _calc(BuildContext context) {
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

  String _setField(String input) {
    if (input.length >= 35 && MediaQuery.of(this.context).orientation == Orientation.portrait) {
      return "${input.substring(0, 35)}...";
    }
    return input;
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
    List<String> _tmp = value.split('.');
    if ((_tmp.last.length <= 2 || _tmp.length == 1) && double.parse(_tmp.first) >= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool _isNotLimitElement(int files) {
    if (files <= 4) {
      return true;
    }
    ShowSnackBar.show(_scaffoldKey, "Досягнуто максимальну кількість файлів - 4", Colors.red) ;
    return false;
  }

  void _setControllers() async {
    _files.clear();
    if (_payDesk != null) {
      if(_payDesk.filesQuantity != null && _payDesk.filesQuantity>0){
        List<PayDeskImage> _pdiList = await PayDeskImageDAO().getUnDeletedByMobID(_payDesk.mobID);
        _pdiList.forEach((element) {
          if(!element.isDeleted){
            _files.add(File(element.path));
          }
        });
        if(_pdiList.length<=0){
          _loadImages();
        }
      }

      _currencyController.text = _currency?.name ?? '';
      _costItemController.text = _costItem?.name ?? '';
      _incomeItemController.text = _incomeItem?.name ?? '';
      _fromPayOfficeController.text = _fromPayOffice?.name ?? '';
      _toPayOfficeController.text = _toPayOffice?.name ?? '';
      _amountController.text = _payDesk?.amount?.toStringAsFixed(2) ?? "";
      _paymentController.text = _payDesk?.payment ?? "";
      _currentType = _payDesk?.payDeskType == null ? widget.type : PayDeskTypes.values[_payDesk.payDeskType];

      _documentDateController.text = formatDate(
        _payDesk?.documentDate ?? _now,
        [dd, '.', mm, '.', yyyy,],
      );
      _documentTimeController.text = formatDate(
        _payDesk?.documentDate ?? _now,
        [HH, ':', nn],
      );
    }
  }

  void _infoDialog(){
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        insetPadding: MediaQuery.of(context).orientation == Orientation.landscape
            ? EdgeInsets.only(top: 55, bottom: 55)
            : EdgeInsets.only(top: 260, bottom: 260),
        content: ListTile(
          title: Container(
            height: 45,
            child: Column(
              children: <Widget>[
                Text(
                  "Інформація про операцiю",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "${PAY_DESK_TYPES_ALIAS.values.elementAt(_payDesk.payDeskType)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
              SizedBox(
                height: 5,
              ),
              Text(
                _payDesk.documentDate == null ? "Iнформацiя вiдсутня" : formatDate(_payDesk.documentDate, [
                  dd, '.', mm, '.', yyyy,
                  ' ', HH, ':', nn,
                ]),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Документ створено: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                _payDesk.createdAt == null ? "Iнформацiя вiдсутня" : formatDate(_payDesk.createdAt, [
                  dd, '.', mm, '.', yyyy,
                  ' ', HH, ':', nn, ':', ss,
                ]),
              ),
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
        if (_ok) {
          Navigator.pop(_scaffoldKey.currentContext);
        }
    }
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
    _payDesk.documentDate =
        DateFormat("dd.MM.yyyy HH:mm").parse("${_documentDateController.text} ${_documentTimeController.text}");

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
      ShowSnackBar.show(_scaffoldKey, "Помилка збереження в базі", Colors.red);
    }
    if(widget.callback!=null){
      widget.callback();
    }
    return _ok;
  }

  Future<void> _saveAttachments() async {

    EnterpriseApp.createApplicationFileDir(action: "pay_desk", scaffoldKey: _scaffoldKey);

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory _dir = Directory('$APPLICATION_FILE_PATH_PAY_DESK_IMAGE/${_payDesk.mobID}');
    if (_dir.existsSync()) {
      List<FileSystemEntity> _listFileSystemEntity = _dir.listSync();
      for (FileSystemEntity _fileSystemEntry in _listFileSystemEntity) {
        List<File> where = _files.where((element) => element.path==_fileSystemEntry.path).toList();
        if(where.length==0){
          _fileSystemEntry.deleteSync(recursive: true);
          await PayDeskImageDAO().setDeleteByPath(_fileSystemEntry.path);
        }
      }
    } else {
      _dir.createSync(recursive: true);
    }

    List<File> _newFiles = [];

    for (File _file in _files) {
      if (_file.path.contains(_dir.path)) {
        _newFiles.add(_file);
      } else {
        final _extension = extension(_file.path);

        final _fileBytes = _file.readAsBytesSync();
        String _fileHash = sha256.convert(_fileBytes).toString();

        if (_files.where((value) => value.path.contains(_fileHash)).length > 0) {
          ShowSnackBar.show(_scaffoldKey, "Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
          continue;
        }

        if (_newFiles.where((value) => value.path.contains(_fileHash)).length > 0) {
          ShowSnackBar.show(_scaffoldKey, "Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
          continue;
        }

        File _newFile = _file.copySync('${_dir.path}/$_fileHash$_extension');
        _newFiles.add(_newFile);

        PayDeskImage pdi = PayDeskImage(mobID: _payDesk.mobID, path: _newFile.path);
        await PayDeskImageDAO().insert(pdi);
      }
    }

    _payDesk.filesQuantity = _newFiles.length;

    PayDeskDAO().update(_payDesk, isModified: true, sync: true);

  }

  Future<void> initAsync() async {

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
    _costItemController.text = _setField(_costItem?.name ?? '');
    _incomeItemController.text = _incomeItem?.name ?? '';
    _fromPayOfficeController.text = _fromPayOffice?.name ?? '';
    _toPayOfficeController.text = _toPayOffice?.name ?? '';
  }

  void _loadImages() async {
    await PayDesk.downloadImagesByPdi(_payDesk, _scaffoldKey).whenComplete(() => setState(() {}));
  }

  Future _getImageCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 70);
    setState(() {
      if (_isNotLimitElement(_files.length + 1)) {
        if (image != null) _files.add(File(image.path));
      }
    });
  }
}

enum payDeskVariablesTypes {
  currency,
  costItem,
  incomeItem,
  fromPayOffice,
  toPayOffice,
}

class CircularButton extends StatelessWidget {

  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton({this.color, this.width, this.height, this.icon, this.onClick});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color,shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon,enableFeedback: true, onPressed: onClick),
    );
  }
}