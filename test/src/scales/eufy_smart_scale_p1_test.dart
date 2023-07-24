import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';

import 'abstract_weight_scale_test.mocks.dart';

void main() {
  late EufySmartScaleP1 scale;

  setUp(() {
    scale = EufySmartScaleP1(device: MockBluetoothDevice());
  });

  group('onData', () {
    test('Should return null When has not 11 bytes', () {
      final weight = scale.onData(Uint8List.fromList(List.of([1, 2, 3, 4])));
      expect(weight, isNull);
    });

    test('Should return 72.6 kg When the data is 5C1C', () {
      final weight = scale.onData(Uint8List.fromList(
        List.of([0, 0, 0, 0x5C, 0x1C, 0, 0, 0, 0, 0, 0]),
      ));
      expect(weight, isNotNull);
      expect(weight!.value, 72.6);
      expect(weight.unit, WeightUnit.kg);
    });
  });

  group('hasStabilized', () {
    test('Should return false When not stabilized', () {
      final data =
          Uint8List.fromList([0xCF, 0, 0, 0xFF, 0xFF, 0, 0, 0, 0, 0xFF, 0xFF]);
      expect(scale.hasStabilized(data), isFalse);
    });

    test('Should return false When has not 11 entries', () {
      final d1 = Uint8List.fromList([1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
      final d2 = Uint8List.fromList([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);

      expect(scale.hasStabilized(d1), isFalse);
      expect(scale.hasStabilized(d2), isFalse);
    });

    test('Should return true When stabilized', () {
      final d1 = Uint8List.fromList([0xCF, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]);
      final d2 = Uint8List.fromList([0xCF, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]);
      final d3 = Uint8List.fromList([0xCF, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0]);

      expect(scale.hasStabilized(d1), isTrue);
      expect(scale.hasStabilized(d2), isTrue);
      expect(scale.hasStabilized(d3), isTrue);
    });
  });
}
