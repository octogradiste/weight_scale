part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class InitializeEvent extends HomeEvent {}

class ShowHangBoardsEvent extends HomeEvent {}

class ShowHangBoardEvent extends HomeEvent {
  final HangBoard hangBoard;

  ShowHangBoardEvent(this.hangBoard);

  @override
  List<Object> get props => [hangBoard];
}

class ShowExercisesEvent extends HomeEvent {}

class ShowExerciseLogsEvent extends HomeEvent {}

class ShowExerciseLogEvent extends HomeEvent {
  final ExerciseLog log;

  ShowExerciseLogEvent(this.log);

  @override
  List<Object> get props => [log];
}

class ExportAllLogsEvent extends HomeEvent {}

class CreateExerciseEvent extends HomeEvent {
  final Exercise template;
  final bool edit;

  CreateExerciseEvent(this.template, this.edit);

  @override
  List<Object> get props => [template, edit];
}

class SaveExerciseEvent extends HomeEvent {
  final Exercise exercise;

  SaveExerciseEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class EditExerciseEvent extends HomeEvent {
  final Exercise old;
  final Exercise edited;

  EditExerciseEvent(this.old, this.edited);

  @override
  List<Object> get props => [old, edited];
}

class DeleteExerciseEvent extends HomeEvent {
  final Exercise exercise;

  DeleteExerciseEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class StartActivityEvent extends HomeEvent {
  final Exercise exercise;

  StartActivityEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}
