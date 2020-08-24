import 'package:flutter/material.dart';

class MenuItem {
  String name;
  IconData icon;
  String category;
  String path;
  bool isDivider;

  MenuItem({
    this.name = "default",
    this.icon,
    this.category = "default",
    this.path,
    this.isDivider = false,
  });
}
