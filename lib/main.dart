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
}
