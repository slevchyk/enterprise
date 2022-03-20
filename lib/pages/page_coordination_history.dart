import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/coordination.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/coordination_list.dart';
import 'package:enterprise/widgets/period_dialog.dart';
import 'package:flutter/material.dart';

class PageCoordinationHistory extends StatefulWidget{
  final Profile profile;
  final List<Coordination> coordinationList;

  PageCoordinationHistory({
    this.profile,
    this.coordinationList,
  });

  createState() => _PageCoordinationHistoryState();
}

class _PageCoordinationHistoryState extends State<PageCoordinationHistory>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  Map<SortControllers, bool> _controllersMap;

  @override
  void initState() {
    super.initState();
    _controllersMap = PeriodDialog.setControllersMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Iсторiя погоджень"),
        actions: [
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: (){
                PeriodDialog.showPeriodDialog(context, _dateFrom, _dateTo, _controllersMap).whenComplete(() => setState((){}));
              }
          ),
        ],
      ),
      body: widget.coordinationList.length == 0
          ? Container(
              child: Center(
                child: Text(
                  "Iсторiя вiдсутня",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
      )
          : CoordinationList(
              scaffoldKey: _scaffoldKey,
              dateFromController: _dateFrom,
              dateToController: _dateTo,
              isPeriod: _controllersMap[SortControllers.period],)
                .showCoordination(widget.coordinationList, true),
    );
  }
}