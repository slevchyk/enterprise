
import 'package:enterprise/database/warehouse/goodsAdded_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoodsView extends StatefulWidget{

  final Goods currentGoods;
  final bool enableEdit;
  final bool isNew;
  final Future<List<Goods>> goodsList;

  GoodsView({
    @required this.currentGoods,
    @required this.enableEdit,
    @required this.isNew,
    @required this.goodsList,
  });

  createState() => _GoodsState(currentGoods, enableEdit, isNew, goodsList);
}

class _GoodsState extends State<GoodsView>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _fieldName = TextEditingController();
  final _fieldCount = TextEditingController();
  final _fieldUnit = TextEditingController();

  final Future<List<Goods>> _goodsList;
  final Goods _currentGoods;

  String _appBar = 'Додати номенклатуру';

  final bool _isNew;
  final bool _enableEdit;
  bool _editable = true;

  var _icon = Icons.check;

  _GoodsState(this._currentGoods, this._enableEdit, this._isNew, this._goodsList){
    if(_enableEdit == false && _currentGoods != null){
      _fieldName.text = _currentGoods.name;
      _fieldCount.text = _currentGoods.count.toString();
      _fieldUnit.text = _currentGoods.unit;
      _appBar = 'Перегляд номенклатури';
      _editable = false;
      _icon = Icons.edit;
    }
    if(_isNew)
      _appBar = 'Номенклатура постачальника';
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
          appBar: AppBar(title: Text(_appBar,)),
          body: Container(
            margin: EdgeInsets.only(right: 20.0),
            child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    _isNew ? Container() : _setStatus(),
                     Container(
                      child: InkWell(
                        onTap: () {
                          if(_editable)
                            showGeneralDialog(
                              barrierLabel: "goods",
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.5),
                              transitionDuration: Duration(milliseconds: 250),
                              context: context,
                              pageBuilder: (context, anim1, anim2) {
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
                                                    String _name = snapshot
                                                        .data[index]
                                                        .name;
                                                    String _id = snapshot
                                                        .data[index]
                                                        .mobID.toString();
                                                    String _unit = snapshot
                                                        .data[index]
                                                        .unit;
                                                    return InkWell(
                                                      onTap: () {
                                                        _fieldName.text = _name;
                                                        _fieldUnit.text = _unit;
                                                        Navigator.pop(context);
                                                      },
                                                      child: Wrap(
                                                        children: <Widget>[
                                                          index == 0
                                                              ? Center(
                                                            child: Text('Номенклатури',
                                                              style: TextStyle(fontSize: 20.0),),)
                                                              : Container(),
                                                          Center(
                                                            child: ListTile(
                                                              leading: CircleAvatar(
                                                                child: Text(_id),
                                                              ),
                                                              title: Text("Номенклатура: $_name"),
                                                              subtitle: Text("Одиниця вимiру: $_unit"),
                                                            ),
                                                          )
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
                                    margin: EdgeInsets.only(top: 50, bottom: 50, left: 12, right: 12),
                                  ),
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
                            enabled: _editable,
                            controller: _fieldName,
                            decoration: InputDecoration(
                                icon: Icon(Icons.title),
                                labelText: _isNew ? 'Номенклатура' : 'Номенклатура *',
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
                          labelText: _isNew ? 'Одиниця вимiру' : 'Одиниця вимiру *',
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
                      enabled: _editable,
                      controller: _fieldCount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.sortNumericDown),
                          suffixIcon: _isNew ? null : _clearIconButton(_fieldCount),
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
                  ],
                )
            ),
          ),
          floatingActionButton: Visibility(
            visible: !_isNew,
              child: FloatingActionButton(
                onPressed: () async {
                  if(_formKey.currentState.validate() == true && _enableEdit){
                    if(await _insertIntoDB())
                      _displaySnackBar(context, "Номенклатуру збережно", Colors.green);
                    else
                      _displaySnackBar(context, "Помилка збереження", Colors.red);
                  }
                  if (!_enableEdit && !_editable){
                    setState(() {
                      _appBar = 'Редагування номенклатури';
                      _editable = true;
                      _icon = Icons.check;
                    });
                  } else if (!_enableEdit &&
                      _editable &&
                      _formKey.currentState.validate()){
                    if (await _updatePaymentInDB())
                      _displaySnackBar(context, "Номенклатуру оновлено", Colors.green);
                    else
                      _displaySnackBar(context, "Помилка збереження", Colors.red);
                    setState(() {
                      _appBar = 'Перегляд номенклатури';
                      _editable = false;
                      _icon = Icons.edit;
                    });
                  }
                },
                child: Icon(_icon),
              )
          ),
        ),
      ),
    );
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

  Widget _setStatus() {
    String _statusText;
    if (_enableEdit) {
      _statusText = '';
      return Container();
    }

    if (_currentGoods.status == true) {
      _statusText = 'Робочий';
    } else {
      _statusText = 'Чорновик';
    }

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
              'Статус: $_statusText',
              style: TextStyle(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }

  bool _isNotNumber(String input) {
    try {
      double.parse(input.trim());
      return false;
    } on Exception {
      return true;
    }
  }

  Future<bool> _insertIntoDB() async {
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    if (_userID == '') {
      _showDialog(
          title: 'Помилка збереження',
          body: 'Спочатку потрібно зареєструватися ');
      return false;
    }

    try {
      Goods goods = Goods(
        userID: _userID,
        status: false,
        name: _fieldName.text,
        count: int.parse(_fieldCount.text),
        unit: _fieldUnit.text,
      );
      return await GoodsAddedDAO().insert(goods);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _updatePaymentInDB() async {
    try {
      Goods goods = Goods(
        mobID: _currentGoods.mobID,
        userID: _currentGoods.userID,
        status: false,
        name: _fieldName.text,
        count: int.parse(_fieldCount.text),
        unit: _fieldUnit.text,
      );
      return await GoodsAddedDAO().update(goods) == 1 ? true : false;
    } catch (_) {
      return false;
    }
  }

  void _displaySnackBar(BuildContext context, String title, Color color) {
    final snackBar = SnackBar(
      content: Text(title),
      backgroundColor: color,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _showDialog({String title, String body}) {
    showDialog(
      context: context,
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

}
