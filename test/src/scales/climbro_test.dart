import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/climbro.dart';

import 'abstract_weight_scale_test.mocks.dart';

void main() {
  late Climbro scale;

  setUp(() {
    scale = Climbro(device: MockBluetoothDevice());
  });

  group('onData', () {
    test('Should return null When has more the one byte', () {
      final weight = scale.onData(Uint8List.fromList(List.of([1, 2, 3, 4])));
      expect(weight, isNull);
    });

    test('Should return 38 kg When the data is 38', () {
      final weight = scale.onData(Uint8List.fromList(List.of([38])));
      expect(weight, isNotNull);
      expect(weight!.value, 38);
      expect(weight.unit, WeightUnit.kg);
    });
  });
}
