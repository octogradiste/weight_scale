import 'package:flutter/material.dart';

class WeightDisplay extends StatelessWidget {
  final double weight;
  final double fontSize;
  final int precision;

  const WeightDisplay(
      {Key? key, required this.weight, this.fontSize = 48, this.precision = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: weight.toStringAsFixed(precision),
            style: TextStyle(fontSize: fontSize),
          ),
          TextSpan(
            text: ' kg',
            style: TextStyle(fontSize: fontSize / 2),
          ),
        ],
      ),
    );
  }
}
