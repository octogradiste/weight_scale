import 'package:equatable/equatable.dart';

class ExerciseStats extends Equatable {
  /// The time in percent the left hand was in the target zone.
  final int percentInTargetLeft;

  /// The time in percent the right hand was in the target zone.
  final int percentInTargetRight;

  /// The average weight in kg the left hand pulled.
  final double averagePullLeft;

  /// The average weight in kg the right hand pulled.
  final double averagePullRight;

  /// The max weight in kg the left hand pulled during any rep.
  final double maxPullLeft;

  /// The max weight in kg the right hand pulled during any rep.
  final double maxPullRight;

  const ExerciseStats({
    required this.percentInTargetLeft,
    required this.percentInTargetRight,
    required this.averagePullLeft,
    required this.averagePullRight,
    required this.maxPullLeft,
    required this.maxPullRight,
  });
  String toCSV (){
    String csvOutput = "$percentInTargetLeft;$percentInTargetRight;${averagePullLeft.toStringAsFixed(2)};${averagePullRight.toStringAsFixed(2)};${maxPullLeft.toStringAsFixed(2)};${maxPullRight.toStringAsFixed(2)};";
    return csvOutput;
  }
  @override
  List<Object?> get props => [
        percentInTargetLeft,
        percentInTargetRight,
        averagePullLeft,
        averagePullRight,
        maxPullLeft,
        maxPullRight,
      ];

  static const ExerciseStats ZERO = ExerciseStats(
    percentInTargetLeft: 0,
    percentInTargetRight: 0,
    averagePullLeft: 0,
    averagePullRight: 0,
    maxPullLeft: 0,
    maxPullRight: 0,
  );
}
