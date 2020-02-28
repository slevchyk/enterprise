import 'dart:ui';

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
  String userID;
  dynamic arg;

  RouteArgs(
    this.userID,
    this.arg,
  );
}
