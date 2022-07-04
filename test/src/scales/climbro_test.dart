import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/abstract_weight_scale.dart';
import 'package:weight_scale/src/scales/climbro.dart';

import '../fake_ble_device.dart';

void main() {
  late BleDevice device;
  late AbstractWeightScale scale;

  setUp(() {
    device = FakeBleDevice(id: "id", name: "name");
    scale = Climbro(device: device);
  });

  group('onData', () {
    test('Should return null When has more the one byte', () {
      final weight = scale.onData(Uint8List.fromList(List.of([1, 2, 3, 4])));
      expect(weight, isNull);
    });

    test('Should return 38 kg When the data is 38', () {
      final weight = scale.onData(Uint8List.fromList(List.of([38])));
      expect(weight, isNotNull);
      expect(weight!.weight, 38);
      expect(weight.unit, WeightUnit.kg);
    });
  });
}
