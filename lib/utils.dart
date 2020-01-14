import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utility {
  static Image ImageFromBase64String(String value) {
    return Image.memory(
      base64Decode(value),
      fit: BoxFit.fill,
    );
  }
}
