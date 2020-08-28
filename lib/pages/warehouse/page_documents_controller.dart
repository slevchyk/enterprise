
import 'package:barcode_scan/barcode_scan.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/warehouse/documents_dao.dart';
import 'package:enterprise/database/warehouse/partners_dao.dart';
import 'package:enterprise/database/warehouse/relation_documents_goods_dao.dart';
import 'package:enterprise/database/warehouse/user_goods_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/warehouse/documnets.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/models/warehouse/partners.dart';
import 'package:enterprise/models/warehouse/relation_documents_goods.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsView extends StatefulWidget{
  final Documents currentDocument;
  final bool enableEdit;

  DocumentsView({
    @required this.currentDocument,
    @required this.enableEdit,
  });

  createState() => _DocumentsState();
}

class _DocumentsState extends State<DocumentsView>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _fieldNumber = TextEditingController();
  final _fieldDate = TextEditingController();
  final _fieldPartner = TextEditingController();
  final _fieldGoods = TextEditingController();

  Future<List<Partners>> _partnersList;
  Future<List<Goods>> _goodsList;

  Documents _currentDocument;

  bool _readOnly = true;

  @override
  void initState() {
    _setFields();
    _setControllers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onDoubleTap: () {
          Navigator.pop(context);
        },
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _appBar(context),
          body: Container(
            margin: EdgeInsets.only(right: 20.0),
            child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    _readOnly ?
                        Container() : _currentDocument!=null ?
                            _currentDocument.status ?
                                _setStatus('Робочий', Colors.green) :
                                _setStatus('Чорновик', Colors.blue[800]) :
                                Container(),
                    TextFormField(
                      enabled: _readOnly,
                      controller: _fieldNumber,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.sortNumericDown),
                          suffixIcon: _clearIconButton(_fieldNumber),
                          labelText: 'Номер *',
                          hintText: 'Введiть номер'
                      ),
                      validator: (validator) {
                        if(validator.trim().isEmpty)
                          return 'Ви не вказали номер';
                        if(_isNotNumber(validator))
                          return 'Ви ввели не число';
                        return null;
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          if (_readOnly)
                            FocusScope.of(context).unfocus();
                            _selectDate(context, _fieldDate);
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            enabled: _readOnly,
                            controller: _fieldDate,
                            decoration: InputDecoration(
                              icon: Icon(Icons.date_range),
                              labelText: 'Дата *',
                            ),
                            validator: (validator) {
                              if(validator.trim().isEmpty)
                                return 'Ви не вказали дату';
                              return null;
                            },
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          if(_readOnly)
                            showGeneralDialog(
                              barrierLabel: "partners",
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.5),
                              transitionDuration: Duration(milliseconds: 250),
                              context: context,
                              pageBuilder: (context, anim1, anim2) {
                                return _showPartnersDialog();
                              },
                              transitionBuilder: (context, anim1, anim2, child) {
                                return SlideTransition(
                                  position: Tween(
                                      begin: Offset(0, 1),
                                      end: Offset(0, 0)).animate(anim1),
                                  child: child,
                                );
                              },
                            );
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            enabled: _readOnly,
                            controller: _fieldPartner,
                            decoration: InputDecoration(
                              icon: Icon(Icons.people),
                              labelText: 'Партнер *',
                              hintText: 'Оберiть партнера'
                            ),
                            validator: (validator) {
                              if(validator.trim().isEmpty)
                                return 'Ви не обрали партнера';
                              return null;
                            },
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          if(_readOnly)
                            showGeneralDialog(
                              barrierLabel: "goods",
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.5),
                              transitionDuration: Duration(milliseconds: 250),
                              context: context,
                              pageBuilder: (context, anim1, anim2) {
                                return _showGoodsDialog();
                              },
                              transitionBuilder: (context, anim1, anim2, child) {
                                return SlideTransition(
                                  position: Tween(
                                      begin: Offset(0, 1),
                                      end: Offset(0, 0)).animate(anim1),
                                  child: child,
                                );
                              },
                            );
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            minLines: 1,
                            maxLines: 100,
                            enabled: _readOnly,
                            controller: _fieldGoods,
                            decoration: InputDecoration(
                                icon: Icon(Icons.people),
                                labelText: 'Номенклатура *',
                                hintText: 'Оберiть номенклатуру'
                            ),
                            validator: (validator) {
                              if(validator.trim().isEmpty)
                                return 'Ви не обрали номенклатуру';
                              return null;
                            },
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.menu),
            onPressed: () {
              _showModalBottomSheet();
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _save() async {
    bool _ok = false;

    if (!_formKey.currentState.validate()) {
      return _ok;
    }

    _currentDocument.date = DateTime.parse(formatDate(
        DateFormat("dd-MM-yyyy")
            .parse(_fieldDate.text.replaceAll('.', '-')),
        [yyyy, '-', mm, '-', dd]));
    _currentDocument.partner = _fieldPartner.text;
    _currentDocument.number = int.parse(_fieldNumber.text);

    if(_readOnly && _currentDocument.mobID==null){
      _ok = await _insertIntoDB();
    } else {
      _ok = await _updatePaymentInDB();
    }

    if (_ok) {
      setState(() {
        _readOnly = false;
        ShowSnackBar.show(_scaffoldKey, "Замовлення збережно", Colors.green);
      });
    } else {
      ShowSnackBar.show(_scaffoldKey, "Помилка збереження", Colors.red);
    }

    return _ok;
  }

  Future<bool> _insertIntoDB() async {
    List<bool> _temp = [];
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    _currentDocument.userID = _userID;
    _currentDocument.status = false;
    try {
      _currentDocument.goods.forEach((element) async {
        RelationDocumentsGoods relationDocumentsGoods = RelationDocumentsGoods(
            documentID: await DocumentsDAO().getLastId(),
            goodsID: element.mobID,
        );
        _temp.add(await RelationDocumentsGoodsDAO().insert(relationDocumentsGoods));
      });
      _temp.add(await DocumentsDAO().insert(_currentDocument));
      return _temp.where((element) => element == true)
          .toList().length == _temp.length;
    } catch (_) {
      return false;
    }
  }

  List<Goods> _setGoods(List<Goods> inputGoods){
    inputGoods.forEach((goods) {
      goods.isSelected = true;
      _fieldGoods.text = ""
          "${_fieldGoods.text}"
          "${_fieldGoods.text.isNotEmpty
          ? '\n' : ''}"
          "${goods.name}";
    });
    return inputGoods;
  }

  Future<bool> _updatePaymentInDB() async {
    List<bool> _temp = [];
    try {
      _temp.add(await RelationDocumentsGoodsDAO()
          .deleteById(_currentDocument.mobID) > 0 ?
          true :
          false);
      _currentDocument.goods.forEach((good) async {
        RelationDocumentsGoods relationDocumentsGoods = RelationDocumentsGoods(
          documentID: _currentDocument.mobID,
          goodsID: good.mobID,
        );
        _temp.add(await RelationDocumentsGoodsDAO().insert(relationDocumentsGoods));
      });
      _temp.add(await DocumentsDAO().update(_currentDocument, isModified: true));
      return _temp.where((element) => element == true)
          .toList().length == _temp.length;
    } catch (_) {
      return false;
    }
  }

  Widget _clearIconButton(TextEditingController textController) {
    if (textController.text.isEmpty) {
      return null;
    } else
      return IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => textController.clear());
            setState(() {});
          });
  }

  Widget _setStatus(String status, Color color) {
    return Container(
      margin: EdgeInsets.only(top: 8.0, left: 4.0),
      alignment: Alignment.topLeft,
      child: Row(
        children: <Widget>[
          Opacity(
              child: Icon(
                FontAwesomeIcons.userClock,
                size: 18,
              ),
              opacity: 0.5),
          Container(
            margin: EdgeInsets.only(left: 16.0),
            child: Text(
              'Статус: $status',
              style: TextStyle(fontSize: 15, color: color),
            ),
          )
        ],
      ),
    );
  }

  Widget _showGoodsDialog() {
    FocusScope.of(context).unfocus();
    return StatefulBuilder(
        builder: (context, setState) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 300,
              child: Material(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(40),
                  child: FutureBuilder<List<Goods>>(
                    future: _goodsList,
                    builder: (context, snapshot){
                      if(snapshot.hasData) {
                        return Container(
                          margin: EdgeInsets.only(
                              top: 7,
                              bottom: 7
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot == null
                                ? 0
                                : snapshot.data.length,
                            itemBuilder: (context, int index) {
                              Goods _good = snapshot.data[index];
                              _currentDocument.goods.forEach((good) {
                                if(good.mobID == _good.mobID)_good
                                    .isSelected = true;
                              });
                              return Center(
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      margin: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 5,
                                          bottom: 5
                                      ),
                                      child: CheckboxListTile(
                                        value: _good.isSelected,
                                        title: ListTile(
                                          selected: _good.isSelected,
                                          leading: CircleAvatar(
                                            child: Text('${_good.mobID}'),
                                          ),
                                          title: Text("Номенклатура:"
                                              "\n${_good.name}"),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Одиницi вимiру: ${_good.unit}'),
                                              Text('Кiлькiсть: ${_good.count}'),
                                            ],
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            if(_good.isSelected) {
                                              _good.isSelected = false;
                                              _currentDocument.goods.remove(_good);
                                              _fieldGoods.clear();

                                              _currentDocument.goods.forEach((good) {
                                                _fieldGoods.text = ""
                                                    "${_fieldGoods.text}"
                                                    "${_fieldGoods.text.isNotEmpty
                                                    ? '\n' : ''}"
                                                    "${good.name}";
                                              });
                                            } else {
                                              _currentDocument.goods.add(_good);
                                              _good.isSelected = true;
                                              _fieldGoods.text = ""
                                                  "${_fieldGoods.text}"
                                                  "${_fieldGoods.text.isNotEmpty
                                                  ? '\n' : ''}"
                                                  "${_good.name}";
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  )
              ),
              margin: EdgeInsets.only(
                  top: 50,
                  bottom: 50,
                  left: 12,
                  right: 12
              ),
            ),
          );
        }
    );
  }

  Widget _showPartnersDialog() {
    FocusScope.of(context).unfocus();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 300,
        child: Material(
            borderRadius: BorderRadius.circular(40),
            child: FutureBuilder<List<Partners>>(
              future: _partnersList,
              builder: (context, snapshot){
                if(snapshot.hasData) {
                  return Container(
                    margin: EdgeInsets.only(
                        top: 7,
                        bottom: 7
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot == null
                          ? 0
                          : snapshot.data.length,
                      itemBuilder: (context, int index) {
                        Partners _partner = snapshot.data[index];
                        return InkWell(
                          onTap: () {
                            _fieldPartner.text = _partner.name;
                            Navigator.pop(context);
                          },
                          child: Card(
                            margin: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 5,
                                bottom: 5
                            ),
                            child: Wrap(
                              children: <Widget>[
                                Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${_partner.mobID}'),
//                                     child: _partner.logo == null
//                                      ? Text('${_partner.mobID}')
//                                      : Image.file(_partner.logo),
//                                     Add image of partner to list
//                                     Surround with try{} catch for handle the error
//                                     Add field 'logo' to => warehouse core, partners_dao and models partners
//                                     Check if partner have image, show image, else show id
                                    ),
                                    title: Text("Партнер:\n${_partner.name}"),
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
            )
        ),
        margin: EdgeInsets.only(
            top: 50,
            bottom: 50,
            left: 12,
            right: 12
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      title: Text(_readOnly ? 'Замовлення' : 'Перегляд'),
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
            visible: _currentDocument.mobID == null || _readOnly,
            child: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () async {
                  String scan = await _scan();
                  int _id = _getID(scan);
                  _addScannedGoods(_id);
                }
            ),),
        Visibility(
          visible: _currentDocument.mobID != null,
          child: IconButton(
              icon: Icon(Icons.info),
              onPressed: (){
                FocusScope.of(context).unfocus();
                showGeneralDialog(
                  barrierLabel: 'info',
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.5),
                  transitionDuration: Duration(milliseconds: 250),
                  context: _scaffoldKey.currentContext,
                  transitionBuilder: (context, anim1, anim2, child) {
                    return SlideTransition(
                      position: Tween(
                          begin: Offset(0, -1),
                          end: Offset(0, 0)).animate(anim1),
                      child: child,
                    );
                  },
                  pageBuilder: (context, anim1, anim2) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))
                    ),
                    insetPadding: EdgeInsets.only(top: 200, bottom: 200),
                    content: ListTile(
                      title: Text("Інформація про замовлення"),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'Створений: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatDate(_currentDocument.createdAt, [
                                  dd, '-', mm, '-', yyyy, ' ',
                                  HH, ':', nn, ':', ss
                                ]),
                              ),
                            ],
                          ),
                          _currentDocument.updatedAt
                              .difference(_currentDocument.createdAt)
                              .inSeconds > 0 ? Row(
                            children: <Widget>[
                              Text(
                                'Змінений: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatDate(_currentDocument.updatedAt, [
                                  dd, '-', mm, '-', yyyy, ' ',
                                  HH, ':', nn, ':', ss
                                ]),
                              ),
                            ],
                          ) : Container(),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Назад'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }
          ),
        ),
      ],
    );
  }

  bool _isNotNumber(String input) {
    try {
      int.parse(input.trim());
      return false;
    } on Exception {
      return true;
    }
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

        if (!_readOnly) {
          _menu.add(_exitLT(context));
          _menu.add(_editLT(context));
        } else {
          _menu.add(_undoLT(context));
          _menu.add(_saveExitLT(context));
          _menu.add(_saveLT(context));
        }

        return Theme(
          data: Theme.of(_scaffoldKey.currentContext)
              .copyWith(canvasColor: Colors.transparent),
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

  Future _selectDate(
      BuildContext context, TextEditingController textController) async {
    DateTime picked = await showDatePicker(
        context: context,
        firstDate: DateTime(1991),
        initialDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 1));

    if (picked != null)
      setState(() {
        textController.text = formatDate(picked, [dd, '.', mm, '.', yyyy]);
      });
  }

  void _setFields(){
    _currentDocument = widget.currentDocument;
    _partnersList = PartnersDAO().getAll();
    _goodsList = UserGoodsDAO().getAll();
    _readOnly = widget.enableEdit;
  }

  void _setControllers(){
    if(!_readOnly){
      _fieldNumber.text = _currentDocument.number.toString();
      _fieldDate.text = DateFormat('dd.MM.yyyy').format(_currentDocument.date);
      _fieldPartner.text = _currentDocument.partner;
      _currentDocument.goods = _setGoods(_currentDocument.goods);
    }
  }

  void _handleBottomSheet(String action) async {
    switch (action) {
      case "edit":
        setState(() {
          _readOnly = true;
        });
        break;
      case "undo":
        _setControllers();
        setState(() {
          _readOnly = false;
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

  Future<String> _scan() async {
    try{
      return await BarcodeScanner.scan();
    } on PlatformException catch(e){
      if(e.code == BarcodeScanner.CameraAccessDenied){
        return "Помилка доступу до камери";
      } else {
        return "Помилка $e";
      }
    } on FormatException {
      return "null";
    } catch (e){
      return "$e";
    }
  }

  _addScannedGoods(int id) async {
    Future<Goods> _scannedGood = _goodsList.then((goods) =>
        goods.firstWhere((good) => good.mobID == id, orElse: () => null));
    _scannedGood.then((good) => good != null ?
        _currentDocument.goods.contains(good) ?
            null : _currentDocument.goods.contains(good) ?
            null : _currentDocument.goods.add(_setGoods([good]).first) :
    ShowSnackBar.show(_scaffoldKey, 'Номенклатуру не знайдено', Colors.red));
  }

  int _getID(String input) {
    List<String> _list = input.split(":");
    try {
      switch(_list.length){
        case 2:
          return int.parse(_list.first);
        case 4:
          return int.parse(_list.last);
        default:
          return 0;
      }
    } catch (e){
      return 0;
    }
  }

}