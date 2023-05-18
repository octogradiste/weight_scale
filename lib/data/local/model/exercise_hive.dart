import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/data/local/model/grip_hive.dart';
import 'package:climb_scale/data/local/model/hold_hive.dart';
import 'package:hive/hive.dart';

part 'exercise_hive.g.dart';

@HiveType(typeId: 0)
enum HandsHive {
  @HiveField(0)
  both,
  @HiveField(1)
  block_wise,
}

@HiveType(typeId: 1)
class ExerciseHive extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int countdownMillis;
  @HiveField(2)
  final int reps;
  @HiveField(3)
  final int hangTimeMillis;
  @HiveField(4)
  final int restBetweenRepsMillis;
  @HiveField(5)
  final int sets;
  @HiveField(6)
  final int restBetweenSetsMillis;

  @HiveField(7)
  final HandsHive hands;
  @HiveField(8)
  final int restBetweenHandsMillis;

  @HiveField(9)
  final double target;

  @HiveField(10)
  final double deviation;

  @HiveField(11)
  final GripHive grip;

  @HiveField(12)
  final HoldHive hold;

  @HiveField(13)
  final bool isAssessment;

  ExerciseHive(
      this.name,
      this.countdownMillis,
      this.reps,
      this.hangTimeMillis,
      this.restBetweenRepsMillis,
      this.sets,
      this.restBetweenSetsMillis,
      this.hands,
      this.restBetweenHandsMillis,
      this.target,
      this.deviation,
      this.grip,
      this.hold,
      this.isAssessment,
  );

  ExerciseHive.fromExercise(Exercise exercise)
      : name = exercise.name,
        countdownMillis = exercise.countdown.inMilliseconds,
        reps = exercise.reps,
        hangTimeMillis = exercise.hangTime.inMilliseconds,
        restBetweenRepsMillis = exercise.restBetweenReps.inMilliseconds,
        sets = exercise.sets,
        restBetweenSetsMillis = exercise.restBetweenSets.inMilliseconds,
        hands = HandsHive.values[exercise.hands.index],
        restBetweenHandsMillis = exercise.restBetweenHands.inMilliseconds,
        target = exercise.target,
        deviation = exercise.deviation,
        grip = GripHive.fromGrip(exercise.grip),
        hold = HoldHive.fromHold(exercise.hold),
        isAssessment = exercise.isAssessment;

  Exercise toExercise() {
    return Exercise(
      name: name,
      countdown: Duration(milliseconds: countdownMillis),
      reps: reps,
      hangTime: Duration(milliseconds: hangTimeMillis),
      restBetweenReps: Duration(milliseconds: restBetweenRepsMillis),
      sets: sets,
      restBetweenSets: Duration(milliseconds: restBetweenSetsMillis),
      hands: Hands.values[hands.index],
      restBetweenHands: Duration(milliseconds: restBetweenHandsMillis),
      target: target,
      deviation: deviation,
      grip: grip.toGrip(),
      hold: hold.toHold(),
      isAssessment: isAssessment,
    );
  }
}
