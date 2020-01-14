import 'package:enterprise/main.dart';
import 'package:flutter/material.dart';

class PageProfile extends StatefulWidget {
  PageProfileState createState() => PageProfileState();
}

class PageProfileState extends State<PageProfile> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _itnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

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
        title: Text('Профіль'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Основне:',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey.shade800),
                ),
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
                    icon: SizedBox(
                      width: 24.0,
                    ),
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
                ),
                TextFormField(
                  controller: _middleNameController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    suffixIcon: _clearIconButton(_middleNameController),
                    hintText: 'по-батькові',
                    labelText: 'По-батькові *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали по-батькові';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _itnController,
                  decoration: InputDecoration(
                    icon: SizedBox(
                      width: 24.0,
                    ),
                    labelText: 'ІПН',
                    hintText: 'ваш ІПН (якщо немає, то серія і номер паспорта',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали ІПН/Паспорт';
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone),
                    suffixIcon: _clearIconButton(_phoneController),
                    hintText: 'номер ваого мобільного телефону',
                    labelText: 'Телефон *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали номер телефону';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    suffixIcon: _clearIconButton(_emailController),
                    hintText: 'ваш email',
                    labelText: 'Email *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'ви не вказали email';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Налаштування збережено'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  },
                  child: Text('Save'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.update),
        onPressed: () async {},
      ),
    );
  }
}
