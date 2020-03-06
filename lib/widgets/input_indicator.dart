import 'package:flutter/material.dart';

class InputIndicator extends StatelessWidget {
  final int size;
  final String input;
  final Color filledColor;
  final Color emptyColor;

  InputIndicator({
    this.size,
    this.input,
    this.filledColor,
    this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> _indicators = [];
    for (int i = 0; i < size; i++) {
      _indicators.add(_singleIndicator(i));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _indicators,
    );
  }

  Widget _singleIndicator(int index) {
    return Row(
      children: <Widget>[
        Icon(
          input.length > index ? Icons.lens : Icons.panorama_fish_eye,
          color: input.length > index
              ? filledColor != null ? filledColor : Colors.green.shade400
              : emptyColor != null ? emptyColor : Colors.grey.shade500,
        ),
        SizedBox(
          width: index < size ? 10.0 : 0.0,
        ),
      ],
    );
  }
}
