import 'dart:async';
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/paydesk_dao.dart';
import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/pay.dart';
import 'package:enterprise/models/profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PagePayDesk extends StatefulWidget {
  @override
  _PagePayDeskState createState() => _PagePayDeskState();
}

class _PagePayDeskState extends State<PagePayDesk> {
  Profile profile;

  List<Pay> array = [];

  static Pay lastId = Pay();
  static int id;

  static const List<IconData> _icons = const [
    Icons.image,
    FontAwesomeIcons.filePdf,
    Icons.photo_camera
  ];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _amountController = TextEditingController();
  final _paymentController = TextEditingController();
  final _confirmingController = TextEditingController();
  final _dateController = TextEditingController();

  List<File> _files = [];
  double _amount;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Каса'),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(text: "Архів"),
                  Tab(text: "Додати"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
                  child: FutureBuilder(
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Center(child: _archive());
                    },
                  ),
                ),
                Container(
                  child: FutureBuilder(
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Center(
                        child: _addPayment(),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _archive() {
    return Scaffold(
        body: LiquidPullToRefresh(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      child: ListView(
        children: (id == array.length || id != null)
            ? List.generate(
                id,
                (int index) {
                  return Container(
                      child: Row(
                    children: [
                      Text(array[index].payment),
                      Text(array[index].id.toString()),
                    ],
                  ));
                },
              )
            : List.generate(1, (int index2) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
      ),
    ));
  }

  Widget _addPayment() {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[
          Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _amountController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.attach_money),
                        suffixIcon: _clearIconButton(_amountController),
                        hintText: 'Вкажiть суму',
                        labelText: 'Сума *',
                      ),
                      validator: (value) {
                        String _input = value.trim().replaceAll(',', '.');
                        if (_input.isEmpty) return 'Ви не вказали суму';
                        if (_isNotNumber(_input)) return 'Ви ввели не число';
                        if (_isNotCorrectAmount(_input))
                          return 'Некоректно введена сума';
                        _amount = double.parse(_input);
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: TextFormField(
                      controller: _paymentController,
                      decoration: InputDecoration(
                        icon: Icon(FontAwesomeIcons.file),
                        suffixIcon: _clearIconButton(_paymentController),
                        hintText: 'Вкажiть призначення платежу',
                        labelText: 'Призначення платежу *',
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Ви не вказали призначення платежу';
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: TextFormField(
                      controller: _confirmingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        icon: Icon(FontAwesomeIcons.sortNumericUp),
                        suffixIcon: _clearIconButton(_confirmingController),
                        hintText: 'Вкажiть номер підтверджуючого документу',
                        labelText: 'Номер підтверджуючого документу',
                      ),
                      validator: (value) {
                        if (_isNotNumber(value) && value.isNotEmpty)
                          return 'Ви ввели не число';
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: InkWell(
                      onTap: () {
                        _selectDate(this.context, _dateController);
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.date_range),
                            labelText: 'Дата підвтерджуючого документу',
                          ),
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    child: Wrap(
                        children: List.generate(_files.length, (int index) {
                      Widget child = Container(
                        height: 140.0,
                        width: 170.0,
                        child: Tooltip(
                            message: 'Натисніть щоб видалити',
                            child: Hero(
                                tag: 'image' + index.toString(),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _files.removeAt(index);
                                        });
                                      },
                                      child: Image.file(_files[index])),
                                ))),
                      );
                      return child;
                    })),
                  ),
                ],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _saveLocally();
            _files.forEach((file) => _writeFile(file));
            _displaySnackBar(this.context);
          }
        },
        child: Icon(Icons.check),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_icons.length, (int index) {
          Widget child = Container(
            child: FlatButton(
              child: Icon(_icons[index]),
              onPressed: () {
                switch (index) {
                  case 0:
                    _getFile(FileType.IMAGE);
                    break;
                  case 1:
                    _getFile(FileType.CUSTOM);
                    break;
                  case 2:
                    _getImage();
                    break;
                  default:
                    _getFile(FileType.IMAGE);
                }
              },
            ),
          );
          return child;
        }),
      ),
    );
  }

  Widget _clearIconButton(TextEditingController textController) {
    if (textController.text.isEmpty)
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

  _isNotNumber(String input) {
    try {
      double.parse(input.trim());
      return false;
    } on Exception {
      return true;
    }
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Платіж збережено'),
      backgroundColor: Colors.green,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _isNotCorrectAmount(String value) {
    //Check if the sum is of type *.xx
    // (Two digits after the period)
    List<String> tmp = value.split('.');
    if ((tmp.last.length <= 2 || tmp.length == 1) &&
        double.parse(tmp.first) >= 0) {
      return false;
    } else {
      return true;
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
        textController.text = formatDate(picked, [yyyy, '-', mm, '-', dd]);
      });
  }

  _getFile(FileType type) async {
    List<File> files;
    switch (type) {
      case FileType.IMAGE:
        files = await FilePicker.getMultiFile(type: FileType.IMAGE);
        break;
      case FileType.CUSTOM:
        files = await FilePicker.getMultiFile(
            type: FileType.CUSTOM, fileExtension: 'pdf' //TODO PDF View
            );
        break;
      default:
        files = await FilePicker.getMultiFile(type: FileType.IMAGE);
    }
    setState(() {
      if (_isNotLimitElement()) {
        files.forEach((file) => _files.add(file));
      }
    });
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (_isNotLimitElement()) {
        if (image != null) _files.add(image);
      }
    });
  }

  _isNotLimitElement() {
    //TODO Error if > then 3
    if (_files.length < 3) {
      return true;
    }
    return false;
  }

  _getProfile() async {
    _load();
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    Profile _profile;

    if (_userID != "") {
//      _profile = await DBProvider.db.getProfile(_userID);
      _profile = await ProfileDAO().getByUserId(_userID);
    }

    setState(() {
      profile = _profile;
    });
  }

  _saveLocally() async {
    Pay pay = Pay(
      userID: 2,
      amount: _amount,
      payment: _paymentController.text,
      confirming: int.parse(_confirmingController.text.isNotEmpty
          ? _confirmingController.text
          : '0'),
      date: _dateController.text.isNotEmpty
          ? DateTime.parse(_dateController.text)
          : null,
    );
    await PayDeskDAO().insert(pay);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final name = basename(_files.first.path);
    final Pay lastId = await PayDeskDAO().getLastId();
    final id = lastId.id;
    return File('$path/paydesk/$id/$name');
  }

  _writeFile(File inputFile) async {
    final file = await _localFile;
    List fileBytes = new File(inputFile.path).readAsBytesSync();
    String encodedFile = base64.encode(fileBytes);
    final _bytePhoto = base64Decode(encodedFile);

    if (!file.parent.existsSync()) {
      final path = await _localPath;
      final Pay lastId = await PayDeskDAO().getLastId();
      final id = lastId.id;
      Directory('$path/paydesk/$id/').create();
    }

    file.writeAsBytes(_bytePhoto);
  }

  _load() async {
    lastId = await PayDeskDAO().getLastId();
    lastId != null ? id = lastId.id : id = 0;
    array.clear();

    List<Pay> arrayz = [];

    for (int i = 1; i != id + 1; i++) {
      final Pay tmp = await PayDeskDAO().getById(i);
      arrayz.add(tmp);
    }
    setState(() {
      array.addAll(arrayz);
    });
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    _load();
    _addPayment();
    completer.complete();
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }
}
