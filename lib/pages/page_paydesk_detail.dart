import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/paydesk_dao.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/attachments_carousel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  final _paymentController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _documentDateController = TextEditingController();

  PayDesk _payDesk;
  Profile profile;

  double _amount;
  DateTime _documentDate;
  String _appPath;

  int _status;
  bool _readOnly = false;

  final List<IconData> _icons = const [
    Icons.image,
    FontAwesomeIcons.filePdf,
    Icons.photo_camera
  ];

  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAsync());

    _payDesk = widget.payDesk ?? PayDesk();
    _readOnly = _payDesk?.mobID != null;
    profile = widget.profile;
    _setControllers();
  }

  Future<void> initAsync() async {
    getApplicationDocumentsDirectory().then((value) {
      setState(() {
        _appPath = value.path;
      });
    });
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
//                _setStatus(),
                Text(
                  'Основне',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        enabled: !_readOnly,
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
                      ),
                      TextFormField(
                        enabled: !_readOnly,
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
                      ),
                      TextFormField(
                        enabled: !_readOnly,
                        controller: _documentNumberController,
                        decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.sortNumericUp),
                          suffixIcon:
                              _clearIconButton(_documentNumberController),
                          hintText: 'номер чеку',
                          labelText: 'Номер підтверджуючого документу',
                        ),
                      ),
                      InkWell(
                        onLongPress: () {
                          if (!_readOnly) {
                            _documentDateController.clear();
                            setState(() {
                              _payDesk.documentDate = null;
                              _documentDate = null;
                            });
                          }
                        },
                        onTap: () async {
                          if (_readOnly) {
                            return;
                          }

                          DateTime picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(DateTime.now().year - 1),
                              initialDate: _payDesk?.documentDate != null
                                  ? _payDesk.documentDate
                                  : DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1));

                          if (picked != null)
                            setState(() {
                              _documentDate = picked;
                              _documentDateController.text =
                                  formatDate(picked, [dd, '-', mm, '-', yyyy]);
                            });
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: _documentDateController,
                            readOnly: _readOnly,
                            decoration: InputDecoration(
                              icon: Icon(FontAwesomeIcons.calendar),
                              labelText: 'Дата підтверджуючого документу',
                            ),
                          ),
                        ),
                      ),
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
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
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
      bottomNavigationBar: _setNavigationBar(),
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
        if (_ok) Navigator.pop(_scaffoldKey.currentContext);
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

    _payDesk.userID = profile.userID;
    _payDesk.amount = _amount;
    _payDesk.payment = _paymentController.text;
    _payDesk.documentNumber = _documentNumberController.text;
    _payDesk.documentDate = _documentDate;

    if (_existPayDesk == null) {
      _payDesk.mobID = await PayDeskDAO().insert(_payDesk);
      if (_payDesk.mobID != null) {
        _payDesk = await PayDeskDAO().getByMobID(_payDesk.mobID);
        _ok = true;
      }
    } else {
      _ok = await PayDeskDAO().update(_payDesk);
    }

    if (_ok) {
      _saveAttachments();
      setState(() {
        _readOnly = true;
      });
    } else {
      _displaySnackBar("Помилка збереження в базі", Colors.red);
    }

    return _ok;
  }

  void _setControllers() {
    _files.clear();
    if (_payDesk != null) {
      List<dynamic> _filesPaths = [];
      if (_payDesk.filePaths != null && _payDesk.filePaths.isNotEmpty)
        _filesPaths = jsonDecode(_payDesk.filePaths);
      _filesPaths.forEach((value) {
        _files.add(File(value));
      });

      _amountController.text = _payDesk?.amount?.toStringAsFixed(2) ?? "";
      _paymentController.text = _payDesk?.payment ?? "";
      _documentNumberController.text = _payDesk?.documentNumber ?? "";
      _documentDateController.text = _payDesk?.documentDate == null
          ? ""
          : formatDate(_payDesk.documentDate, [dd, '-', mm, '-', yyyy]);
      _documentDate = _payDesk?.documentDate ?? null;
    }
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
                    content: ListTile(
                      title: Text("Інформація про документ"),
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
                                formatDate(_payDesk.createdAt, [
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
                          Row(
                            children: <Widget>[
                              Text(
                                'Змінений: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatDate(_payDesk.updatedAt, [
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

  Widget _setStatus() {
    String _statusText;
    if (!_readOnly) {
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
    if (!_readOnly) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_icons.length, (int index) {
          Widget child = Container(
            child: FlatButton(
              child: Icon(_icons[index]),
              onPressed: () {
                if (_files.length >= 4) {
                  _displaySnackBar(
                      "Вже досягнута максимальна кількість файлів: 4",
                      Colors.redAccent);
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
        files = await FilePicker.getMultiFile(
            type: FileType.CUSTOM, fileExtension: 'pdf');
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

        if (_files.where((value) => value.path.contains(_fileHash)).length >
            0) {
          _displaySnackBar(
              "Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
          continue;
        }

        if (_newFiles.where((value) => value.path.contains(_fileHash)).length >
            0) {
          _displaySnackBar(
              "Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
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

    PayDeskDAO().update(_payDesk);

    setState(() {
      _files = _newFiles;
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
}
