import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DigitalKeyboard extends StatelessWidget {
  final Function(String value) onPressed;

  DigitalKeyboard({
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 265.0,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _keyForm(_keyButton("7"), "7"),
              _keyForm(_keyButton("8"), "8"),
              _keyForm(_keyButton("9"), "9"),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _keyForm(_keyButton("4"), "4"),
              _keyForm(_keyButton("5"), "5"),
              _keyForm(_keyButton("6"), "6"),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _keyForm(_keyButton("1"), "1"),
              _keyForm(_keyButton("2"), "2"),
              _keyForm(_keyButton("3"), "3"),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _keyForm(_keyButton(""), ""),
              _keyForm(_keyButton("0"), "0"),
              _keyForm(Icon(Icons.keyboard_backspace), "<"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyForm(Widget buttonChild, String symbol) {
    return RawMaterialButton(
      child: SizedBox(
        width: 40.0,
        height: 40.0,
        child: Center(
          child: buttonChild,
        ),
      ),
      onPressed: () {
        symbol.isNotEmpty ? onPressed(symbol) : Container();
      },
      elevation: symbol.isNotEmpty ? 5.0 : 0.0,
      fillColor: symbol.isNotEmpty ? Colors.white : null,
      padding: const EdgeInsets.all(15.0),
      shape: symbol.isNotEmpty
          ? CircleBorder(side: BorderSide(color: Colors.grey.shade300))
          : CircleBorder(),
    );
  }

  Widget _keyButton(String symbol) {
    return Text(
      symbol,
      style: TextStyle(fontSize: 30.0),
    );
  }
}
