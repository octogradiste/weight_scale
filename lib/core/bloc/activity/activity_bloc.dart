import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:climb_scale/core/entity/activity/connection_information.dart';
import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/activity/hang_board_state.dart';
import 'package:climb_scale/core/entity/activity/ongoing_activity.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/data/repository.dart';
import 'package:climb_scale/services/audio_service.dart';
import 'package:climb_scale/services/hang_board_service.dart';
import 'package:climb_scale/services/navigation_service.dart';
import 'package:climb_scale/services/screen_service.dart';
import 'package:climb_scale/services/snack_bar_service.dart';
import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:climb_scale/ui/dialog/connection_detail_dialog.dart';
import 'package:climb_scale/ui/snack_bar/info_snack_bar.dart';
import 'package:climb_scale/utils/logger.dart';
import 'package:climb_scale/utils/stream_merge_ext.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weight_scale/scale.dart' hide ScanResult;

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  static final String _className = 'ActivityBloc';

  final IAudioService _audioService;
  final HangBoardService _hbService;
  final INavigationService _navigationService;
  final IScreenService _screenService;
  final ISnackBarService _sbService;
  final IWeightScaleService _wsService;
  final Repository _repository;

  /// The subscription to the info stream of the [_hbService] for
  /// (un)registering sounds.
  late StreamSubscription<HangBoardState> _soundSubscription;

  ActivityBloc({
    required IAudioService audioService,
    required HangBoardService hangBoardService,
    required INavigationService navigationService,
    required IScreenService screenService,
    required ISnackBarService snackBarService,
    required IWeightScaleService weightScaleService,
    required Repository repository,
  })  : _audioService = audioService,
        _hbService = hangBoardService,
        _navigationService = navigationService,
        _screenService = screenService,
        _sbService = snackBarService,
        _wsService = weightScaleService,
        _repository = repository,
        super(InitializeState()) {
    on<InitializeEvent>((event, emit) async {
      emit(InitializeState());
      await _wsService.initialize();
      await _repository.initialize();

      if (await Permission.bluetoothScan.request().isDenied) {
        throw Exception("Not allowed to perform a BLE Scan!");
      }
      if (await Permission.bluetoothConnect.request().isDenied) {
        throw Exception("Not allowed to connect to a BLE device!");
      }

      _wsService.setUnexpectedDisconnectCallback((result) {
        add(UnexpectedDisconnectEvent(result));
      });

      add(StartScanEvent());
    });

    on<StartScanEvent>((event, emit) {
      _wsService.startScan().then((_) => add(StopScanEvent()));
      emit(BleScanState(_wsService.results, true));
    });

    on<StopScanEvent>((event, emit) async {
      if (state is BleScanState) {
        await _wsService.stopScan();
        emit(BleScanState(_wsService.results, false));
      }
    });

    on<ConnectEvent>((event, emit) async {
      emit(ConnectingState(
        ConnectionInformation(
          result: event.result,
          initialConnection: _wsService.status,
          connection: _wsService.connection,
        ),
      ));
      await _wsService.stopScan();
      try {
        await _wsService.connect(event.result);
        emit(TakeWeightState(
          information: _getCurrentConnectionInformation(),
          weight: _wsService.weight,
        ));
      } on WeightScaleException catch (e) {
        emit(ConnectionFailedState(e.message));
      }
    });

    on<UnexpectedDisconnectEvent>((event, emit) async {
      Logger.w(_className, 'Unexpected disconnect. Trying to reconnect.');
      _sbService.showSnackBar(InfoSnackBar('Trying to reconnect...'));
      try {
        await _wsService.connect(event.result);
        _sbService.showSnackBar(InfoSnackBar('Successfully reconnected!'));
      } on WeightScaleException catch (_) {
        add(UnexpectedDisconnectEvent(event.result));
      }
    });

    on<BeginActivityEvent>((event, emit) async {
      _screenService.wakeLockOn();
      _registerSounds();

      var pull = _wsService.weight.map((value) => event.weight - value);

      var activity = _hbService.state.merge<double, OngoingActivity>(
        other: pull,
        initialValue: 0.0,
        onMerge: (info, pull) => OngoingActivity(info: info, pull: pull),
      );

      var states = HangBoardService.generate(event.exercise);

      emit(DoActivityState(
        information: _getCurrentConnectionInformation(),
        initialState: OngoingActivity(info: states.first, pull: 0.0),
        state: activity,
      ));

      var measurements = await _hbService.start(
        states: states,
        pull: pull,
      );

      if (measurements != null) {
        _audioService.play(Sound.beep_endOfExercise);
        _wsService.disconnect();

        ExerciseLog log = ExerciseLog(
          date: DateTime.now(),
          exercise: event.exercise,
          weight: event.weight,
          mark: 0,
          note: '',
          stats: HangBoardService.calculateStats(measurements, states),
          measurements: measurements,
        );

        emit(FinishedActivityState(log));
      }

      _unregisterSounds();
      _screenService.wakeLockOff();
    });

    on<SaveExerciseLog>((event, emit) {
      _repository.saveExerciseLog(event.log);
      add(PagePopEvent());
    });

    on<ShowConnectionDetail>((event, emit) {
      ConnectionInformation information = _getCurrentConnectionInformation();
      _navigationService.showPopUpDialog(ConnectionDetailDialog(
        information: information,
        onReconnect: () {
          _wsService.reconnect();
          _navigationService.pop();
        },
      ));
    });

    on<PagePopEvent>((event, emit) {
      if (state is ConnectedState || state is ConnectingState) {
        _wsService.disconnect();
      } else if (state is BleScanState) {
        _wsService.stopScan();
      }

      if (state is DoActivityState) {
        _hbService.stop();
      }

      _navigationService.pop();
    });

    add(InitializeEvent());
  }

  /// Can only be used when already in a connected state.
  ConnectionInformation _getCurrentConnectionInformation() {
    return ConnectionInformation(
      result: (state as ConnectedState).information.result,
      initialConnection: _wsService.status,
      connection: _wsService.connection,
    );
  }

  void _unregisterSounds() {
    _soundSubscription.cancel();
  }

  void _registerSounds() {
    _soundSubscription = _hbService.state.listen(null);
    _soundSubscription.onData((info) {
      if (info.time.inSeconds == info.totalTime.inSeconds) {
        switch (info.state) {
          case HangBoardActivityType.countdown:
            break;
          case HangBoardActivityType.hang:
            _audioService.play(Sound.beep_hang);
            break;
          case HangBoardActivityType.rep_rest:
            _audioService.play(Sound.beep_rest);
            break;
          case HangBoardActivityType.set_rest:
            _audioService.play(Sound.beep_endOfSet);
            break;
          case HangBoardActivityType.hand_rest:
            _audioService.play(Sound.beep_endOfHand);
            break;
        }
      }
      if (info.time.inSeconds <= 3) {
        if (info.state == HangBoardActivityType.hand_rest ||
            info.state == HangBoardActivityType.set_rest ||
            info.state == HangBoardActivityType.countdown) {
          _audioService.play(Sound.beep_countDown);
        }
      }
    });
  }
}
