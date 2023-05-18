import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/data/local/database.dart';
import 'package:climb_scale/utils/logger.dart';

class Repository {
  static const String _className = 'Repository';
  late final Database _db;

  Repository({required Database database}) {
    _db = database;
  }

  Future<void> initialize() async {
    await _db.initialize();
  }

  Future<void> saveExercise(Exercise exercise) {
    Logger.d(_className, 'Saving ${exercise.name}');
    return _db.exerciseDao.saveExercise(exercise);
  }

  Future<void> updateExercise(Exercise exercise) {
    Logger.d(_className, 'Updating ${exercise.name}');
    return _db.exerciseDao.updateExercise(exercise);
  }

  Future<void> deleteExercise(Exercise exercise) {
    Logger.d(_className, 'Deleting ${exercise.name}');
    return _db.exerciseDao.deleteExercise(exercise);
  }

  Future<List<Exercise>> getExercises() {
    return _db.exerciseDao.getExercises();
  }

  Future<void> saveExerciseLog(ExerciseLog log) {
    return _db.logDao.saveExerciseLog(log);
  }

  Future<void> deleteExerciseLog(ExerciseLog log) {
    return _db.logDao.deleteExerciseLog(log);
  }

  Future<List<ExerciseLog>> getExerciseLogs() {
    return _db.logDao.getExerciseLogs();
  }

  Future<void> saveHangBoard(HangBoard hangBoard) {
    return _db.hangBoardDao.saveHangBoard(hangBoard);
  }

  Future<void> deleteHangBoard(HangBoard hangBoard) {
    return _db.hangBoardDao.deleteHangBoard(hangBoard);
  }

  Future<List<HangBoard>> getHangBoards() {
    return _db.hangBoardDao.getHangBoards();
  }
}
