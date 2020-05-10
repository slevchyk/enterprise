
import 'package:enterprise/models/warehouse/partners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartnersView extends StatelessWidget{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fieldName = TextEditingController();

  final Partners currentPartners;

  PartnersView({
    @required this.currentPartners
  }) {
    _fieldName.text = currentPartners.name;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onDoubleTap: () {
          Navigator.pop(context);
        },
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text("Партнер"),),
          body: Container(
            margin: EdgeInsets.only(right: 20.0),
            child: Form(
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      enabled: false,
                      controller: _fieldName,
                      decoration: InputDecoration(
                          icon: Icon(Icons.title),
                          labelText: 'Назва',
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }
}
