import 'package:enterprise/models/warehouse/partners.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartnersView extends StatefulWidget{

  final Partners currentPartners;

  PartnersView({
    @required this.currentPartners
  });

  createState() => _PartnersState(currentPartners);
}

class _PartnersState extends State<PartnersView>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fieldName = TextEditingController();

  final Partners _currentPartners;

  _PartnersState(this._currentPartners){
    if(_currentPartners != null){
      _fieldName.text = _currentPartners.name;
    }
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
          appBar: AppBar(title: Text("Перегляд партнера"),),
          body: Container(
            margin: EdgeInsets.only(right: 20.0),
            child: Form(
                key: _formKey,
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
