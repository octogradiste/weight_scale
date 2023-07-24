import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/recognizers/climbro_recognizer.dart';

import '../fake_ble_device.dart';

void main() {
  late WeightScaleRecognizer recognizer;

  group('recognize', () {
    setUp(() {
      recognizer = ClimbroRecognizer();
    });

    test('Should recognize and return the weight scale', () {
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

    test('Should not recognize and return null', () {
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
  });
}
