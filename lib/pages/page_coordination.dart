
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/coordination.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/coordination_list.dart';
import 'package:enterprise/widgets/period_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageCoordination extends StatefulWidget {
  final Profile profile;

  PageCoordination({
    this.profile,
  });

  createState() => _PageCoordinationState();
}

class _PageCoordinationState extends State<PageCoordination>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  Map<SortControllers, bool> _controllersMap;

  Future<List<Coordination>> _coordinationList;

  Future<void> _load() async {
    _coordinationList = Coordination.getCoordinationList(_scaffoldKey).whenComplete(() => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _load();
    _controllersMap = PeriodDialog.setControllersMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Погодження"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              List<Coordination> _coordinationListWithoutNone =
              (await _coordinationList)
                  .where((element) => element.status!=CoordinationTypes.none)
                  .toList();
              RouteArgs args = RouteArgs(
                  coordinationList: _coordinationListWithoutNone,
              );
              Navigator.pushNamed(context, "/coordination/history", arguments: args);
            },
          ),
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                PeriodDialog.showPeriodDialog(context, _dateFrom, _dateTo, _controllersMap).whenComplete(() => setState((){}));
              }
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: (){
              _load();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation){
            return FutureBuilder(
              future: _coordinationList,
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
                    _coordinationList = _coordinationList.where((element) => element.status==CoordinationTypes.none).toList();
                    if(_coordinationList.length==0){
                      return Container(
                        child: Center(
                          child: Text(
                              "Відсутні заявки до погодження",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      );
                    }
                    return CoordinationList(
                        scaffoldKey: _scaffoldKey,
                        dateFromController: _dateFrom,
                        dateToController: _dateTo,
                        isPeriod: _controllersMap[SortControllers.period],
                        callback: _load,
                    )
                        .showCoordination(_coordinationList, false);
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
      ),
    );
  }
}