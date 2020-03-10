import 'dart:async';
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:enterprise/database/paydesk_dao.dart';
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
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PagePayDesk extends StatefulWidget {
  @override
  _PagePayDeskState createState() => _PagePayDeskState();
}

class _PagePayDeskState extends State<PagePayDesk> {
  List<Pay> _paymentArray = [];
  static int _lastId;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static int _id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Каса'),
      ),
      body: Container(
        child: Center(
          child: Scaffold(
            body: LiquidPullToRefresh(
              color: Colors.lightGreen,
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: _id == 0
                  ? ListView(
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Записiв не зайдено',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        )
                      ],
                    )
                  : ListView.builder(
                      itemCount: _id,
                      itemBuilder: (BuildContext context, int index) {
                        if (_id != _paymentArray.length)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        return InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return WorkWithPayment(
                                edit: false,
                                index: index,
                                current: _paymentArray[index],
                              );
                            })).whenComplete(() => _load());
                          },
                          child: Hero(
                            tag: 'paydesk_$index',
                            child: Material(
                              type: MaterialType.transparency,
                              child: ListTile(
                                isThreeLine: true,
                                leading: CircleAvatar(
                                    child: Text(
                                        _paymentArray[index].id.toString())),
                                title: Text('Призначення платежу: '
                                    '${_paymentArray[index].payment.toString()}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Сумма платежу:  '
                                        '${_paymentArray[index].amount.toStringAsFixed(2)} '
                                        '${String.fromCharCode(0x000020B4)}'),
                                    _paymentArray[index].date == null
                                        ? Text('Дата: не вказана')
                                        : Text(
                                            'Дата: ${DateFormat('dd.MM.yyyy').format(_paymentArray[index].date)}'),
                                    _paymentArray[index].confirming == 0
                                        ? Text('Номер платежу: не вказан')
                                        : Text('Номер платежу: '
                                            '${_paymentArray[index].confirming.toString()}')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return Material(child: WorkWithPayment(edit: true));
          })).whenComplete(() => _load());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _load() async {
    List<Pay> _tmp = [];

    _lastId = await PayDeskDAO().getLastId();
    _lastId != null ? _id = _lastId : _id = 0;
    _paymentArray.clear();

    for (int i = 1; i != _id + 1; i++) {
      final Pay tmp = await PayDeskDAO().getById(i);
      _tmp.add(tmp);
    }

    this.setState(() {
      _paymentArray.addAll(_tmp);
    });
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    _load();
    completer.complete();
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        backgroundColor: Colors.lightGreen,
        content: const Text(
          'Сторiнка оновлена',
          style: TextStyle(color: Colors.black),
        ),
      ));
    });
  }
}

class WorkWithPayment extends StatefulWidget {
  final bool edit;
  final amount;
  final payment;
  final confirming;
  final date;
  final files;
  final int index;
  final Pay current;

  WorkWithPayment(
      {this.edit,
      this.amount,
      this.payment,
      this.confirming,
      this.date,
      this.files,
      this.index,
      this.current});

  @override
  createState() => _WorkWithPaymentState(edit,
      amount: amount,
      payment: payment,
      confirming: confirming,
      date: date,
      files: files,
      index: index,
      current: current);
}

class _WorkWithPaymentState extends State<WorkWithPayment> {
  _WorkWithPaymentState(this._editable,
      {amount, payment, confirming, date, files, index, current}) {
    if (!_editable) {
      _amountController.text = current.amount.toStringAsFixed(2);
      _paymentController.text = current.payment.toString();
      current.confirming.toString() != "0"
          ? _confirmingController.text = current.confirming.toString()
          : _confirmingController.text = 'Номер не вказан';
      current.date != null
          ? _dateController.text = DateFormat('dd.MM.yyyy').format(current.date)
          : _dateController.text = 'Дата не вказана';
      _enableEdit = false;
      current.files != null ? _files = _takeFilesFromPath(current) : File('');
      _index = index;
      _icon = Icons.edit;
      _status = current.paymentStatus;
      _uid = current.userID;
    }
  }

  List<IconData> _icons = const [
    Icons.image,
    FontAwesomeIcons.filePdf,
    Icons.photo_camera
  ];

  String _uid;
  String _deletedFiles;

  int _index;

  Profile profile;

  List<File> _files = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _paymentController = TextEditingController();
  final _confirmingController = TextEditingController();
  final _dateController = TextEditingController();

  double _amount;
  int _status;
  bool _editable;
  bool _enableEdit = true;
  var _icon = Icons.check;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _setAppBar(),
      key: _scaffoldKey,
      body: GestureDetector(
        onDoubleTap: () {
          Navigator.pop(context);
        },
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Hero(
              tag: _setHeroTag(),
              child: Material(
                type: MaterialType.transparency,
                child: ListView(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            _setStatus(),
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              child: TextFormField(
                                enabled: _enableEdit,
                                keyboardType: TextInputType.number,
                                controller: _amountController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.attach_money),
                                  suffixIcon:
                                      _clearIconButton(_amountController),
                                  hintText: 'Вкажiть суму',
                                  labelText: 'Сума *',
                                ),
                                validator: (value) {
                                  String _input =
                                      value.trim().replaceAll(',', '.');
                                  if (_input.isEmpty)
                                    return 'Ви не вказали суму';
                                  if (_isNotNumber(_input))
                                    return 'Ви ввели не число';
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
                                enabled: _enableEdit,
                                controller: _paymentController,
                                decoration: InputDecoration(
                                  icon: Icon(FontAwesomeIcons.file),
                                  suffixIcon:
                                      _clearIconButton(_paymentController),
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
                                enabled: _enableEdit,
                                controller: _confirmingController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  icon: Icon(FontAwesomeIcons.sortNumericUp),
                                  suffixIcon:
                                      _clearIconButton(_confirmingController),
                                  hintText:
                                      'Вкажiть номер підтверджуючого документу',
                                  labelText: 'Номер підтверджуючого документу',
                                ),
                                validator: (value) {
                                  if (value.trim() == 'Номер не вказан')
                                    return value = null;
                                  if (_isNotNumber(value) && value.isNotEmpty)
                                    return 'Ви ввели не число';
                                  return null;
                                },
                                onTap: () {
                                  if (_confirmingController.text.trim() ==
                                      'Номер не вказан')
                                    _confirmingController.clear();
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              child: InkWell(
                                onLongPress: () {
                                  if (_enableEdit) _dateController.clear();
                                },
                                onTap: () {
                                  if (_enableEdit)
                                    _selectDate(context, _dateController);
                                },
                                child: IgnorePointer(
                                  child: TextFormField(
                                    enabled: _enableEdit,
                                    controller: _dateController,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.date_range),
                                      labelText:
                                          'Дата підвтерджуючого документу',
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
                                  children:
                                      List.generate(_files.length, (int index) {
                                Widget child = Container(
                                  height: 170.0,
                                  width: 170.0,
                                  margin: EdgeInsets.all(5.0),
                                  child: _showImage(index),
                                );
                                return child;
                              })),
                            ),
                          ],
                        )),
                  ],
                ),
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState.validate() && _editable) {
            if (await _saveLocally())
              _displaySnackBar(context, "Платiж збережно", Colors.green);
            else
              _displaySnackBar(context, "Помилка збереження", Colors.red);
          } else if (!_formKey.currentState.validate() && _editable) {
            return;
          }
          if (!_enableEdit && !_editable) {
            setState(() {
              _enableEdit = true;
              _icon = Icons.check;
            });
          } else if (_enableEdit &&
              !_editable &&
              _formKey.currentState.validate()) {
            if (await _updatePaymentInDB() && await _deleteFileLocally())
              _displaySnackBar(context, "Платiж оновлено", Colors.green);
            else
              _displaySnackBar(context, "Помилка збереження", Colors.red);
            setState(() {
              _enableEdit = false;
              _icon = Icons.edit;
            });
          }
        },
        child: Icon(_icon),
      ),
      bottomNavigationBar: _setNavigationBar(),
    );
  }

  Widget _showImage(index) {
    if (_enableEdit) {
      return Tooltip(
          message: 'Натисніть щоб видалити',
          child: InkWell(
            onTap: () {
              setState(() {
                if (_deletedFiles == null) {
                  _deletedFiles = _files[index].path;
                } else {
                  _deletedFiles = '$_deletedFiles,${_files[index].path}';
                }
                _files.removeAt(index);
              });
            },
            child: Wrap(
              children: <Widget>[
                Center(
                  child: _chooseImageOrPDF(_files[index]),
                )
              ],
            ),
          ));
    } else {
      return _chooseImageOrPDF(_files[index]);
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

  Widget _setAppBar() {
    if (_editable)
      return AppBar(
        title: Text('Додати платiж'),
      );
    return null;
  }

  Widget _setStatus() {
    String _statusText;
    if (_editable) {
      _statusText = '';
      return Container();
    }

    if (_status != null && _status == 0) {
      _statusText = 'Чорновик';
    } else {
      _statusText = 'Робочий';
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

  Widget _setNavigationBar() {
    if (_editable) {
      return Row(
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

  Widget _chooseImageOrPDF(File file) {
    if (path.extension(file.path) == '.pdf')
      return Column(
        children: <Widget>[
          Image.asset(
            'assets/pdf.png',
            width: 100,
          ),
          _enableEdit ? Text(path.basename(file.path)) : Text(''),
        ],
      );
    return Column(
      children: <Widget>[
        Image.file(
          file,
          width: 100,
          height: 100,
        ),
        _enableEdit ? Text(path.basename(file.path)) : Text(''),
      ],
    );
  }

  String _setHeroTag() {
    if (_editable) return 'add_new_payment';
    return 'paydesk_$_index';
  }

  String _getStringFilePath(List<File> inputFiles) {
    String toReturn;
    inputFiles.forEach((element) {
      if (toReturn == null) {
        toReturn = element.path;
      } else {
        toReturn = '$toReturn,${element.path}';
      }
    });
    return toReturn;
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
    if ((tmp.last.length <= 2 || tmp.length == 1) &&
        double.parse(tmp.first) >= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool _isNotLimitElement(int files) {
    if (files <= 4) {
      return true;
    }
    _showDialog(
        title: 'Максимальна кількість',
        body: 'Досягнуто максимальну кількість файлів - 4');
    return false;
  }

  void _displaySnackBar(BuildContext context, String title, Color color) {
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
        files = await FilePicker.getMultiFile(
            type: FileType.CUSTOM, fileExtension: 'pdf');
        break;
      default:
        files = await FilePicker.getMultiFile(type: FileType.IMAGE);
    }
    setState(() {
      if (_isNotLimitElement((files.length + _files.length))) {
        files.forEach((file) => _files.add(file));
      }
    });
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

  Future<bool> _saveLocally() async {
    String toReturn;
    List<File> tmp = await _writeFile(_files);
    tmp.forEach((element) {
      if (toReturn == null) {
        toReturn = element.path;
      } else {
        toReturn = '$toReturn,${element.path}';
      }
    });
    return await _insertIntoDB(toReturn);
  }

  Future<bool> _insertIntoDB(String toWrite) async {
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    if (_userID == '') {
      _showDialog(
          title: 'Помилка збереження',
          body: 'Спочатку потрібно зареєструватися ');
      return false;
    }
    try {
      Pay pay = Pay(
        userID: _userID,
        paymentStatus: 0,
        amount: _amount,
        payment: _paymentController.text,
        confirming: int.parse(_confirmingController.text.isNotEmpty
            ? _confirmingController.text
            : '0'),
        date: _dateController.text.isNotEmpty
            ? DateTime.parse(formatDate(
                DateFormat("dd-MM-yyyy")
                    .parse(_dateController.text.replaceAll('.', '-')),
                [yyyy, '-', mm, '-', dd]))
            : null,
        files: toWrite != null ? toWrite : null,
      );
      return await PayDeskDAO().insert(pay);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _updatePaymentInDB() async {
    String confirming = _confirmingController.text;
    String date = _dateController.text;
    if (confirming == "Номер не вказан") confirming = '0';
    if (date == "Дата не вказана") date = '';
    String toWrite = _getStringFilePath(_files);
    try {
      Pay pay = Pay(
          id: _index + 1,
          userID: _uid,
          amount: _amount,
          payment: _paymentController.text,
          confirming: int.parse(confirming.isNotEmpty ? confirming : '0'),
          date: date.isNotEmpty
              ? DateTime.parse(formatDate(
                  DateFormat("dd-MM-yyyy").parse(date.replaceAll('.', '-')),
                  [yyyy, '-', mm, '-', dd]))
              : null,
          files: toWrite);
      return await PayDeskDAO().update(pay) == 1 ? true : false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _deleteFileLocally() async {
    try {
      if (_deletedFiles != null) {
        var dirPath;
        var split = _deletedFiles.split(',');
        split.forEach((element) async {
          File input = File(element);
          dirPath = input.parent.path;
          if (input.existsSync()) {
            input.deleteSync();
          }
        });
        Directory dir = Directory('$dirPath');
        if (await dir.list().isEmpty) {
          dir.deleteSync(recursive: true);
        }
      }
      return true;
    } catch (error) {
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

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (_isNotLimitElement(_files.length + 1)) {
        if (image != null) _files.add(image);
      }
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  List<File> _takeFilesFromPath(Pay current) {
    List<File> tmp = [];
    List<String> split = current.files.split(',');
    split.forEach((element) {
      tmp.add(File(element));
    });

    return tmp;
  }

  Future<File> _localFile(File inputFile) async {
    var uuid = Uuid();
    final localPath = await _localPath;
    final extension = path.extension(inputFile.path);
    final id = await PayDeskDAO().getLastId();
    final originalName = path.basename(inputFile.path);
    final encryptedName = uuid.v5(
        Uuid.NAMESPACE_URL, '${DateTime.now().toString()}$id$originalName');
    return File('$localPath/paydesk/$id/$encryptedName$extension');
  }

  Future<List<File>> _writeFile(List<File> inputFiles) async {
    List<File> tmp = [];
    try {
      for (int i = 0; i < _files.length; i++) {
        File file = await _localFile(inputFiles[i]);
        List fileBytes = new File(inputFiles[i].path).readAsBytesSync();
        String encodedFile = base64.encode(fileBytes);
        final _bytePhoto = base64Decode(encodedFile);

        if (!file.parent.existsSync()) {
          final path = await _localPath;
          final id = await PayDeskDAO().getLastId();
          await Directory('$path/paydesk/$id/').create(recursive: true);
        }

        await file.writeAsBytes(_bytePhoto);

        tmp.add(file);
      }
      return tmp;
    } catch (_) {
      _displaySnackBar(context, "Файл не знайдено", Colors.red);
      return null;
    }
  }
}
