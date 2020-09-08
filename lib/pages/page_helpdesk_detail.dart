import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/attachments_carousel.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PageHelpdeskDetail extends StatefulWidget {
  final HelpDesk helpdesk;
  final Profile profile;

  PageHelpdeskDetail({
    this.helpdesk,
    this.profile,
  });

  @override
  createState() => _PageHelpDeskDetailState();
}

class _PageHelpDeskDetailState extends State<PageHelpdeskDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  HelpDesk _helpDesk;
  Profile profile;

  String _appPath;

  bool _readOnly = false;

  final List<IconData> _icons = const [Icons.image, FontAwesomeIcons.filePdf, Icons.photo_camera];
  List<bool> _isError = [false];

  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initAsync());

    _helpDesk = widget.helpdesk ?? HelpDesk();
    _readOnly = _helpDesk?.mobID != null;
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
                          if (value.isEmpty) return 'Ви не вказали опис проблеми';
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

    HelpDesk _existHelpDesk;
    if (_helpDesk.mobID != null) {
      _existHelpDesk = await HelpdeskDAO().getByMobID(_helpDesk.mobID);
    }

    _helpDesk.userID = profile.userID;
    _helpDesk.title = _titleController.text;
    _helpDesk.description = _descriptionController.text;
    _helpDesk.status = "processed";

    if (_existHelpDesk == null) {
      _helpDesk.mobID = await HelpdeskDAO().insert(_helpDesk);
      if (_helpDesk.mobID != null) {
        _helpDesk = await HelpdeskDAO().getByMobID(_helpDesk.mobID);
        _ok = true;
      }
    } else {
      _ok = await HelpdeskDAO().update(_helpDesk);
    }

    if (_ok) {
      _saveAttachments();
      setState(() {
        _readOnly = true;
      });
    } else {
      ShowSnackBar.show(_scaffoldKey, "Помилка збереження в базі", Colors.red);
    }

    return _ok;
  }

  void _setControllers() {
    _files.clear();
    if (_helpDesk != null) {
      List<dynamic> _filesPaths = [];
      if (_helpDesk.filePaths != null && _helpDesk.filePaths.isNotEmpty) _filesPaths = jsonDecode(_helpDesk.filePaths);
      _filesPaths.forEach((value) {
        _files.add(File(value));
      });

      _titleController.text = _helpDesk?.title ?? "";
      _descriptionController.text = _helpDesk?.description ?? "";
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
          visible: _helpDesk.mobID != null,
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
                                formatDate(_helpDesk.createdAt, [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn, ':', ss]),
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
                                formatDate(_helpDesk.updatedAt, [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn, ':', ss]),
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
                  ShowSnackBar.show(_scaffoldKey, "Вже досягнута максимальна кількість файлів: 4", Colors.redAccent);
                  return;
                }

                switch (index) {
                  case 0:
                    _getFile(FileType.image);
                    break;
                  case 1:
                    _getFile(FileType.custom);
                    break;
                  case 2:
                    _getImageCamera();
                    break;
                  default:
                    _getFile(FileType.image);
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
    ShowSnackBar.show(_scaffoldKey, "Досягнуто максимальну кількість файлів - 4", Colors.red) ;
    return false;
  }

  void _getFile(FileType type) async {
    List<File> files;
    switch (type) {
      case FileType.image:
        files = await FilePicker.getMultiFile(type: FileType.image);
        break;
      case FileType.custom:
        files = await FilePicker.getMultiFile(type: FileType.custom, allowedExtensions: ['pdf']);
        break;
      default:
        files = await FilePicker.getMultiFile(type: FileType.image);
    }

    if (files != null) {
      if (_isNotLimitElement((files.length + _files.length))) {
        files.forEach((file) => _files.add(file));
      }
      setState(() {});
    }
  }

  Future<void> _saveAttachments() async {
    Directory _dir = Directory('$_appPath/helpdesk/${_helpDesk.mobID}');
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
          ShowSnackBar.show(_scaffoldKey, "Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
          continue;
        }

        if (_newFiles.where((value) => value.path.contains(_fileHash)).length > 0) {
          ShowSnackBar.show(_scaffoldKey, "Вже є такий файл ${basename(_file.path)}", Colors.redAccent);
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
    _helpDesk.filePaths = jsonEncode(_filesPaths);

    _helpDesk.filesQuantity = _newFiles.length;

    HelpdeskDAO().update(_helpDesk, sync: false);

    setState(() {
      _files = _newFiles;
    });
  }

  Future _getImageCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      if (_isNotLimitElement(_files.length + 1)) {
        if (image != null) _files.add(File(image.path));
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
}
