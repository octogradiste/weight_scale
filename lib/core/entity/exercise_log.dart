import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/exercise_stats.dart';
import 'package:equatable/equatable.dart';

class Measurement extends Equatable {
  final double pull;
  final Duration elapsed;

  Measurement({required this.pull, required this.elapsed});

  String toCSV (){
    String csvOutput = "$elapsed;${pull.toStringAsFixed(2)};";
    return csvOutput;
  }
  @override
  List<Object?> get props => [pull, elapsed];
}

class ExerciseLog extends Equatable {
  final DateTime date;
  final Exercise exercise;
  final double weight;
  final int mark;
  final String note;
  final ExerciseStats stats;
  final List<Measurement> measurements;

  ExerciseLog({
    required this.date,
    required this.exercise,
    required this.weight,
    required this.mark,
    required this.note,
    required this.stats,
    required this.measurements,
  });

  ExerciseLog addUserFeedback({required int mark, String note = ''}) {
    return ExerciseLog(
      date: date,
      exercise: exercise,
      weight: weight,
      mark: mark,
      note: note,
      stats: stats,
      measurements: measurements,
    );
  }
  String toCSV (){
    String csvOutput ="";
    String prefix = "$date;${weight.toStringAsFixed(2)};${exercise.toCSV()}${stats.toCSV()}";
    for (Measurement m in measurements){
      csvOutput+="$prefix${m.elapsed};${m.pull.toStringAsFixed(2)}\n";
    }
    return csvOutput;
  }
  @override
  List<Object?> get props => [date, exercise, weight, stats, measurements];
}
