import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utility {
  static Image imageFromBase64String(String value) {
    return Image.memory(
      base64Decode(value),
      fit: BoxFit.fill,
    );
  }

  static DateTime beginningOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
