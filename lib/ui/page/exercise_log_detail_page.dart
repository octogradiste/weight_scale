import 'package:climb_scale/core/bloc/home/home_bloc.dart';
import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/ui/widget/exercise_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseLogDetailPage extends StatelessWidget {
  final ExerciseLog log;
  final HomeBloc bloc;

  static const Map<int, String> markSentence = {
    0: 'You did not gave a mark.',
    1: 'It was not your day.',
    2: 'You were not in your best shape.',
    3: 'You felt alright.',
    4: 'You felt strong on this one! ',
    5: 'You were super strong!'
  };

  const ExerciseLogDetailPage({
    Key? key,
    required this.log,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateFormat('EEEE, dd.MM.y HH:mm').format(log.date)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.exercise.name, style: textTheme.headlineSmall),
                  for (var line in _exerciseSummary(log.exercise))
                    Text(line, style: textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Text(
                    markSentence[log.mark] ?? 'Invalid mark: ${log.mark}.',
                    style: textTheme.headlineSmall,
                  ),
                  Text(
                    log.note.isEmpty ? 'You did not leave a note.' : log.note,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: SfCartesianChart(
                  // margin: EdgeInsets.zero,
                  zoomPanBehavior: ZoomPanBehavior(enablePanning: true),
                  primaryXAxis: NumericAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    visibleMaximum: 10000,
                    axisLabelFormatter: (details) => ChartAxisLabel(
                      '${(details.value / 1000).round()}s',
                      details.textStyle,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    plotBands: [
                      PlotBand(
                          opacity: 0.3,
                          color: Colors.green,
                          start: log.exercise.target - log.exercise.deviation,
                          end: log.exercise.target + log.exercise.deviation)
                    ],
                    // labelPosition: ChartDataLabelPosition.inside,
                    // labelAlignment: LabelAlignment.end,
                    // edgeLabelPlacement: EdgeLabelPlacement.shift,
                    // axisLine: AxisLine(width: 0),
                    // majorTickLines: MajorTickLines(size: 0),
                    // minorTickLines: MinorTickLines(size: 0),
                    interval: 5,
                    axisLabelFormatter: (details) => ChartAxisLabel(
                      '${details.value.round()} kg',
                      details.textStyle,
                    ),
                  ),
                  series: [
                    LineSeries<Measurement, int>(
                      dataSource: log.measurements,
                      xValueMapper: (measurement, _) =>
                          measurement.elapsed.inMilliseconds,
                      yValueMapper: (measurement, _) => measurement.pull,
                      markerSettings: const MarkerSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: ExerciseStats(log: log),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _exerciseSummary(Exercise exercise) {
    String sets = Intl.plural(
      exercise.sets,
      one: '1 set',
      other: '${exercise.sets} sets',
    );
    String reps = Intl.plural(
      exercise.reps,
      one: '1 rep',
      other: '${exercise.reps} reps',
    );
    String hands = exercise.hands == Hands.block_wise ? 'alternating' : 'both';
    NumberFormat weight = NumberFormat('##0kg');
    return [
      '$sets x $reps x (${exercise.hangTime.inSeconds}s-${exercise.restBetweenReps.inSeconds}s) with ${exercise.restBetweenSets.inSeconds}s rest',
      'target ${weight.format(exercise.target)} + ${weight.format(exercise.deviation)} deviation',
      '$hands hands',
    ];
  }
}
