import 'package:enterprise/widgets/custom_expansion_title.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:f_logs/model/flog/log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageShowLogs extends StatelessWidget{
  final ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _scrollController.jumpTo(
          0.0,
        );
      },
      onDoubleTap: () {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Logs"),
        ),
        body: Container(
          child: FutureBuilder<List>(
            future: FLog.getAllLogs(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                if(snapshot.data.length == 0){
                  return Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20.0),
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Text(
                        'No logs',
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                List<Log> _listToShow = snapshot.data;
                return Container(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _listToShow.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(index==0){
                        return Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text("Logs size: ${_listToShow.length}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              ),
                              _smt(_listToShow, index),
                            ],
                          ),
                        );
                      }
                     return  _smt(_listToShow, index);
                    },
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
  Widget _smt(_listToShow, index){
    return Card(
      color: Colors.grey[300],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: ListTile(
        isThreeLine: true,
        leading: Text("${_listToShow.elementAt(index).id}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _listToShow.elementAt(index).exception == "null" ? Text("Info", style: TextStyle(fontWeight: FontWeight.bold),) : Text(_listToShow.elementAt(index).exception, style: TextStyle(fontWeight: FontWeight.bold),),
              Text("Class Name: ${_listToShow.elementAt(index).className}"),
              Text("Method Name: ${_listToShow.elementAt(index).methodName}"),
            ],
          ),
        ),
        subtitle: Column(
          children: [
            Text(_listToShow.elementAt(index).text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.black),),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text("Time: ${_listToShow.elementAt(index).timestamp}", textAlign: TextAlign.left,),
            ),

            _listToShow.elementAt(index).stacktrace == "null" ? Container() : CustomExpansionTile(
              title: Text("Stacktrace"),
              children: [
                Text(_listToShow.elementAt(index).stacktrace)
              ],
            ),
            //
          ],
        ),
      ),
    );
  }
}