import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/coordination.dart';
import 'package:enterprise/models/coordination_approved.dart';
import 'package:enterprise/widgets/snack_bar_show.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CoordinationList{
  final  GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController dateFromController;
  final TextEditingController dateToController;
  final bool isPeriod;
  final commentController = TextEditingController();
  final Function callback;

  CoordinationList({
    @required this.scaffoldKey,
    this.dateFromController,
    this.dateToController,
    this.isPeriod,
    this.callback(),
  });

  Widget showCoordination(List<Coordination> coordinationList, bool isHistory){
    DateTime _dateFrom;
    DateTime _dateTo;
    CoordinationApproved _result;
    List<bool> _isComplete = [false];

    if(dateFromController != null && dateFromController.text.isNotEmpty){
      _dateFrom = DateFormat('dd.MM.yyyy').parse(dateFromController.text);
    }
    if(dateToController != null && dateToController.text.isNotEmpty){
      _dateTo = DateFormat('dd.MM.yyyy').parse(dateToController.text);
    }
    if(_dateTo!=null && !isPeriod){
      coordinationList = coordinationList.where((element) => DateFormat('yyyy-MM-dd').parse(element.date.toString()).isAtSameMomentAs(_dateTo)).toList();
    }
    if(_dateFrom!=null && isPeriod){
      coordinationList = coordinationList.where((element) {
        var parse = DateFormat('yyyy-MM-dd').parse(element.date.toString());
        return parse.isBefore(_dateTo) && parse.isAfter(_dateFrom) || parse.isAtSameMomentAs(_dateTo) || parse.isAtSameMomentAs(_dateFrom);
      }).toList();
    }
    return ListView.builder(
      itemCount: coordinationList.length,
      itemBuilder: (BuildContext context, int index){
        return Card(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  width: 0.4,
                  color: Colors.lightGreen
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: ListTile(
              title: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width-70,
                    child: Text(coordinationList.elementAt(index).name, maxLines: 2, overflow: TextOverflow.ellipsis,),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 7),
                    child: coordinationList.elementAt(index).url == null ? Container() : Icon(FontAwesomeIcons.filePdf, color: Colors.black54, size: 25,),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  coordinationList.elementAt(index).date!=null ? Text(formatDate(coordinationList.elementAt(index).date, [dd, '.', mm, '.', yyyy, ' ', HH, ':', mm])) : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: _getStatus(coordinationList.elementAt(index).status),
                  ),
                  isHistory ? Container() : Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(color: Colors.red, spreadRadius: 1),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () async {
                              await _dialogWindow(context, "Вiдхилення", _isComplete);
                              _result = CoordinationApproved(
                                id: coordinationList.elementAt(index).id,
                                comment: commentController.text,
                                result: false,
                              );
                              if(_isComplete.first){
                                if(await CoordinationApproved.setResult(_result, scaffoldKey, "відхилено")){
                                  await Future.delayed(Duration(seconds: 2));
                                  _callback();
                                }
                              }
                              _isComplete.first = false;
                            },
                            icon: Icon(Icons.clear), color: Colors.white,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.lightGreen,
                            boxShadow: [
                              BoxShadow(color: Colors.lightGreen, spreadRadius: 1),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () async {
                              await _dialogWindow(context, "Погодження", _isComplete);
                              _result = CoordinationApproved(
                                id: coordinationList.elementAt(index).id,
                                comment: commentController.text.isEmpty ? "Коментар відсутній" : commentController.text,
                                result: true,
                              );
                              if(_isComplete.first){
                                if(await CoordinationApproved.setResult(_result, scaffoldKey, "погоджено")){
                                  await Future.delayed(Duration(seconds: 2));
                                  _callback();
                                }
                              }
                              _isComplete.first = false;
                            },
                            icon: Icon(Icons.check), color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                if(coordinationList.elementAt(index).url!=null){
                  _openFile(coordinationList.elementAt(index).url, coordinationList.elementAt(index).name);
                }
                },
            ),
          ),
        );
        },
    );
  }

  void _callback(){
    if(callback!=null){
      this.callback();
    }
  }

  Future<void> _openFile(String url, String fileName) async {
    String _tempPath = (await getTemporaryDirectory()).path;
    String _downloadedFilePath = await _downloadFile(url, "$fileName.pdf", _tempPath);
    if(await File(_downloadedFilePath).length() <= 0){
      FLog.error(
        exception: Exception("Error open file"),
        text: "Url: $url, DownloadedFilePath: $_downloadedFilePath,  length <= 0",
      );
      ShowSnackBar.show(scaffoldKey, "Помилка вiдображення файла", Colors.orange);
      return;
    }
    await OpenFile.open(_downloadedFilePath);
  }

  Widget _getStatus(CoordinationTypes input){
    String _text;
    Color _color;
    switch (input){
      case CoordinationTypes.none:
        _text = "До погодження";
        _color = Colors.lightBlue;
        break;
      case CoordinationTypes.approved:
        _text = "Погодженно";
        _color = Colors.green;
        break;
      case CoordinationTypes.reject:
        _text = "Відхилено";
        _color = Colors.red;
        break;
      default:
        _text = "До погодження";
        _color = Colors.lightBlue;
    }
    return Text(_text, style: TextStyle(color: _color),);
  }

  Future<String> _downloadFile(String url, String fileName, String dir) async {
    HttpClient _httpClient = HttpClient();
    File _file;

    try {
      var request = await _httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if(response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        _file = File('$dir/$fileName');
        await _file.writeAsBytes(bytes);
      } else {
        scaffoldKey
            .currentState
            .showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange,
              content: Text("Помилка запиту"),
            ));
        FLog.error(
          exception: Exception(response.statusCode),
          text: "status code error",
        );
        return 'Error code: '+response.statusCode.toString();
      }
    } catch(e, s) {
      scaffoldKey
          .currentState
          .showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text("Помилка отримання документа"),
          ));
      FLog.error(
        exception: Exception(e.toString()),
        text: "try block error",
        stacktrace: s,
      );
      return e.toString();
    }

    return _file.path;
  }

  Future _dialogWindow(BuildContext context, String action, List<bool> a){
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      child: Form(
        key: _formKey,
        child:  Builder(
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(action, textAlign: TextAlign.center, style: TextStyle(fontSize: 25),),
              content: Wrap(
                children: [
                  Padding(
                    padding:EdgeInsets.only(bottom: 20) ,
                    child: TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        hintText: 'Вкажiть коментар до $action',
                        labelText: 'Коментар до ${action.toLowerCase()}',
                      ),
                      validator: (value){
                        if (value.isEmpty && action=="Вiдхилення") return 'Ви не вказали коментар до ${action.toLowerCase()}';
                        return null;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                        color: Colors.grey[200],
                        child: Text("Вiдмiнити"),
                        onPressed: (){
                          a.first = false;
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        color: Colors.lightGreen,
                        child: Text("Пiдтвердити"),
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            a.first = true;
                            Navigator.of(context).pop();
                            return;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
            },
      ),
    )
    );
  }
}