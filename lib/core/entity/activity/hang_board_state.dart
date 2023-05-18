import 'package:climb_scale/core/entity/exercise.dart';
import 'package:equatable/equatable.dart';

enum Hand { none, both, first, second }

enum HangBoardActivityType { countdown, hang, rep_rest, set_rest, hand_rest }

class HangBoardState extends Equatable {
  final Exercise exercise;
  final int currentRep;
  final int currentSet;
  final Duration time;
  final Hand hand;
  final HangBoardActivityType state;

  HangBoardState({
    required this.exercise,
    required this.currentRep,
    required this.currentSet,
    required this.time,
    required this.hand,
    required this.state,
  });

  Duration get totalTime {
    switch (state) {
      case HangBoardActivityType.countdown:
        return exercise.countdown;
      case HangBoardActivityType.hang:
        return exercise.hangTime;
      case HangBoardActivityType.rep_rest:
        return exercise.restBetweenReps;
      case HangBoardActivityType.set_rest:
        return exercise.restBetweenSets;
      case HangBoardActivityType.hand_rest:
        return exercise.restBetweenHands;
    }
  }

  bool get isHanging => state == HangBoardActivityType.hang;

  bool get isResting => !isHanging;

  bool get isFinished =>
      currentRep == exercise.reps &&
      currentSet == exercise.sets &&
      time.inSeconds == 0 &&
      (hand == Hand.both || hand == Hand.second);

  @override
  List<Object?> get props =>
      [exercise, currentRep, currentSet, time, state, hand];
}
