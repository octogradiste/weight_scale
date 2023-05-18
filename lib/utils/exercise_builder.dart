import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/grip.dart';
import 'package:climb_scale/core/entity/hold.dart';

/// A builder class for an exercise.
class ExerciseBuilder {
  String name;
  Duration countdown;
  int reps;
  Duration hangTime;
  Duration restBetweenReps;
  int sets;
  Duration restBetweenSets;

  Hands hands;
  Duration restBetweenHands;

  double target;

  double deviation;

  Grip grip;
  Hold hold;

  bool isAssessment;

  ExerciseBuilder({
    required this.name,
    required this.countdown,
    required this.reps,
    required this.hangTime,
    required this.restBetweenReps,
    required this.sets,
    required this.restBetweenSets,
    required this.hands,
    required this.restBetweenHands,
    required this.target,
    required this.deviation,
    required this.hold,
    required this.grip,
    required this.isAssessment,
  });

  ExerciseBuilder.fromExercise(Exercise exercise)
      : name = exercise.name,
        countdown = exercise.countdown,
        reps = exercise.reps,
        hangTime = exercise.hangTime,
        restBetweenReps = exercise.restBetweenReps,
        sets = exercise.sets,
        restBetweenSets = exercise.restBetweenSets,
        hands = exercise.hands,
        restBetweenHands = exercise.restBetweenHands,
        target = exercise.target,
        deviation = exercise.deviation,
        grip = exercise.grip,
        hold = exercise.hold,
        isAssessment = exercise.isAssessment;

  Exercise build() {
    return Exercise(
      name: name,
      countdown: countdown,
      reps: reps,
      hangTime: hangTime,
      restBetweenReps: restBetweenReps,
      sets: sets,
      restBetweenSets: restBetweenSets,
      hands: hands,
      restBetweenHands: restBetweenHands,
      target: target,
      deviation: deviation,
      hold: hold,
      grip: grip,
      isAssessment: isAssessment,
    );
  }
}
