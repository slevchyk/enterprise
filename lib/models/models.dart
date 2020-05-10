import 'dart:ui';

import 'package:enterprise/models/helpdesk.dart';
import 'package:enterprise/models/profile.dart';

class ChartData {
  String title;
  double value;
  Color color;

  ChartData({
    this.title,
    this.value,
    this.color,
  });
}

class UploadFile {
  String name;
  String data;

  UploadFile({
    this.name,
    this.data,
  });
}

class RouteArgs {
  Profile profile;

  RouteArgs({
    this.profile,
  });
}
