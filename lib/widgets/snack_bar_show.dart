import 'dart:core';

import 'package:flutter/material.dart';

class ShowSnackBar{
  static show(GlobalKey<ScaffoldState> scaffoldKey, String title, Color color, {Duration duration}){
    scaffoldKey == null ? Container() :
    scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: duration == null ? Duration(milliseconds: 700) : duration,
          content: Text(title.capitalize()),
          backgroundColor: color,
        )
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}