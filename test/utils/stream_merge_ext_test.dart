import 'dart:async';

import 'package:climb_scale/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:climb_scale/utils/stream_merge_ext.dart';

void main() {
  Logger.logLevel = LogLevel.none;
  group('StreamMergeExt', () {
    group('merge', () {
      late StreamController<int> main;
      late StreamController<double> other;

      late Stream<double> merge;

      setUp(() {
        main = StreamController();
        other = StreamController();

        merge = main.stream.merge<double, double>(
          other: other.stream,
          initialValue: 5.5,
          onMerge: (m, o) => m + o,
        );
      });

      tearDown(() {
        main.close();
        other.close();
      });

      test(
          'Should emit first value of main with initValue When other has not emitted yet',
          () async {
        var value = merge.first;
        main.add(5);
        expect(await value, 10.5);
      });

      test(
          'Should emit first value of main with latest value of other When other has already emitted some values',
          () async {
        var value = merge.first;
        other.add(7);
        other.add(3.5);
        await Future.delayed(Duration.zero);
        main.add(5);
        expect(await value, 8.5);
      });

      test('Should emit latest from main with other When other emits',
          () async {
        var events = merge.take(2).toList();
        other.add(3);
        main.add(7);
        other.add(3.5);
        expect(await events, containsAllInOrder([10, 10.5]));
      });

      test('Should emit latest from other with main When main emits', () async {
        var events = merge.take(3).toList();
        main.add(3);
        other.add(5);
        main.add(4);
        expect(await events, containsAllInOrder([8.5, 8, 9]));
      });
    });
  });
}
