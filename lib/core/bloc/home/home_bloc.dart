import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/data/repository.dart';
import 'package:climb_scale/services/navigation_service.dart';
import 'package:climb_scale/ui/page/activity_page.dart';
import 'package:climb_scale/ui/page/create_exercise_page.dart';
import 'package:climb_scale/ui/page/exercise_log_detail_page.dart';
import 'package:climb_scale/ui/page/hang_board_detail_page.dart';
import 'package:climb_scale/utils/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const String _className = 'HomeBloc';

  final Repository _repository;
  final INavigationService _navigationService;

  HomeBloc({
    required Repository repository,
    required INavigationService navigationService,
  })  : _repository = repository,
        _navigationService = navigationService,
        super(LoadingState()) {
    on<InitializeEvent>((event, emit) async {
      await _repository.initialize();
      add(ShowExercisesEvent());
    });

    on<ShowExerciseLogsEvent>(((event, emit) async {
      Logger.d(_className, 'Showing exercise logs.');
      List<ExerciseLog> logs = await _repository.getExerciseLogs();
      logs.sort((e1, e2) => e2.date.compareTo(e1.date));
      emit(ShowExerciseLogsState(logs));
    }));

    on<ShowExerciseLogEvent>(((event, emit) {
      Logger.d(_className, 'Moving to the exercise log detail page.');
      _navigationService.navigateTo(ExerciseLogDetailPage(
        bloc: this,
        log: event.log,
      ));
    }));

    on<ExportAllLogsEvent>((event, emit) async  {
      Logger.d(_className, 'Exporting all logs.');
      List<ExerciseLog> logs = await _repository.getExerciseLogs();
      logs.sort((e1, e2) => e2.date.compareTo(e1.date));
      String s ="date;weight;"
          "name;target;countdown;reps;hangTime;restBetweenReps;sets;restBetweenSets;restBetweenHands;hands;deviation;hold;grip;"
          "percentInTargetLeft;percentInTargetRight;averagePullLeft;averagePullRight;"
          "elapsed;pull\n";
      for (var log in logs){
        s+=log.toCSV();
      }
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      String today = DateFormat('y-MM-dd').format(DateTime.now());
      String filename = '$path/exported-logs-$today.csv';
      Logger.d(_className, 'Filename is $filename.');
      final File file = File(filename);
      file.writeAsString(s);
      Share.shareFiles([filename]);
    });

    on<ShowHangBoardsEvent>((event, emit) async {
      Logger.d(_className, 'Showing hang-boards.');
      List<HangBoard> hangBoards = await _repository.getHangBoards();
      emit(ShowHangBoardsState(hangBoards));
    });

    on<ShowHangBoardEvent>((event, emit) {
      Logger.d(_className, 'Moving to the hang-board page.');
      _navigationService.navigateTo(
        HangBoardDetailPage(hangBoard: event.hangBoard),
      );
    });

    on<CreateExerciseEvent>((event, emit) async {
      Logger.d(_className, 'Moving to the create exercise page.');
      _navigationService.navigateTo(CreateExercisePage(
        bloc: this,
        template: event.template,
        edit: event.edit,
      ));
    });

    on<ShowExercisesEvent>((event, emit) async {
      Logger.d(_className, 'Showing exercises.');
      List<Exercise> exercises = await _repository.getExercises();
      emit(ShowExercisesState(exercises));
    });

    on<SaveExerciseEvent>((event, emit) async {
      emit(LoadingState());
      await _repository.saveExercise(event.exercise);
      _navigationService.pop();
      add(ShowExercisesEvent());
    });

    on<EditExerciseEvent>((event, emit) async {
      emit(LoadingState());
      await _repository.deleteExercise(event.old);
      await _repository.saveExercise(event.edited);
      _navigationService.pop();
      add(ShowExercisesEvent());
    });

    on<DeleteExerciseEvent>((event, emit) async {
      emit(LoadingState());
      await _repository.deleteExercise(event.exercise);
      add(ShowExercisesEvent());
    });

    on<StartActivityEvent>((event, emit) async {
      _navigationService.navigateTo(ActivityPage(exercise: event.exercise));
    });

    add(InitializeEvent());
  }
}
