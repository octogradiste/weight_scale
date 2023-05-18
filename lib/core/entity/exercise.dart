import 'package:climb_scale/core/entity/grip.dart';
import 'package:climb_scale/core/entity/hold.dart';
import 'package:equatable/equatable.dart';

enum Hands { both, block_wise }

class Exercise extends Equatable {
  final String name;
  final Duration countdown;
  final int reps;
  final Duration hangTime;
  final Duration restBetweenReps;
  final int sets;
  final Duration restBetweenSets;

  final Hands hands;
  final Duration restBetweenHands;

  /// The target weight to pull in KG.
  final double target;

  /// The allowed deviation from the target in KG.
  final double deviation;

  final Grip grip;
  final Hold hold;

  /// Exercise can be a strength assessement (a strength test)
  final bool isAssessment;

  const Exercise({
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

  @override
  List<Object?> get props => [
        name,
        countdown,
        reps,
        hangTime,
        restBetweenReps,
        sets,
        restBetweenSets,
        hands,
        restBetweenHands,
        target,
        deviation,
        isAssessment,
      ];

  static const Exercise DEFAULT = Exercise(
    name: "",
    countdown: Duration(seconds: 10),
    reps: 15,
    hangTime: Duration(seconds: 7),
    restBetweenReps: Duration(seconds: 3),
    sets: 2,
    restBetweenSets: Duration(minutes: 1),
    hands: Hands.block_wise,
    restBetweenHands: Duration(seconds: 15),
    target: 15,
    deviation: 4,
    hold: Hold.TWENTY_MIL_EDGE,
    grip: Grip.FOUR_FINGER_HALF_CRIMP,
    isAssessment: false,
  );

  String getDescription() {
    return "$sets sets x $reps reps x (${hangTime.inSeconds}s-${restBetweenReps.inSeconds}s) "
        "with ${restBetweenSets.inSeconds}s rest. Target ${target.toStringAsFixed(0)}kg";
  }
  String toCSV (){
    String csvOutput = "$name;${target.toStringAsFixed(2)};$countdown;$reps;$hangTime;$restBetweenReps;$sets;$restBetweenSets;$hands;$restBetweenHands;${deviation.toStringAsFixed(2)};${hold.toCSV()}${grip.toCSV()}$isAssessment;";
    return csvOutput;
  }
}
