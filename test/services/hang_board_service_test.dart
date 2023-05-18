import 'dart:async';

import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/activity/hang_board_state.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/core/entity/exercise_stats.dart';
import 'package:climb_scale/core/entity/grip.dart';
import 'package:climb_scale/core/entity/hold.dart';
import 'package:climb_scale/services/hang_board_service.dart';
import 'package:climb_scale/utils/logger.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class FakeStopwatch extends Mock implements Stopwatch {}

void main() {
  Logger.logLevel = LogLevel.none;

  const Exercise eBlockWise = Exercise(
    name: "test",
    countdown: Duration(seconds: 2),
    reps: 2,
    hangTime: Duration(seconds: 2),
    restBetweenReps: Duration(seconds: 3),
    sets: 2,
    restBetweenSets: Duration(minutes: 2),
    hands: Hands.block_wise,
    restBetweenHands: Duration(seconds: 1),
    target: 30,
    deviation: 2,
    grip: Grip.FOUR_FINGER_HALF_CRIMP,
    hold: Hold.TWENTY_MIL_EDGE,
    isAssessment: false,
  );

  const Exercise eBoth = Exercise(
    name: "test",
    reps: 2,
    countdown: Duration(seconds: 10),
    hangTime: Duration(seconds: 2),
    restBetweenReps: Duration(seconds: 3),
    sets: 2,
    restBetweenSets: Duration(minutes: 2),
    hands: Hands.both,
    restBetweenHands: Duration(seconds: 15),
    target: 30,
    deviation: 10,
    grip: Grip.FOUR_FINGER_HALF_CRIMP,
    hold: Hold.TWENTY_MIL_EDGE,
    isAssessment: false,
  );

  final List<HangBoardState> states = [
    HangBoardState(
      exercise: Exercise.DEFAULT,
      currentRep: 0,
      currentSet: 0,
      time: const Duration(seconds: 1),
      hand: Hand.none,
      state: HangBoardActivityType.countdown,
    ),
    HangBoardState(
      exercise: Exercise.DEFAULT,
      currentRep: 1,
      currentSet: 1,
      time: const Duration(seconds: 1),
      hand: Hand.first,
      state: HangBoardActivityType.hang,
    ),
  ];

  group('HangBoardService', () {
    late StreamController<double> pullController;
    late HangBoardService service;

    setUp(() {
      service = HangBoardService(Stopwatch());
      pullController = StreamController.broadcast();
    });

    tearDown(() async {
      service.stop();
      await pullController.close();
    });
    group('state', () {
      test('Should be a broadcast steam', () {
        expect(service.state.isBroadcast, isTrue);
      });
    });

    group('stop', () {
      test('Should subscribe to the weight of wsService', () async {
        service.start(states: states, pull: pullController.stream);
        service.stop();
        await Future.delayed(Duration.zero);
        expect(pullController.hasListener, isFalse);
      });

      test('Should call stop on stopwatch When stopped', () async {
        FakeStopwatch stopwatch = FakeStopwatch();
        service = HangBoardService(stopwatch);
        service.start(states: states, pull: pullController.stream);
        service.stop();
        verify(stopwatch.stop());
      });

      test('Should not emit new states When stopped', () {
        fakeAsync((async) {
          service.start(states: states, pull: pullController.stream);
          service.stop();
          service.state.listen((event) {
            throw Exception('Should not emit any new state. $event');
          });
          async.elapse(const Duration(hours: 1));
        });
      });
    });

    group('start', () {
      tearDown(() {
        service.stop();
      });

      test('Should call reset on stopwatch When started', () async {
        FakeStopwatch stopwatch = FakeStopwatch();
        service = HangBoardService(stopwatch);
        service.start(states: states, pull: pullController.stream);
        verify(stopwatch.reset());
      });

      test('Should call start on stopwatch When started', () async {
        FakeStopwatch stopwatch = FakeStopwatch();
        service = HangBoardService(stopwatch);
        service.start(states: states, pull: pullController.stream);
        verify(stopwatch.start());
      });

      test('Should end after 2 seconds When not stopped', () {
        fakeAsync((async) {
          var done = false;
          service = HangBoardService(clock.stopwatch());
          service
              .start(states: states, pull: pullController.stream)
              .then((_) => done = true);

          async.elapse(const Duration(milliseconds: 1999));
          expect(done, isFalse);
          async.elapse(const Duration(milliseconds: 1));
          expect(done, isTrue);
        });
      });

      test('Should subscribe to the weight of wsService', () {
        var service = HangBoardService(Stopwatch());
        service.start(
          states: states,
          pull: pullController.stream,
        );
        expect(pullController.hasListener, isTrue);
        service.stop();
      });

      test('Should return measurements When not stopped', () {
        fakeAsync(((async) {
          var done = false;
          service = HangBoardService(clock.stopwatch());
          service
              .start(states: states, pull: pullController.stream)
              .then((measurements) {
            expect(measurements, [
              Measurement(pull: 25, elapsed: const Duration(milliseconds: 200)),
              Measurement(pull: 36, elapsed: const Duration(milliseconds: 1100)),
              Measurement(pull: 5, elapsed: const Duration(milliseconds: 1800)),
            ]);
            done = true;
          });

          async.elapse(const Duration(milliseconds: 200)); // 200ms
          pullController.add(25);

          async.elapse(const Duration(milliseconds: 900)); // 1100ms
          pullController.add(36);

          async.elapse(const Duration(milliseconds: 700)); // 1800ms
          pullController.add(5);

          async.elapse(const Duration(milliseconds: 200)); // 2000ms

          async.flushMicrotasks();

          expect(done, isTrue);
        }));
      });

      test('Should return null When stopped', () {
        fakeAsync(((async) {
          var done = false;
          service = HangBoardService(clock.stopwatch());
          service
              .start(states: states, pull: pullController.stream)
              .then((measurements) {
            expect(measurements, null);
            done = true;
          });

          async.elapse(const Duration(milliseconds: 200));
          pullController.add(25);

          service.stop();

          async.flushMicrotasks();

          expect(done, isTrue);
        }));
      });

      test('Should emit new states every second When started', () {
        fakeAsync(((async) {
          var done = false;
          var count = 0;
          service = HangBoardService(clock.stopwatch());
          service.state.forEach((element) {
            expect(async.elapsed, const Duration(seconds: 1) * count);
            count++;
          });
          service
              .start(states: states, pull: pullController.stream)
              .then((measurements) {
            done = true;
          });

          async.elapse(const Duration(milliseconds: 2000));

          async.flushMicrotasks();

          expect(done, isTrue);
          expect(count, 2);
        }));
      });
    });

    group('calculateStats', () {
      final List<Measurement> measurements = [
        Measurement(pull: 0, elapsed: const Duration(seconds: 0)),
        Measurement(pull: 2, elapsed: const Duration(seconds: 2)),
        Measurement(pull: 4, elapsed: const Duration(seconds: 3)),
        Measurement(pull: 5, elapsed: const Duration(seconds: 4)),
        Measurement(pull: 5, elapsed: const Duration(seconds: 6)),
        Measurement(pull: 3, elapsed: const Duration(seconds: 10)),
        Measurement(pull: 0, elapsed: const Duration(seconds: 11)),
        Measurement(pull: 3, elapsed: const Duration(seconds: 13)),
        Measurement(pull: 5, elapsed: const Duration(seconds: 14)),
        Measurement(pull: 7, elapsed: const Duration(seconds: 16)),
        Measurement(pull: 9, elapsed: const Duration(seconds: 18)),
      ];

      const Exercise exerciseBockWise = Exercise(
        name: 'test block wise',
        countdown: Duration(seconds: 1),
        reps: 1,
        hangTime: Duration(seconds: 7),
        restBetweenReps: Duration.zero,
        sets: 1,
        restBetweenSets: Duration.zero,
        hands: Hands.block_wise,
        restBetweenHands: Duration(seconds: 3),
        target: 5,
        deviation: 1,
        hold: Hold.TWENTY_MIL_EDGE,
        grip: Grip.FOUR_FINGER_HALF_CRIMP,
        isAssessment: false,
      );

      const Exercise exerciseBoth = Exercise(
        name: 'test both',
        countdown: Duration(seconds: 1),
        reps: 2,
        hangTime: Duration(seconds: 7),
        restBetweenReps: Duration(seconds: 3),
        sets: 1,
        restBetweenSets: Duration.zero,
        hands: Hands.both,
        restBetweenHands: Duration.zero,
        target: 5,
        deviation: 1,
        hold: Hold.TWENTY_MIL_EDGE,
        grip: Grip.FOUR_FINGER_HALF_CRIMP,
        isAssessment: false,
      );

      final List<HangBoardState> states = [
        HangBoardState(
          exercise: exerciseBoth,
          currentRep: 1,
          currentSet: 1,
          time: const Duration(seconds: 3),
          hand: Hand.both,
          state: HangBoardActivityType.hang,
        ),
        HangBoardState(
          exercise: exerciseBoth,
          currentRep: 1,
          currentSet: 1,
          time: const Duration(seconds: 2),
          hand: Hand.both,
          state: HangBoardActivityType.hang,
        ),
      ];

      test('Should return the zero stats When states is empty', () {
        expect(
          HangBoardService.calculateStats(measurements, []),
          ExerciseStats.ZERO,
        );
      });

      test('Should return the zero stats When measurements is empty', () {
        expect(
          HangBoardService.calculateStats([], states),
          ExerciseStats.ZERO,
        );
      });

      test(
          'Should add imaginary measurement (same as last in list) When last measurement is not provided',
          () {
        var measurements = [
          Measurement(pull: 5, elapsed: const Duration(seconds: 0)),
        ];
        expect(
          HangBoardService.calculateStats(measurements, states),
          const ExerciseStats(
            percentInTargetLeft: 100,
            percentInTargetRight: 100,
            averagePullLeft: 5,
            averagePullRight: 5,
            maxPullRight: 5,
            maxPullLeft: 5,
          ),
        );
      });

      test(
          'Should add imaginary 0kg measurement When first measurement is not provided',
          () {
        var measurements = [
          Measurement(pull: 3, elapsed: const Duration(seconds: 2)),
        ];
        expect(
          HangBoardService.calculateStats(measurements, states),
          const ExerciseStats(
            percentInTargetLeft: 0,
            percentInTargetRight: 0,
            averagePullLeft: 1.5,
            averagePullRight: 1.5,
            maxPullLeft: 1.5,
            maxPullRight: 1.5
          ),
        );
      });

      test('Should return the correct exercise stats When block wise hands',
          () {
        var states = HangBoardService.generate(exerciseBockWise);
        expect(
          HangBoardService.calculateStats(measurements, states),
          ExerciseStats(
            percentInTargetLeft: (500.0 / 7.0).round(),
            percentInTargetRight: (150.0 / 7.0).round(),
            averagePullLeft: 4,
            averagePullRight: 5,
            maxPullRight: 4,
            maxPullLeft: 5,
          ),
        );
      });

      test('Should return the correct exercise stats When both hands', () {
        var states = HangBoardService.generate(exerciseBoth);
        expect(
          HangBoardService.calculateStats(measurements, states),
          ExerciseStats(
            percentInTargetLeft: (650.0 / 14.0).round(),
            percentInTargetRight: (650.0 / 14.0).round(),
            averagePullLeft: 4.5,
            averagePullRight: 4.5,
            maxPullRight: 1,
            maxPullLeft: 1,
          ),
        );
      });

      test(
          'Should work When measurements are first under and then over the target zone',
          () {
        var measurements = [
          Measurement(pull: 0, elapsed: Duration.zero),
          Measurement(pull: 18, elapsed: const Duration(seconds: 18)),
        ];
        var states = HangBoardService.generate(exerciseBockWise);
        expect(
          HangBoardService.calculateStats(measurements, states),
          ExerciseStats(
            percentInTargetLeft: (200.0 / 7.0).round(),
            percentInTargetRight: 0,
            averagePullLeft: 4.5,
            averagePullRight: 14.5,
            maxPullLeft: 4.5,
            maxPullRight: 14.5,
          ),
        );
      });

      test(
          'Should work When measurements are first over and then under the target zone',
          () {
        var measurements = [
          Measurement(pull: 18, elapsed: Duration.zero),
          Measurement(pull: 0, elapsed: const Duration(seconds: 18)),
        ];
        var states = HangBoardService.generate(exerciseBockWise);
        expect(
          HangBoardService.calculateStats(measurements, states),
          ExerciseStats(
            percentInTargetLeft: 0,
            percentInTargetRight: (200 / 7.0).round(),
            averagePullLeft: 13.5,
            averagePullRight: 3.5,
            maxPullLeft: 13.5,
            maxPullRight: 3.5,
          ),
        );
      });
    });

    group('generate', () {
      test('Should return the right number of states When doing block wise',
          () {
        expect(HangBoardService.generate(eBlockWise).length, 152);
      });

      test('Should return right number of states When doing both hands', () {
        expect(HangBoardService.generate(eBoth).length, 144);
      });

      test('Should return the right first 8 states When doing block wise', () {
        var states = HangBoardService.generate(eBlockWise);
        expect(
          states,
          containsAllInOrder([
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 0,
              currentSet: 0,
              time: const Duration(seconds: 2),
              hand: Hand.none,
              state: HangBoardActivityType.countdown,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 0,
              currentSet: 0,
              time: const Duration(seconds: 1),
              hand: Hand.none,
              state: HangBoardActivityType.countdown,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 2),
              hand: Hand.first,
              state: HangBoardActivityType.hang,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 1),
              hand: Hand.first,
              state: HangBoardActivityType.hang,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 3),
              hand: Hand.none,
              state: HangBoardActivityType.rep_rest,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 2),
              hand: Hand.none,
              state: HangBoardActivityType.rep_rest,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 1),
              hand: Hand.none,
              state: HangBoardActivityType.rep_rest,
            ),
            HangBoardState(
              exercise: eBlockWise,
              currentRep: 2,
              currentSet: 1,
              time: const Duration(seconds: 2),
              hand: Hand.first,
              state: HangBoardActivityType.hang,
            ),
          ]),
        );
      });

      test('Should return the right states When doing both hands', () {
        var states = HangBoardService.generate(eBoth);
        expect(
          states,
          containsAll([
            HangBoardState(
              exercise: eBoth,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 1),
              hand: Hand.both,
              state: HangBoardActivityType.hang,
            ),
            HangBoardState(
              exercise: eBoth,
              currentRep: 1,
              currentSet: 1,
              time: const Duration(seconds: 1),
              hand: Hand.none,
              state: HangBoardActivityType.rep_rest,
            ),
            HangBoardState(
              exercise: eBoth,
              currentRep: 2,
              currentSet: 1,
              time: const Duration(seconds: 65),
              hand: Hand.none,
              state: HangBoardActivityType.set_rest,
            ),
            HangBoardState(
              exercise: eBoth,
              currentRep: 1,
              currentSet: 2,
              time: const Duration(seconds: 3),
              hand: Hand.none,
              state: HangBoardActivityType.rep_rest,
            ),
            HangBoardState(
              exercise: eBoth,
              currentRep: 2,
              currentSet: 2,
              time: const Duration(seconds: 2),
              hand: Hand.both,
              state: HangBoardActivityType.hang,
            ),
          ]),
        );
      });
    });
  });
}
