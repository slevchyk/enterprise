import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PageHelpdeskNew extends StatefulWidget {
  final Helpdesk helpdesk;

  PageHelpdeskNew({
    this.helpdesk,
  });

  PageHelpdeskState createState() => PageHelpdeskState();
}

class PageHelpdeskState extends State<PageHelpdeskNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String userID;
  Helpdesk _helpdesk;

  List<File> _files = [];
  static const List<IconData> _icons = const [
    Icons.image,
    FontAwesomeIcons.filePdf,
    Icons.photo_camera
  ];

  @override
  void initState() {
    super.initState();

    if (widget.helpdesk != null) {
      _helpdesk = widget.helpdesk;

      _titleController.text = _helpdesk.title;
      _descriptionController.text = _helpdesk.description;
    } else {
      _helpdesk = Helpdesk();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _initState());
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

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Створення'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 20.0, left: 10.0),
                    child: TextFormField(
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
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: TextFormField(
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
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            await _saveLocally();
            _files.forEach((file) => _writeFile(file));
            _displaySnackBar(this.context);
          }
        },
        child: Icon(Icons.save),
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

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Збережено'),
      backgroundColor: Colors.green,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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

  _saveLocally() async {
    if (userID == null || userID == "") {
      return;
    }

    _helpdesk.title = _titleController.text;
    _helpdesk.description = _descriptionController.text;
    _helpdesk.userID = userID;
    _helpdesk.status = "processed";

    if (_helpdesk.id == null) {
      _helpdesk.date = DateTime.now();
      _helpdesk.id = await HelpdeskDAO().insert(_helpdesk);
    } else {
      await HelpdeskDAO().update(_helpdesk);
    }
  }

  void _initState() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    setState(() {
      userID = _userID;
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(File inputFile) async {
    final path = await _localPath;
    final name = basename(inputFile.path);
    final id = _helpdesk.id;
    return File('$path/helpdesk/$id/$name');
  }

  _writeFile(File inputFile) async {
    final file = await _localFile(inputFile);
    List fileBytes = new File(inputFile.path).readAsBytesSync();
    String encodedFile = base64.encode(fileBytes);
    final _bytePhoto = base64Decode(encodedFile);

    if (!file.parent.existsSync()) {
      final path = await _localPath;
      final id = _helpdesk.id;
      Directory('$path/helpdesk/$id/').create();
    }

    file.writeAsBytes(_bytePhoto);
  }
}
