import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/data/local/model/exercise_log_hive.dart';
import 'package:hive/hive.dart';

class ExerciseLogDao {
  final Box<ExerciseLogHive> box;

  ExerciseLogDao(this.box);

  Future<void> deleteExerciseLog(ExerciseLog log) async {
    await box.delete(ExerciseLogHive.fromExerciseLog(log).date.millisecond);
  }

  Future<List<ExerciseLog>> getExerciseLogs() async {
    return box.values.map((e) => e.toExerciseLog()).toList();
  }

  Future<void> saveExerciseLog(ExerciseLog log) async {
    await box.put(log.date.millisecond, ExerciseLogHive.fromExerciseLog(log));
  }
}
