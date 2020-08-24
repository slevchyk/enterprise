import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:enterprise/models/coordination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PageCoordination extends StatefulWidget {

  createState() => _PageCoordinationState();

}

class _PageCoordinationState extends State<PageCoordination>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Coordination> _setUrls(List<Coordination> inputList){
    inputList.forEach((element) {
      element.url = "https://api.quickshop.in.ua/test_bk/hs/mobileApi/getDoc?docType=price&docID=123123hk123";
    });
    return inputList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Погодження"),
      ),
      body: FutureBuilder(
        future: Coordination.getCoordinationList(_scaffoldKey),
        builder: (BuildContext context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if(snapshot.data==null){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<Coordination> _coordinationList = snapshot.data;
              _coordinationList = _setUrls(_coordinationList);
              return ListView.builder(
                itemCount: _coordinationList.length,
                itemBuilder: (BuildContext context, int index){
                  return ListTile(
                    title: Row(
                      children: [
                        Text(_coordinationList.elementAt(index).name),
                        Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 7),
                          child: Icon(FontAwesomeIcons.filePdf, color: Colors.black54, size: 17,),
                        ),
                      ],
                    ),
                    subtitle: Text(formatDate(_coordinationList.elementAt(index).date, [dd, '.', mm, '.', yyyy, ' ', HH, ':', mm])),
                    onTap: () {
                      _openFile(_coordinationList.elementAt(index).url, _coordinationList.elementAt(index).name);
                    },
                  );
                },
              );
              break;
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }

  Future<void> _openFile(String url, String fileName) async {
    String _tempPath = (await getTemporaryDirectory()).path;
    String _downloadedFilePath = await _downloadFile(url, "$fileName.pdf", _tempPath);
    await OpenFile.open(_downloadedFilePath);
  }

  Future<String> _downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = HttpClient();
    File _file;

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if(response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        _file = File('$dir/$fileName');
        await _file.writeAsBytes(bytes);
      } else {
        _scaffoldKey
            .currentState
            .showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange,
              content: Text("Помилка статусу запиту"),
        ));
        return 'Error code: '+response.statusCode.toString();
      }
    } catch(ex) {
      _scaffoldKey
          .currentState
          .showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text("Помилка отримання документа"),
          ));
      return ex.toString();
    }

    return _file.path;
  }

}