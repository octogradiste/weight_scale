import 'package:climb_scale/core/entity/exercise_stats.dart';
import 'package:hive/hive.dart';

part 'exercise_stats_hive.g.dart';

@HiveType(typeId: 6)
class ExerciseStatsHive extends HiveObject {
  @HiveField(0)
  final int percentInTargetLeft;
  @HiveField(1)
  final int percentInTargetRight;
  @HiveField(2)
  final double averagePullLeft;
  @HiveField(3)
  final double averagePullRight;
  @HiveField(4)
  final double maxPullLeft;
  @HiveField(5)
  final double maxPullRight;

  ExerciseStatsHive({
    required this.percentInTargetLeft,
    required this.percentInTargetRight,
    required this.averagePullLeft,
    required this.averagePullRight,
    required this.maxPullLeft,
    required this.maxPullRight,
  });

  ExerciseStatsHive.fromExerciseStatsHive(ExerciseStats stats)
      : percentInTargetLeft = stats.percentInTargetLeft,
        percentInTargetRight = stats.percentInTargetRight,
        averagePullLeft = stats.averagePullLeft,
        averagePullRight = stats.averagePullRight,
        maxPullLeft = stats.maxPullLeft,
        maxPullRight = stats.maxPullRight;

  ExerciseStats toExerciseStats() {
    return ExerciseStats(
      percentInTargetLeft: percentInTargetLeft,
      percentInTargetRight: percentInTargetRight,
      averagePullLeft: averagePullLeft,
      averagePullRight: averagePullRight,
      maxPullLeft: maxPullLeft,
      maxPullRight: maxPullRight,
    );
  }
}
