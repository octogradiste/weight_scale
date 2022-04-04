import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/recognizers/climbro_recognizer.dart';

import '../fake_ble_device.dart';

void main() {
  late WeightScaleRecognizer recognizer;

  setUp(() {
    recognizer = ClimbroRecognizer();
  });

  test('[recognize] returns a weight scale.', () {
    BleDevice device = FakeBleDevice(id: "id", name: "Climbro_12345");
    ScanResult scanResult = ScanResult(
      device: device,
      serviceData: const {},
      serviceUuids: const [],
      rssi: 0,
    );
    WeightScale? scale = recognizer.recognize(scanResult: scanResult);
    expect(scale, isNotNull);
  });

  test('does not [recognize] returns null', () {
    BleDevice device = FakeBleDevice(id: "id", name: "not a climbro");
    ScanResult scanResult = ScanResult(
      device: device,
      serviceData: const {},
      serviceUuids: const [],
      rssi: 0,
    );
    WeightScale? scale = recognizer.recognize(scanResult: scanResult);
    expect(scale, isNull);
  });
}
