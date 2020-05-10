
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/warehouse/goods_dao.dart';
import 'package:enterprise/database/warehouse/user_goods_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoodsView extends StatefulWidget{
  final Goods currentGood;
  final bool enableEdit;
  final bool isNew;

  GoodsView({
    @required this.currentGood,
    @required this.enableEdit,
    @required this.isNew,
  });

  createState() => _GoodsState();
}

class _GoodsState extends State<GoodsView>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _fieldName = TextEditingController();
  final _fieldCount = TextEditingController();
  final _fieldUnit = TextEditingController();

  Future<List<Goods>> _goodsList;

  Goods _currentGood;

  bool _isNew;
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
                    !_isNew && _readOnly ?
                        Container() : _currentGood!=null ?
                            _currentGood.status ?
                                _setStatus('Робочий', Colors.green) :
                                _setStatus('Чорновик', Colors.blue[800]) :
                                Container(),
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
                            enabled: _readOnly,
                            controller: _fieldName,
                            decoration: InputDecoration(
                                icon: Icon(Icons.title),
                                labelText: _isNew ? 'Номенклатура'
                                    : 'Номенклатура *',
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
                    TextFormField(
                      enabled: false,
                      controller: _fieldUnit,
                      decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.sortNumericDown),
                          labelText: _isNew ? 'Одиниця вимiру'
                              : 'Одиниця вимiру *',
                          hintText: 'Введiть одиницю вимiру'
                      ),
                      validator: (validator) {
                        if(validator.trim().isEmpty)
                          return 'Ви не вказали одиницю вимiру';
                        return null;
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    TextFormField(
                      enabled: _readOnly,
                      controller: _fieldCount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.sortNumericDown),
                          suffixIcon: _isNew ? null
                              : _clearIconButton(_fieldCount),
                          labelText: _isNew ? 'Кількість' : 'Кількість *',
                          hintText: 'Введiть кількість'
                      ),
                      validator: (validator) {
                        if(validator.trim().isEmpty)
                          return 'Ви не вказали кількість';
                        if(_isNotNumber(validator))
                          return 'Ви ввели не число';
                        return null;
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    !_isNew && _readOnly ? Container() : Center(
                      child: GestureDetector(
                        onTap: () {
                          showGeneralDialog(
                            barrierLabel: "barCode",
                            barrierDismissible: true,
                            barrierColor: Colors.white.withOpacity(0.95),
                            transitionDuration: Duration(milliseconds: 250),
                            context: context,
                            pageBuilder: (context, anim1, anim2) {
                              return Container(
                                child: Center(
                                  child: BarCodeImage(
                                    params: Code128BarCodeParams(
                                      "${_currentGood.mobID}:"
                                          "${_currentGood.status? 1 : 0}",
                                      lineWidth: 4.0,
                                      barHeight: 120.0,
                                      withText: true,
                                    ),
                                  ),
                                ),
                              );
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
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: BarCodeImage(
                            params: Code128BarCodeParams(
                              "${_currentGood.mobID}:"
                                  "${_currentGood.status? 1 : 0}",
                              lineWidth: 2.0,
                              barHeight: 90.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    !_isNew && _readOnly ? Container() : Center(
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              barrierLabel: "qrCode",
                              barrierDismissible: true,
                              barrierColor: Colors.white.withOpacity(0.95),
                              transitionDuration: Duration(milliseconds: 250),
                              context: context,
                              pageBuilder: (context, anim1, anim2) {
                                return Container(
                                  child: Center(
                                    child: QrImage(
                                      data: "${_currentGood.name}\n"
                                          "${_currentGood.count} : "
                                          "${_currentGood.unit} : "
                                          "${_currentGood.status? 1 : 0} : "
                                          "${_currentGood.mobID}",
                                      version: QrVersions.auto,
                                      gapless: false,
                                      embeddedImage: AssetImage('assets/logo_512.png'),
                                      embeddedImageStyle: QrEmbeddedImageStyle(
                                        size: Size(80, 80),
                                      ),
                                      size: 300,
                                    ),
                                  ),
                                );
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
                          child: RepaintBoundary(
                            child: QrImage(
                              data: "${_currentGood.name}\n"
                                  "${_currentGood.count} : "
                                  "${_currentGood.unit} : "
                                  "${_currentGood.status? 1 : 0} : "
                                  "${_currentGood.mobID}",
                              version: QrVersions.auto,
                              gapless: false,
                              embeddedImage: AssetImage('assets/logo_512.png'),
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: Size(50, 50),
                              ),
                              size: 200,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
            ),
          ),
          floatingActionButton: Visibility(
            visible: !_isNew,
              child: FloatingActionButton(
                onPressed: () {
                  _showModalBottomSheet();
                },
                child: Icon(Icons.menu),
              )
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

    _currentGood.name = _fieldName.text;
    _currentGood.count = int.parse(_fieldCount.text);
    _currentGood.unit = _fieldUnit.text;

    if(_readOnly && _currentGood.mobID==null){
      _ok = await _insertIntoDB();
    } else {
      _ok = await _updatePaymentInDB();
    }

    if (_ok) {
      setState(() {
        _readOnly = true;
        _displaySnackBar(context, "Номенклатуру збережно", Colors.green);
      });
    } else {
      _displaySnackBar(context, "Помилка збереження", Colors.red);
    }

    return _ok;
  }

  Future<bool> _insertIntoDB() async {
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    _currentGood.userID = _userID;
    _currentGood.status = false;
    try {
      return await UserGoodsDAO().insert(_currentGood);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _updatePaymentInDB() async {
    try {
      return await UserGoodsDAO().update(_currentGood, isModified: true);
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 300,
        child: Material(
            borderRadius: BorderRadius.circular(40),
            child: FutureBuilder<List<Goods>>(
              future: _goodsList,
              builder: (context, snapshot){
                if(snapshot.hasData) {
                  return Container(
                    margin: EdgeInsets.only(top: 7, bottom: 7),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot == null
                          ? 0
                          : snapshot.data.length,
                      itemBuilder: (context, int index) {
                        Goods _good = snapshot.data[index];
                        return InkWell(
                          onTap: () {
                            _fieldName.text = _good.name;
                            _fieldUnit.text = _good.unit;
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
                                      child: Text('${_good.mobID}'),
                                    ),
                                    title: Text('Номенклатура: '
                                        '\n${_good.name}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Одиницi вимiру: ${_good.unit}'),
                                        Text('Кiлькiсть: ${_good.count}'),
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
            )
        ),
        margin: EdgeInsets.only(top: 50, bottom: 50, left: 12, right: 12),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      title: Text(_readOnly ? 'Номенклатура' : 'Перегляд'),
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
          visible: _currentGood.mobID != null && !_isNew,
          child: IconButton(
              icon: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
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
                      title: Text("Інформація про номенклатуру"),
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
                                formatDate(_currentGood.createdAt, [
                                  dd,
                                  '-',
                                  mm,
                                  '-',
                                  yyyy,
                                  ' ',
                                  HH,
                                  ':',
                                  nn,
                                  ':',
                                  ss
                                ]),
                              ),
                            ],
                          ),
                          _currentGood.updatedAt
                              .difference(_currentGood.createdAt)
                              .inSeconds > 0 ? Row(
                            children: <Widget>[
                              Text(
                                'Змінений: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatDate(_currentGood.updatedAt, [
                                  dd,
                                  '-',
                                  mm,
                                  '-',
                                  yyyy,
                                  ' ',
                                  HH,
                                  ':',
                                  nn,
                                  ':',
                                  ss
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
              }),
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

  void _setFields(){
    _currentGood = widget.currentGood;
    _isNew = widget.isNew;
    _goodsList = GoodsDAO().getAll();
    _readOnly = widget.enableEdit;
  }

  void _setControllers(){
    if(!_readOnly){
      _fieldName.text = _currentGood.name;
      _fieldCount.text = _currentGood.count.toString();
      _fieldUnit.text = _currentGood.unit;
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

  void _displaySnackBar(BuildContext context, String title, Color color) {
    final snackBar = SnackBar(
      content: Text(title),
      backgroundColor: color,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}
