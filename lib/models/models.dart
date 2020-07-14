import 'dart:ui';

import 'package:enterprise/models/profile.dart';
import 'package:flutter/cupertino.dart';

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
  ScrollController scrollController;
  DateTime dateSort;
  bool showTransfer;
  ImageProvider image;

  RouteArgs({
    this.profile,
    this.scrollController,
    this.dateSort,
    this.showTransfer,
    this.image,
  });
}
