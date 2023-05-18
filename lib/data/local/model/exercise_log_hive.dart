import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/data/local/model/exercise_hive.dart';
import 'package:climb_scale/data/local/model/exercise_stats_hive.dart';
import 'package:hive/hive.dart';

part 'exercise_log_hive.g.dart';

@HiveType(typeId: 7)
class MeasurementHive extends HiveObject {
  @HiveField(0)
  final double weight;
  @HiveField(1)
  final int elapsed;

  MeasurementHive({required this.weight, required this.elapsed});

  MeasurementHive.fromWeightMeasurement(Measurement measurement)
      : weight = measurement.pull,
        elapsed = measurement.elapsed.inMilliseconds;

  Measurement toWeighMeasurement() {
    return Measurement(pull: weight, elapsed: Duration(milliseconds: elapsed));
  }
}

@HiveType(typeId: 8)
class ExerciseLogHive extends HiveObject {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final ExerciseHive exercise;
  @HiveField(2)
  final double weight;
  @HiveField(3)
  final int mark;
  @HiveField(4)
  final String note;
  @HiveField(5)
  final ExerciseStatsHive stats;
  @HiveField(6)
  final List<MeasurementHive> measurements;

  ExerciseLogHive({
    required this.date,
    required this.exercise,
    required this.weight,
    required this.mark,
    required this.note,
    required this.stats,
    required this.measurements,
  });

  ExerciseLogHive.fromExerciseLog(ExerciseLog log)
      : date = log.date,
        exercise = ExerciseHive.fromExercise(log.exercise),
        weight = log.weight,
        stats = ExerciseStatsHive.fromExerciseStatsHive(log.stats),
        mark = log.mark,
        note = log.note,
        measurements = log.measurements
            .map((m) => MeasurementHive.fromWeightMeasurement(m))
            .toList();

  ExerciseLog toExerciseLog() {
    return ExerciseLog(
      date: date,
      exercise: exercise.toExercise(),
      weight: weight,
      stats: stats.toExerciseStats(),
      mark: mark,
      note: note,
      measurements: measurements.map((m) => m.toWeighMeasurement()).toList(),
    );
  }
}
