import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/route_generator.dart';
import 'package:flutter/material.dart';

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
    _sync();
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
//        dividerColor: Colors.transparent,
      ),
    );
  }

  void _sync() {
    CostItem.sync();
    IncomeItem.sync();
    Currency.sync();
    PayOffice.sync();
  }
}
