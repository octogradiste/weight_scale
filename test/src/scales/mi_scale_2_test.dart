import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

import 'abstract_weight_scale_test.mocks.dart';

void main() {
  late MiScale2 scale;

  setUp(() {
    scale = MiScale2(device: MockBluetoothDevice());
  });

  group('onData', () {
    test('Should return null When has not 13 bytes', () {
      final weight = scale.onData(Uint8List.fromList(List.of([1, 2, 3, 4])));
      expect(weight, isNull);
    });

    test('Should return 70.2 kg the last to bytes are 6C 1B', () {
      final weight = scale.onData(Uint8List.fromList(
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xD8, 0x36],
      ));
      expect(weight, const Weight(70.2, WeightUnit.kg));
    });

    test(
        'Should return 12.34 lbs When the last to bytes are D2 04 and bit seven is 1',
        () {
      final weight = scale.onData(Uint8List.fromList(
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xD2, 0x04],
      ));
      expect(weight, const Weight(12.34, WeightUnit.lbs));
    });

    test('Should return null When unit is catty i.e. when bit nine is 1', () {
      final weight = scale.onData(Uint8List.fromList(
        [0, 0x40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xD4, 0x04],
      ));
      expect(weight, isNull);
    });
  });

  group('hasStabilized', () {
    test('Should return false When not stabilized i.e. bit number ten is 0',
        () {
      final data = Uint8List.fromList(
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xD8, 0x36],
      );
      expect(scale.hasStabilized(data), isFalse);
    });

    test('Should return false When has not 13 entries', () {
      final d1 = Uint8List.fromList([0, 0x20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      final d2 = Uint8List.fromList(
        [0, 0x20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      );

      expect(scale.hasStabilized(d1), isFalse);
      expect(scale.hasStabilized(d2), isFalse);
    });

    test('Should return true When stabilized i.e. bit number ten is 1', () {
      final data = Uint8List.fromList(
        [0, 0x20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xD8, 0x36],
      );
      expect(scale.hasStabilized(data), isTrue);
    });
  });
}
