import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';
import 'package:weight_scale/src/scales/simple_weight_scale.dart';

import '../fake_ble_device.dart';

void main() {
  late BleDevice bleDevice;
  late SimpleWeightScale scale;

  setUp(() {
    bleDevice = FakeBleDevice(id: "id", name: "name");
    scale = EufySmartScaleP1(bleDevice: bleDevice);
  });

  test('the [name] is Eufy Smart Scale P1', () {
    expect(scale.name, "Eufy Smart Scale P1");
  });

  test('the [weight] is kg', () {
    expect(scale.unit, WeightUnit.kg);
  });

  test('[onData] returns null if has not 11 bytes', () {
    var weight = scale.onData(Uint8List.fromList(List.of([1, 2, 3, 4])));
    expect(weight, isNull);
  });

  test('[onData] returns 72.6 for 5C1C', () {
    var weight = scale.onData(Uint8List.fromList(
      List.of([0, 0, 0, 0x5C, 0x1C, 0, 0, 0, 0, 0, 0]),
    ));
    expect(weight!.weight, 72.6);
    expect(weight.unit, WeightUnit.kg);
  });
}
