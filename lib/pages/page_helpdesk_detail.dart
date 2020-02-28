import 'dart:convert';
import 'dart:io';

import 'package:enterprise/models/contatns.dart';
import 'package:enterprise/database/help_desk_dao.dart';
import 'package:enterprise/models/helpdesk.dart';
import 'package:enterprise/pages/page_helpdesk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageHelpdeskNew extends StatefulWidget {
  PageHelpdeskState createState() => PageHelpdeskState();
}

class PageHelpdeskState extends State<PageHelpdeskNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Widget _clearIconButton(TextEditingController textController) {
    if (textController.text.isEmpty)
      return null;
    else
      return IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              textController.clear();
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Створення'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.edit),
                          suffixIcon: _clearIconButton(_titleController),
                          hintText: 'Введіть заголовок',
                          labelText: 'Заголовок *',
                        ),
                        validator: (value) {
                          if (value.isEmpty) return 'ви не вказали заголовок';
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.format_align_left),
                          suffixIcon: _clearIconButton(_descriptionController),
                          hintText: 'Опис проблеми',
                          labelText: 'Опис *',
                        ),
                        maxLines: 9,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'ви не вказали опис проблеми';
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.update),
        onPressed: () {
          setState(() {});
        },
      ),
    );
  }
}
