import 'package:flutter/material.dart';

class PageProfile extends StatefulWidget {
  PageProfileState createState() => PageProfileState();
}

class PageProfileState extends State<PageProfile> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

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
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                suffixIcon: _clearIconButton(_firstNameController),
                hintText: 'ваше ім\'я',
                labelText: 'Ім\'я *',
              ),
              validator: (value) {
                if (value.isEmpty) return 'ви не вказали ім\'я';
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                suffixIcon: _clearIconButton(_lastNameController),
                hintText: 'ваше прізвище',
                labelText: 'Прізвище *',
              ),
              validator: (value) {
                if (value.isEmpty) return 'ви не вказали прізвище';
              },
              onChanged: (value) {
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}
