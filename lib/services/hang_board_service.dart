import 'dart:async';

import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/activity/hang_board_state.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/core/entity/exercise_stats.dart';
import 'package:climb_scale/utils/logger.dart';

class HangBoardService {
  static const String _className = 'HangBoardService';

  final Stopwatch _stopwatch;
  final StreamController<HangBoardState> _controller =
      StreamController.broadcast();

  Completer<bool> _done = Completer();

  HangBoardService(
    Stopwatch stopwatch,
  ) : _stopwatch = stopwatch;

  /// A broadcast stream emitting the new states every second after [start]ing.
  Stream<HangBoardState> get state => _controller.stream;

  /// True when paused.
  bool get isPaused => throw UnimplementedError();

  /// Starts emitting to the [state] stream.
  ///
  /// Returns the measurements only if the exercise was not stopped else
  /// will return null.
  Future<List<Measurement>?> start({
    required Iterable<HangBoardState> states,
    required Stream<double> pull,
  }) async {
    _stopwatch.reset();

    List<Measurement> measurements = [];
    _done = Completer();

    var iterator = states.iterator;
    var callback = () {
      if (iterator.moveNext()) {
        _controller.add(iterator.current);
      } else {
        if (!_done.isCompleted) _done.complete(true);
      }
    };

    callback();
    Timer timer = Timer.periodic(const Duration(seconds: 1), (_) => callback());

    var sub = pull.listen((value) => measurements
        .add(Measurement(pull: iterator.current.isHanging ? value : 0, elapsed: _stopwatch.elapsed)));

    _stopwatch.start();

    bool completed = await _done.future;

    timer.cancel();
    sub.cancel();

    return completed ? measurements : null;
  }

  /// Pauses the exercise.
  ///
  /// The future completes if either [resume] or [stop] is called.
  Future<void> pause() async {
    throw UnimplementedError();
  }

  /// If [isPaused], will resume the exercise.
  void resume() {
    throw UnimplementedError();
  }

  /// If exercising, will stop the exercise and [start] will return null.
  void stop() {
    _stopwatch.stop();
    if (!_done.isCompleted) {
      _done.complete(false);
    }
  }

  /// Generates (in order) all the different states of the given [exercise].
  static Iterable<HangBoardState> generate(Exercise exercise) sync* {
    for (int sec = exercise.countdown.inSeconds; sec > 0; sec--) {
      yield HangBoardState(
        exercise: exercise,
        currentRep: 0,
        currentSet: 0,
        time: Duration(seconds: sec),
        hand: Hand.none,
        state: HangBoardActivityType.countdown,
      );
    }
    for (int set = 1; set <= exercise.sets; set++) {
      switch (exercise.hands) {
        case Hands.both:
          for (int rep = 1; rep <= exercise.reps; rep++) {
            for (int sec = exercise.hangTime.inSeconds; sec > 0; sec--) {
              yield HangBoardState(
                exercise: exercise,
                currentRep: rep,
                currentSet: set,
                time: Duration(seconds: sec),
                hand: Hand.both,
                state: HangBoardActivityType.hang,
              );
            }
            if (rep != exercise.reps) {
              for (int sec = exercise.restBetweenReps.inSeconds;
                  sec > 0;
                  sec--) {
                yield HangBoardState(
                  exercise: exercise,
                  currentRep: rep,
                  currentSet: set,
                  time: Duration(seconds: sec),
                  hand: Hand.none,
                  state: HangBoardActivityType.rep_rest,
                );
              }
            }
          }
          break;
        case Hands.block_wise:
          for (int rep = 1; rep <= exercise.reps; rep++) {
            for (int sec = exercise.hangTime.inSeconds; sec > 0; sec--) {
              yield HangBoardState(
                exercise: exercise,
                currentRep: rep,
                currentSet: set,
                time: Duration(seconds: sec),
                hand: Hand.first,
                state: HangBoardActivityType.hang,
              );
            }
            if (rep != exercise.reps) {
              for (int sec = exercise.restBetweenReps.inSeconds;
                  sec > 0;
                  sec--) {
                yield HangBoardState(
                  exercise: exercise,
                  currentRep: rep,
                  currentSet: set,
                  time: Duration(seconds: sec),
                  hand: Hand.none,
                  state: HangBoardActivityType.rep_rest,
                );
              }
            }
          }
          for (int sec = exercise.restBetweenHands.inSeconds; sec > 0; sec--) {
            yield HangBoardState(
              exercise: exercise,
              currentRep: exercise.reps,
              currentSet: set,
              time: Duration(seconds: sec),
              hand: Hand.none,
              state: HangBoardActivityType.hand_rest,
            );
          }
          for (int rep = 1; rep <= exercise.reps; rep++) {
            for (int sec = exercise.hangTime.inSeconds; sec > 0; sec--) {
              yield HangBoardState(
                exercise: exercise,
                currentRep: rep,
                currentSet: set,
                time: Duration(seconds: sec),
                hand: Hand.second,
                state: HangBoardActivityType.hang,
              );
            }
            if (rep != exercise.reps) {
              for (int sec = exercise.restBetweenReps.inSeconds;
                  sec > 0;
                  sec--) {
                yield HangBoardState(
                  exercise: exercise,
                  currentRep: rep,
                  currentSet: set,
                  time: Duration(seconds: sec),
                  hand: Hand.none,
                  state: HangBoardActivityType.rep_rest,
                );
              }
            }
          }
          break;
      }
      if (set != exercise.sets) {
        for (int sec = exercise.restBetweenSets.inSeconds; sec > 0; sec--) {
          yield HangBoardState(
            exercise: exercise,
            currentRep: exercise.reps,
            currentSet: set,
            time: Duration(seconds: sec),
            hand: Hand.none,
            state: HangBoardActivityType.set_rest,
          );
        }
      }
    }
  }

  /// Returns the slope from [m1] to [m2].
  ///
  /// It's expected that [m1] was measured before [m2].
  static double _slope(Measurement m1, Measurement m2) {
    return (m2.pull - m1.pull).toDouble() /
        (m2.elapsed - m1.elapsed).inMicroseconds.toDouble();
  }

  /// Returns the linearly interpolated measurement at time [e] between [m1]
  /// and [m2].
  ///
  /// It's expected that [m1] was measured before [m2].
  static Measurement _interpolate(Measurement m1, Measurement m2, Duration e) {
    return Measurement(
      pull: m1.pull + _slope(m1, m2) * (e - m1.elapsed).inMicroseconds,
      elapsed: e,
    );
  }

  /// Returns the elapsed time at which the linearly interpolated values
  /// between [m1] and [m2] equals [p].
  ///
  /// It's expected that [m1] was measured before [m2].
  static Duration _interpolateDuration(
    Measurement m1,
    Measurement m2,
    double p,
  ) {
    int inMicroSec = ((p - m1.pull) / _slope(m1, m2)).round();
    return Duration(microseconds: inMicroSec) + m1.elapsed;
  }

  /// Returns the time in which the linearly interpolated values between [m1]
  /// and [m2] are in the target zone.
  ///
  /// It's expected that [m1] was measured before [m2].
  static Duration _timeInTargetZone(
    Measurement m1,
    Measurement m2,
    Exercise exercise,
  ) {
    double lowerBound = exercise.target - exercise.deviation;
    double upperBound = exercise.target + exercise.deviation;

    if (m1.pull < lowerBound) {
      if (m2.pull < lowerBound) {
        return Duration.zero;
      } else if (m2.pull <= upperBound) {
        return m2.elapsed - _interpolateDuration(m1, m2, lowerBound);
      } else {
        return _interpolateDuration(m1, m2, upperBound) -
            _interpolateDuration(m1, m2, lowerBound);
      }
    } else if (m1.pull <= upperBound) {
      if (m2.pull < lowerBound) {
        return _interpolateDuration(m1, m2, lowerBound) - m1.elapsed;
      } else if (m2.pull <= upperBound) {
        return m2.elapsed - m1.elapsed;
      } else {
        return _interpolateDuration(m1, m2, upperBound) - m1.elapsed;
      }
    } else {
      if (m2.pull < lowerBound) {
        return _interpolateDuration(m1, m2, lowerBound) -
            _interpolateDuration(m1, m2, upperBound);
      } else if (m2.pull <= upperBound) {
        return m2.elapsed - _interpolateDuration(m1, m2, upperBound);
      } else {
        return Duration.zero;
      }
    }
  }

  /// Returns the area under the linearly interpolated line from [m1] to [m2]
  /// in kg * microsecond.
  ///
  /// It's expected that [m1] was measured before [m2].
  static double _area(Measurement m1, Measurement m2) {
    return (m1.pull + m2.pull) / 2.0 * (m2.elapsed - m1.elapsed).inMicroseconds;
  }

  /// Calculates the exercise stats of the [states] given the [measurements].
  ///
  /// The [measurements] are expected to be ordered from first to last.
  /// If there are no [measurements] or no [states] it returns the
  /// [ExerciseStats.ZERO].
  ///
  /// If there is no starting measurement, an imaginary measurement of 0kg is
  /// used instead. Likewise, if there is no measurement at the end, an
  /// imaginary measurement with the same pulling value as the last real
  /// measurement is added at the end.
  ///
  /// To compute the stats, it uses linear interpolation between the
  /// [measurements]. The average pull of a hand is calculated by dividing the
  /// area under the interpolated curve by the total time the hand is pulling.
  static ExerciseStats calculateStats(
    List<Measurement> measurements,
    Iterable<HangBoardState> states,
  ) {
    // If either measurements of states is empty, return zero stats.
    if (measurements.isEmpty || states.isEmpty) {
      Logger.w(_className, 'The measurements or the states are empty.');
      return ExerciseStats.ZERO;
    }

    // If necessary add 0kg measurement to the beginning of the measurements.
    if (measurements.first.elapsed != Duration.zero) {
      measurements.insert(0, Measurement(pull: 0, elapsed: Duration.zero));
    }

    // If necessary add additional measurement at the end with the same value
    // as the last real measurement.
    Duration totalTime = const Duration(seconds: 1) * states.length;
    if (measurements.last.elapsed != totalTime) {
      measurements.add(Measurement(
        pull: measurements.last.pull,
        elapsed: totalTime,
      ));
    }

    double areaFirst = 0;
    double areaSecond = 0;

    double areaFirstRep = 0;
    double areaSecondRep = 0;
    double areaFirstRepMax = 0;
    double areaSecondRepMax = 0;

    Duration totalTimeFirst = Duration.zero;
    Duration totalTimeSecond = Duration.zero;

    Duration timeInTargetFirst = Duration.zero;
    Duration timeInTargetSecond = Duration.zero;

    // TODO: investigate if it is necessary, that all states contain the exercise.
    // The exercise is assumed to be the same for all states.
    Exercise exercise = states.first.exercise;

    Duration elapsed = Duration.zero;

    // It's guaranteed to have at least to measurements (at the start and at the end of the exercise).
    int currentMeasurement = 0;
    Measurement current = measurements[currentMeasurement];
    Measurement next = measurements[currentMeasurement + 1];

    for (var state in states) {
      elapsed += const Duration(seconds: 1);
      // if this is the start of new rep
      Logger.d(_className, 'Looping states. State found: ${state.time.toString()}.');
      if ((state.time == state.exercise.hangTime)&&(state.isHanging)){
        areaFirstRep = 0;
        Logger.d(_className, 'Looping states. new rep found, aera intialized to 0');
      }
      var compute = (Measurement m1, Measurement m2) {
        if (state.isResting) return;
        var totalTime = m2.elapsed - m1.elapsed;
        var area = _area(m1, m2);
        var timeInTarget = _timeInTargetZone(m1, m2, exercise);
        if (state.hand == Hand.both || state.hand == Hand.first) {
          areaFirst += area;
          totalTimeFirst += totalTime;
          timeInTargetFirst += timeInTarget;
          areaFirstRep += area;
        }
        if (state.hand == Hand.both || state.hand == Hand.second) {
          areaSecond += area;
          totalTimeSecond += totalTime;
          timeInTargetSecond += timeInTarget;
          areaSecondRep += area;
        }
      };
      if(state.isHanging) {
        Logger.d(_className, 'Looping states. aeraFirstRep: ${areaFirstRep.toString()}.');
        Logger.d(_className, 'Looping states. aeraSecondRep: ${areaSecondRep.toString()}.');
      }
      // loop through all measurements for this state (1 state every second)
      while (next.elapsed < elapsed) {
        compute(current, next);
        currentMeasurement++;
        current = measurements[currentMeasurement];
        next = measurements[currentMeasurement + 1];
        // 'next' exists because the last measurement is not < elapsed but ==.
      }
      Measurement inBetween = _interpolate(current, next, elapsed);
      compute(current, inBetween);
      current = inBetween;

      // if this is the end of rep (is not resting and timer is at 1 second)
      if ((state.time == const Duration (seconds: 1))&&(state.isHanging)){
        Logger.d(_className, 'Looping states. last state of rep reached');
        if(areaFirstRep>areaFirstRepMax) {areaFirstRepMax = areaFirstRep;}
        if(areaSecondRep>areaSecondRepMax) {areaSecondRepMax = areaSecondRep;}
        Logger.d(_className, 'Looping states. aeraFirstRepMax: ${areaFirstRepMax.toString()}.');
        Logger.d(_className, 'Looping states. aeraSecondRepMax: ${areaSecondRepMax.toString()}.');
      }
    }

    // TODO: is the first hand really the left hand?
    return ExerciseStats(
      percentInTargetLeft: (100 *
              timeInTargetFirst.inMicroseconds /
              totalTimeFirst.inMicroseconds)
          .round(),
      percentInTargetRight: (100 *
              timeInTargetSecond.inMicroseconds /
              totalTimeSecond.inMicroseconds)
          .round(),
      averagePullLeft: areaFirst / totalTimeFirst.inMicroseconds,
      averagePullRight: areaSecond / totalTimeSecond.inMicroseconds,
      maxPullLeft: areaFirstRepMax /  states.first.exercise.hangTime.inMicroseconds,
      maxPullRight: areaSecondRepMax / states.first.exercise.hangTime.inMicroseconds,
    );
  }
}
