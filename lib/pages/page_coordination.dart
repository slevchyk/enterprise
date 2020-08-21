import 'package:date_format/date_format.dart';
import 'package:enterprise/models/coordination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageCoordination extends StatefulWidget {

  createState() => _PageCoordinationState();

}

class _PageCoordinationState extends State<PageCoordination>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Погодження"),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {

            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, orientation) {
          return FutureBuilder(
            future: Coordination.getCoordinationList(),
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
                  return ListView.builder(
                    itemCount: _coordinationList.length,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        title: Text(_coordinationList.elementAt(index).name),
                        subtitle: Text(formatDate(_coordinationList.elementAt(index).date, [dd, '.', mm, '.', yyyy, ' ', HH, ':', mm])),
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
          );
        },
      ),
    );
  }

}