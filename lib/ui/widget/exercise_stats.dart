import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExerciseStats extends StatelessWidget {
  const ExerciseStats({
    Key? key,
    required this.log,
  }) : super(key: key);

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Stats',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            HandStats(
              hand: 'LEFT',
              averagePull: log.stats.averagePullLeft,
              percentInTarget: log.stats.percentInTargetLeft,
              maxPull: log.stats.maxPullLeft,
            ),
            HandStats(
              hand: 'RIGHT',
              averagePull: log.stats.averagePullRight,
              percentInTarget: log.stats.percentInTargetRight,
              maxPull: log.stats.maxPullRight,
            ),
          ],
        ),
      ],
    );
  }
}

class HandStats extends StatelessWidget {
  final String hand;
  final double averagePull;
  final double maxPull;
  final int percentInTarget;

  const HandStats({
    Key? key,
    required this.hand,
    required this.averagePull,
    required this.maxPull,
    required this.percentInTarget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(hand, style: textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          '${NumberFormat('##0.0kg').format(averagePull)} on average',
          style: textTheme.bodyMedium,
        ),
        Text(
          '$percentInTarget% in target zone',
          style: textTheme.bodyMedium,
        ),
        Text(
          '${NumberFormat('##0.0kg').format(maxPull)} maximum',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
