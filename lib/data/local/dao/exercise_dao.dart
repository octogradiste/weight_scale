import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/data/local/model/exercise_hive.dart';
import 'package:hive_flutter/adapters.dart';

class ExerciseDao {
  final Box<ExerciseHive> box;

  ExerciseDao(this.box);

  Future<void> deleteExercise(Exercise exercise) async {
    await box.delete(ExerciseHive.fromExercise(exercise).name);
  }

  Future<List<Exercise>> getExercises() async {
    return box.values.map((e) => e.toExercise()).toList();
  }

  Future<void> saveExercise(Exercise exercise) async {
    await box.put(exercise.name, ExerciseHive.fromExercise(exercise));
  }

  Future<void> updateExercise(Exercise exercise) async {
    await box.put(exercise.name, ExerciseHive.fromExercise(exercise));
  }
}
