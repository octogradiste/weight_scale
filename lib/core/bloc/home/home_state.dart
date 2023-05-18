part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class LoadingState extends HomeState {}

class ShowExercisesState extends HomeState {
  final List<Exercise> exercises;

  ShowExercisesState(this.exercises);

  @override
  List<Object> get props => [exercises];
}

class ShowExerciseLogsState extends HomeState {
  final List<ExerciseLog> logs;

  ShowExerciseLogsState(this.logs);

  @override
  List<Object> get props => [logs];
}

class ShowHangBoardsState extends HomeState {
  final List<HangBoard> hangBoards;

  ShowHangBoardsState(this.hangBoards);

  @override
  List<Object> get props => [hangBoards];
}
