import 'package:enterprise/models/expense.dart';
import 'package:enterprise/models/paydesk.dart';
import 'package:enterprise/models/purse.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/route_generator.dart';

import 'models/timing.dart';

void main() => runApp(EnterpriseApp());

class EnterpriseApp extends StatefulWidget {
  EnterpriseAppState createState() => EnterpriseAppState();
}

class EnterpriseAppState extends State<EnterpriseApp> {
  @override
  void initState() {
    super.initState();

    Timing.closePastTiming();
    Timing.downloadByDate(DateTime.now());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        primaryColorDark: Colors.grey.shade700,
        primaryColor: Colors.grey.shade600,
        primaryColorLight: Colors.grey.shade100,
        accentColor: Colors.lightGreen.shade700,
        dividerColor: Colors.grey.shade400,
      ),
    );
  }

  void _load(){
    PayDesk.sync();
    Expense.sync();
    Purse.sync();
  }
}
