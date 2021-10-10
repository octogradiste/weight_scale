import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/recognizers/climbro_recognizer.dart';

import '../ble_service_test.mocks.dart';

void main() {
  late WeightScaleRecognizer recognizer;
  late BleOperations operations;

  setUp(() {
    recognizer = ClimbroRecognizer();
    operations = MockBleOperations();
  });

  test('[recognize] returns a weight scale.', () {
    BleDevice device =
        BleDevice(id: "id", name: "Climbro_12345", operations: operations);
    ScanResult scanResult = ScanResult(
      device: device,
      manufacturerData: Uint8List(0),
      serviceData: {},
      serviceUuids: [],
      rssi: 0,
    );
    WeightScale? scale = recognizer.recognize(scanResult: scanResult);
    expect(scale, isNotNull);
  });

  test('does not [recognize] returns null', () {
    BleDevice device =
        BleDevice(id: "id", name: "name", operations: operations);
    ScanResult scanResult = ScanResult(
      device: device,
      manufacturerData: Uint8List(0),
      serviceData: {},
      serviceUuids: [],
      rssi: 0,
    );
    WeightScale? scale = recognizer.recognize(scanResult: scanResult);
    expect(scale, isNull);
  });
}
