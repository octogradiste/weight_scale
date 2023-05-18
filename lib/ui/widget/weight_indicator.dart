import 'dart:math';

import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/ui/widget/weight_display.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WeightIndicator extends StatelessWidget {
  final double pull;
  final Exercise exercise;
  final WeightIndicatorDecoration decoration;

  const WeightIndicator({
    Key? key,
    required this.pull,
    required this.exercise,
    this.decoration = const WeightIndicatorDecoration(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: WeightIndicatorPainter(
        value: min(1, max(0, pull / 2 / exercise.target)),
        target: 0.5,
        deviation: exercise.deviation / 2 / exercise.target,
        decoration: decoration,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeightDisplay(weight: pull),
            const SizedBox(height: 12),
            WeightDisplay(weight: exercise.target, fontSize: 28),
          ],
        ),
      ),
    );
  }
}

class WeightIndicatorPainter extends CustomPainter {
  final double value;
  final double target;
  final double deviation;
  final WeightIndicatorDecoration decoration;

  /// The [value], the [target] and the [deviation] in percents (between 0 and 1).
  WeightIndicatorPainter({
    required this.value,
    required this.target,
    required this.deviation,
    this.decoration = const WeightIndicatorDecoration(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    Size square = Size(size.shortestSide, size.shortestSide);
    Offset offset = Offset((size.width - size.shortestSide) / 2,
        (size.height - size.shortestSide) / 2);
    Rect rect = offset & square;
    Paint paint = Paint()
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke;

    double range = decoration.range;
    double rangeStart = -(pi + range) / 2;
    double targetStart = rangeStart + max(0, range * (target - deviation));
    double targetEnd = rangeStart + min(range, range * (target + deviation));
    double valueStart =
        rangeStart + max(0, range * value - decoration.valueWidth);

    paint
      ..color = decoration.rangeColor
      ..strokeCap = decoration.rangeCap;
    canvas.drawArc(rect, rangeStart, range, false, paint);

    paint
      ..color = decoration.targetColor
      ..strokeCap = decoration.targetCap;
    canvas.drawArc(rect, targetStart, targetEnd - targetStart, false, paint);

    paint
      ..color = decoration.valueColor
      ..strokeCap = decoration.valueCap;
    canvas.drawArc(rect, valueStart, decoration.valueWidth, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    WeightIndicatorPainter old = oldDelegate as WeightIndicatorPainter;
    return old.decoration != decoration ||
        old.value != value ||
        old.target != target ||
        old.deviation != deviation;
  }
}

class WeightIndicatorDecoration extends Equatable {
  /// The [thickness] of the arc in pixels.
  final double thickness;

  /// The [range] in radians.
  final double range;

  /// The width in radians of the value bar.
  final double valueWidth;

  final Color valueColor;
  final Color targetColor;
  final Color rangeColor;

  final StrokeCap valueCap;
  final StrokeCap targetCap;
  final StrokeCap rangeCap;

  const WeightIndicatorDecoration({
    this.thickness = 30,
    this.range = 1.1 * pi,
    this.valueWidth = pi / 180,
    this.valueColor = Colors.black,
    this.targetColor = Colors.green,
    this.rangeColor = Colors.grey,
    this.valueCap = StrokeCap.round,
    this.targetCap = StrokeCap.round,
    this.rangeCap = StrokeCap.round,
  });

  @override
  List<Object?> get props => [
        thickness,
        range,
        valueWidth,
        valueColor,
        rangeColor,
        targetColor,
        valueCap,
        targetCap,
        rangeCap,
      ];
}
