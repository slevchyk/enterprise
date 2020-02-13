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
    Timing.syncCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        primaryColorDark: Color(0xFF455A64),
        primaryColor: Color(0xFF607D8B),
        primaryColorLight: Color(0xFFCFD8DC),
        accentColor: Colors.teal.shade700,
        dividerColor: Color(0xFFBDBDBD),
      ),
    );
  }
}
