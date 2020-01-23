import 'package:enterprise/models.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/route_generator.dart';

void main() => runApp(EnterpriseApp());

class EnterpriseApp extends StatefulWidget {
  EnterpriseAppState createState() => EnterpriseAppState();
}

class EnterpriseAppState extends State<EnterpriseApp> {
  void initState() {
    Timing.closePastOperation();
    Timing.clearCurrentOperation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        primaryColor: Colors.green.shade700,
        accentColor: Colors.green.shade500,
        dividerColor: Colors.green.shade900,
        primaryIconTheme: IconThemeData(
          color: Colors.green.shade500,
        ),
      ),
    );
  }
}
