
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/warehouse/documents_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/warehouse/documnets.dart';
import 'package:enterprise/models/warehouse/partners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsView extends StatefulWidget{

  final Documents currentDocuments;
  final bool enableEdit;
  final Future<List<Partners>> partnersList;

  DocumentsView({
    @required this.currentDocuments,
    @required this.enableEdit,
    @required this.partnersList
  });

  createState() => _DocumentsState(currentDocuments, enableEdit, partnersList);
}

class _DocumentsState extends State<DocumentsView>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fieldNumber = TextEditingController();
  final _fieldDate = TextEditingController();
  final _fieldPartner = TextEditingController();

  Future<List<Partners>> _partnersList;
  final Documents _currentDocuments;
  String _appBar = 'Додати замовлення';

  final bool _enableEdit;
  bool _editable = true;

  var _icon = Icons.check;

  _DocumentsState(this._currentDocuments, this._enableEdit, this._partnersList){
    if(_enableEdit == false && _currentDocuments != null){
      _fieldNumber.text = _currentDocuments.number.toString();
      _fieldDate.text = DateFormat('dd.MM.yyyy').format(_currentDocuments.date);
      _fieldPartner.text = _currentDocuments.partner;
      _appBar = 'Перегляд замовлення';
      _editable = false;
      _icon = Icons.edit;
    }
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
          appBar: AppBar(title: Text(_appBar),),
          body: Container(
            margin: EdgeInsets.only(right: 20.0),
            child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    _setStatus(),
                    TextFormField(
                      enabled: _editable,
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
                          if (_editable)
                            _selectDate(context, _fieldDate);
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            enabled: _editable,
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
                          if(_editable)
                            showGeneralDialog(
                              barrierLabel: "partners",
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
                                                    String _name = snapshot
                                                        .data[index]
                                                        .name;
                                                    String _id = snapshot
                                                        .data[index]
                                                        .mobID.toString();
//                                                    var _image = Image.file(snapshot
//                                                        .data[index]
//                                                        .logo);
//                                                    Add image of partner to list
//                                                    Surround with try{} catch for handle the error
//                                                    Add field 'logo' to => warehouse core, partners_dao and models partners
                                                    return InkWell(
                                                      onTap: () {
                                                        _fieldPartner.text = _name;
                                                        Navigator.pop(context);
                                                      },
                                                      child: Wrap(
                                                        children: <Widget>[
                                                          index == 0
                                                              ? Center(
                                                            child: Text('Партнери',
                                                              style: TextStyle(
                                                                  fontSize: 20.0
                                                              ),),)
                                                              : Container(),
                                                          Center(
                                                            child: ListTile(
                                                              leading: CircleAvatar(
                                                                child: Text(_id),
//                                                               child:  _image == null
//                                                                ? Text(_id)
//                                                                : _image,
//                                                               Check if partner have image, show image, else show id
                                                              ),
                                                              title: Text("Партнер: $_name"),
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
                                    margin: EdgeInsets.only(
                                        top: 50,
                                        bottom: 50,
                                        left: 12,
                                        right: 12
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
                        child: IgnorePointer(
                          child: TextFormField(
                            enabled: _editable,
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
                  ],
                )
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if(_formKey.currentState.validate() == true && _enableEdit){
                if(await _insertIntoDB()) {
                  _displaySnackBar(context, "Замовлення збережно", Colors.green);
                }

                else
                  _displaySnackBar(context, "Помилка збереження", Colors.red);
              }
              if (!_enableEdit && !_editable){
                setState(() {
                  _appBar = 'Редагування замовлення';
                  _editable = true;
                  _icon = Icons.check;
                });
              } else if (!_enableEdit &&
                  _editable &&
                  _formKey.currentState.validate()){
                if (await _updatePaymentInDB())
                  _displaySnackBar(context, "Замовлення оновлено", Colors.green);
                else
                  _displaySnackBar(context, "Помилка збереження", Colors.red);
                setState(() {
                  _appBar = 'Перегляд замовлення';
                  _editable = false;
                  _icon = Icons.edit;
                });
              }
            },
            child: Icon(_icon),
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

    if (_currentDocuments.status == true) {
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
      Documents documents = Documents(
        userID: _userID,
        status: false,
        number: int.parse(_fieldNumber.text),
        date: DateTime.parse(formatDate(
            DateFormat("dd-MM-yyyy")
                .parse(_fieldDate.text.replaceAll('.', '-')),
            [yyyy, '-', mm, '-', dd])),
        partner: _fieldPartner.text,
      );
      return await DocumentsDAO().insert(documents);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _updatePaymentInDB() async {
    try {
      Documents documents = Documents(
        mobID: _currentDocuments.mobID,
        userID: _currentDocuments.userID,
        status: false,
        number: int.parse(_fieldNumber.text),
        date: DateTime.parse(formatDate(
            DateFormat("dd-MM-yyyy")
                .parse(_fieldDate.text.replaceAll('.', '-')),
            [yyyy, '-', mm, '-', dd])),
        partner: _fieldPartner.text,
      );
      return await DocumentsDAO().update(documents) == 1 ? true : false;
    } catch (_) {
      return false;
    }
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