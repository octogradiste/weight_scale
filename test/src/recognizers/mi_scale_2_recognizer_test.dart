import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';

import '../fake_ble_device.dart';

void main() {
  group('recognize', () {
    late WeightScaleRecognizer recognizer;

    setUp(() {
      recognizer = MiScale2Recognizer();
    });

    test('[recognize] returns a weight scale.', () {
      BleDevice device = FakeBleDevice(id: "id", name: "MIBFS");
      ScanResult scanResult = ScanResult(
        device: device,
        serviceData: {
          const Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13)
        },
        serviceUuids: const [],
        rssi: 0,
      );
      WeightScale? scale = recognizer.recognize(scanResult: scanResult);
      expect(scale, isNotNull);
      // The Unit is KG because the service data (same format as the
      // advertisement data) is only zeros.
      expect(scale?.unit, WeightScaleUnit.KG);
    });

    test('does not [recognize] returns null', () {
      BleDevice device = FakeBleDevice(id: "id", name: "not MIBFS");
      ScanResult scanResult = ScanResult(
        device: device,
        serviceData: {
          const Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13)
        },
        serviceUuids: const [],
        rssi: 0,
      );
      WeightScale? scale = recognizer.recognize(scanResult: scanResult);
      expect(scale, isNull);
    });
  });
}
