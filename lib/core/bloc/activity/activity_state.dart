part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

class InitializeState extends ActivityState {}

class BleScanState extends ActivityState {
  final Stream<List<ScanResult>> results;
  final bool searching;

  BleScanState(this.results, this.searching);

  @override
  List<Object> get props => [results, searching];
}

abstract class ConnectedState extends ActivityState {
  final ConnectionInformation information;

  ConnectedState(this.information);

  @override
  List<Object> get props => [information];
}

class ConnectingState extends ConnectedState {
  ConnectingState(ConnectionInformation information) : super(information);
}

class ConnectionFailedState extends ActivityState {
  final String message;

  ConnectionFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class TakeWeightState extends ConnectedState {
  final Stream<double> weight;
  TakeWeightState({
    required ConnectionInformation information,
    required this.weight,
  }) : super(information);

  @override
  List<Object> get props => [weight, super.props];
}

class DoActivityState extends ConnectedState {
  final OngoingActivity initialState;
  final Stream<OngoingActivity> state;

  DoActivityState({
    required ConnectionInformation information,
    required this.initialState,
    required this.state,
  }) : super(information);

  @override
  List<Object> get props => [initialState, state, super.props];
}

class FinishedActivityState extends ActivityState {
  final ExerciseLog log;

  FinishedActivityState(this.log);

  @override
  List<Object> get props => [log];
}
