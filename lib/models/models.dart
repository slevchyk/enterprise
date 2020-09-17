import 'dart:ui';

import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/coordination.dart';
import 'package:enterprise/models/pay_office.dart';
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
  int initialPage;
  List<ImageProvider> listImage;
  List<dynamic> listDynamic;
  int currencyCode;
  PayOffice payOffice;
  PayDeskTypes type;
  List<Coordination> coordinationList;
  Function callback;

  RouteArgs({
    this.profile,
    this.scrollController,
    this.dateSort,
    this.showTransfer,
    this.initialPage,
    this.listImage,
    this.listDynamic,
    this.currencyCode,
    this.payOffice,
    this.type,
    this.coordinationList,
    this.callback,
  });
}
