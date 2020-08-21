import 'package:flutter/material.dart';

class MenuItem{
  String name;
<<<<<<< HEAD
  IconData icon;
=======
  Icon icon;
>>>>>>> beta
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