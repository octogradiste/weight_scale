import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weight_scale/src/util/async_task_queue.dart';

void main() {
  group("AsyncTaskQueue", () {
    group("add", () {
      late AsyncTaskQueue queue;

      setUp(() {
        queue = AsyncTaskQueue();
      });

      test('if task throws exception then add method must too', () async {
        await expectLater(queue.add(() => throw Exception()),
            throwsA(TypeMatcher<Exception>()));
      });

      test("First added tasks gets executed immediately.", () {
        const int time = 1;
        fakeAsync((async) async {
          async.elapse(Duration(seconds: time));
          final result = await queue.add<int>(() {
            Future.delayed(Duration(seconds: time));
            return Future.value(1);
          });
          expect(result, 1);
        });
      });

      test("Tasks get executed in order.", () async {
        var results = <int>[];

        queue.add<void>(() async => results.add(1));
        queue.add<void>(() async => results.add(2));
        await queue.add<void>(() async => results.add(3));

        expect(results, containsAllInOrder([1, 2, 3]));
      });

      test("The next task gets executed after the current task finishes.", () {
        fakeAsync((async) async {
          List<int> results = List.empty(growable: true);

          final time1 = 1;
          final time2 = 2;
          final time3 = 3;

          queue
              .add<void>(() => Future.delayed(Duration(seconds: time1)))
              .then((_) => results.add(1));
          queue
              .add<void>(() => Future.delayed(Duration(seconds: time2)))
              .then((_) => results.add(2));
          queue
              .add<void>(() => Future.delayed(Duration(seconds: time3)))
              .then((_) => results.add(3));

          async.elapse(Duration(seconds: time1));
          expect(results, containsAllInOrder([1]));

          async.elapse(Duration(seconds: time2));
          expect(results, containsAllInOrder([1, 2]));

          async.elapse(Duration(seconds: time3));
          expect(results, containsAllInOrder([1, 2, 3]));
        });
      });
    });
  });
}
