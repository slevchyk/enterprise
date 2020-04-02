import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:enterprise/models/profile.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:crypto/crypto.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/widgets/attachments_carousel.dart';

class PageHelpdeskDetail extends StatefulWidget {
  final Helpdesk helpdesk;
  final Profile profile;

  PageHelpdeskDetail({
    this.helpdesk,
    this.profile,
  });

  @override
  createState() => _PageHelpdeskDetailState();
}

class _PageHelpdeskDetailState extends State<PageHelpdeskDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Helpdesk _helpdesk;
  Profile profile;

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

    _helpdesk = widget.helpdesk ?? Helpdesk();
    _readOnly = _helpdesk?.mobID != null;
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
                        controller: _titleController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.edit),
                          suffixIcon: _clearIconButton(_titleController),
                          hintText: 'Введіть заголовок',
                          labelText: 'Заголовок *',
                        ),
                        validator: (value) {
                          if (value.isEmpty) return 'Ви не вказали заголовок';
                          return null;
                        },
                      ),
                      TextFormField(
                        enabled: !_readOnly,
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.format_align_left),
                          suffixIcon: _clearIconButton(_descriptionController),
                          hintText: 'Опис проблеми',
                          labelText: 'Опис *',
                        ),
                        maxLines: 8,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Ви не вказали опис проблеми';
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
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

    Helpdesk _existHelpDesk;
    if (_helpdesk.mobID != null) {
      _existHelpDesk = await HelpdeskDAO().getByMobID(_helpdesk.mobID);
    }

    _helpdesk.userID = profile.userID;
    _helpdesk.title = _titleController.text;
    _helpdesk.description = _descriptionController.text;
    _helpdesk.status = "processed";

    if (_existHelpDesk == null) {
      _helpdesk.mobID = await HelpdeskDAO().insert(_helpdesk);
      if (_helpdesk.mobID != null) {
        _helpdesk = await HelpdeskDAO().getByMobID(_helpdesk.mobID);
        _ok = true;
      }
    } else {
      _ok = await HelpdeskDAO().update(_helpdesk);
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
    if (_helpdesk != null) {
      List<dynamic> _filesPaths = [];
      if (_helpdesk.filePaths != null && _helpdesk.filePaths.isNotEmpty)
        _filesPaths = jsonDecode(_helpdesk.filePaths);
      _filesPaths.forEach((value) {
        _files.add(File(value));
      });

      _titleController.text = _helpdesk?.title ?? "";
      _descriptionController.text = _helpdesk?.description ?? "";
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
          visible: _helpdesk.mobID != null,
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
                                formatDate(_helpdesk.createdAt, [
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
                                formatDate(_helpdesk.updatedAt, [
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
    Directory _dir = Directory('$_appPath/helpdesk/${_helpdesk.mobID}');
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
    _helpdesk.filePaths = jsonEncode(_filesPaths);

    _helpdesk.filesQuantity = _newFiles.length;

    HelpdeskDAO().update(_helpdesk, sync: false);

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
