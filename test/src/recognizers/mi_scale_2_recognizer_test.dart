import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';

import '../ble_service_test.mocks.dart';

void main() {
  group('recognize', () {
    late WeightScaleRecognizer recognizer;
    late BleOperations operations;

    setUp(() {
      recognizer = MiScale2Recognizer();
      operations = MockBleOperations();
    });

    test('[recognize] returns a weight scale.', () {
      BleDevice device = BleDevice(
        id: "00:00:00:00:00:00",
        name: "MIBFS",
        operations: operations,
      );
      ScanResult scanResult = ScanResult(
        device: device,
        manufacturerData: Uint8List(0),
        serviceData: {
          Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13)
        },
        serviceUuids: [],
        rssi: 0,
      );
      WeightScale? scale = recognizer.recognize(scanResult: scanResult);
      expect(scale, isNotNull);
      // The Unit is KG because the service data (same format as the
      // advertisement data) is only zeros.
      expect(scale?.unit, WeightScaleUnit.KG);
    });

    test('does not [recognize] returns null', () {
      BleDevice device = BleDevice(
        id: "00:00:00:00:00:00",
        name: "not MIBCS",
        operations: operations,
      );
      ScanResult scanResult = ScanResult(
        device: device,
        manufacturerData: Uint8List(0),
        serviceData: {
          Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13)
        },
        serviceUuids: [],
        rssi: 0,
      );
      WeightScale? scale = recognizer.recognize(scanResult: scanResult);
      expect(scale, isNull);
    });
  });
}
