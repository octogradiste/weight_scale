import 'dart:async';
import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/data/local/dao/exercise_dao.dart';
import 'package:climb_scale/data/local/dao/exercise_log_dao.dart';
import 'package:climb_scale/data/local/dao/hang_board_dao.dart';
import 'package:climb_scale/data/local/model/exercise_log_hive.dart';
import 'package:climb_scale/data/local/model/exercise_stats_hive.dart';
import 'package:climb_scale/data/local/model/hang_board_hive.dart';
import 'package:climb_scale/data/local/model/hold_hive.dart';
import 'package:climb_scale/data/local/sample_exercises.dart';
import 'package:climb_scale/data/local/model/exercise_hive.dart';
import 'package:climb_scale/data/local/model/grip_hive.dart';
import 'package:hive_flutter/adapters.dart';

class Database {
  static const String EXERCISE_BOX = 'exercise_box';
  static const String EXERCISE_LOG_BOX = 'exercise_log_box';
  static const String HANG_BOARD_BOX = 'hang_board_box';

  late final ExerciseDao exerciseDao;
  late final ExerciseLogDao logDao;
  late final HangBoardDao hangBoardDao;

  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await Hive.initFlutter();

      // Registering all hive adapters.
      Hive.registerAdapter(HandsHiveAdapter());
      Hive.registerAdapter(ExerciseHiveAdapter());
      Hive.registerAdapter(GripPositionHiveAdapter());
      Hive.registerAdapter(GripHiveAdapter());
      Hive.registerAdapter(HoldHiveAdapter());
      Hive.registerAdapter(HangBoardHiveAdapter());
      Hive.registerAdapter(ExerciseStatsHiveAdapter());
      Hive.registerAdapter(MeasurementHiveAdapter());
      Hive.registerAdapter(ExerciseLogHiveAdapter());

      // Opening hive boxes.
      Box<ExerciseHive> exerciseBox = await Hive.openBox(EXERCISE_BOX);
      Box<ExerciseLogHive> logBox = await Hive.openBox(EXERCISE_LOG_BOX);
      Box<HangBoardHive> hangBoardBox = await Hive.openBox(HANG_BOARD_BOX);

      exerciseDao = ExerciseDao(exerciseBox);
      logDao = ExerciseLogDao(logBox);
      hangBoardDao = HangBoardDao(hangBoardBox);

      // Add sample exercises.
      for (Exercise exercise in sample_exercises) {
        exerciseDao.saveExercise(exercise);
      }

      hangBoardDao.saveHangBoard(beastmaker1000);

      _initialized = true;
    }
  }
}
