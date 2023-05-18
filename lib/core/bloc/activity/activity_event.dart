part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object> get props => [];
}

class InitializeEvent extends ActivityEvent {}

class PagePopEvent extends ActivityEvent {}

class StartScanEvent extends ActivityEvent {}

class StopScanEvent extends ActivityEvent {}

class ConnectEvent extends ActivityEvent {
  final ScanResult result;

  ConnectEvent(this.result);

  @override
  List<Object> get props => [result];
}

class UnexpectedDisconnectEvent extends ActivityEvent {
  final ScanResult result;

  UnexpectedDisconnectEvent(this.result);

  @override
  List<Object> get props => [result];
}

class BeginActivityEvent extends ActivityEvent {
  final Exercise exercise;
  final double weight;

  BeginActivityEvent(this.exercise, this.weight);

  @override
  List<Object> get props => [exercise, weight];
}

class ShowConnectionDetail extends ActivityEvent {}

class SaveExerciseLog extends ActivityEvent {
  final ExerciseLog log;

  SaveExerciseLog(this.log);

  @override
  List<Object> get props => [log];
}
