import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/recognizers/eufy_smart_scale_p1_recognizer.dart';
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';

import '../ble_service_test.mocks.dart';

void main() {
  late WeightScaleRecognizer recognizer;
  late BleOperations operations;

  setUp(() {
    recognizer = EufySmartScaleP1Recognizer();
    operations = MockBleOperations();
  });

  test('[recognize] returns the scale for eufy T9147', () {
    BleDevice device =
        BleDevice(id: "id", name: "eufy T9147", operations: operations);
    ScanResult scanResult = ScanResult(
      device: device,
      manufacturerData: Uint8List(0),
      serviceData: {},
      serviceUuids: [],
      rssi: 0,
    );
    expect(recognizer.recognize(scanResult: scanResult),
        TypeMatcher<EufySmartScaleP1>());
  });

  test('[recognize] returns null for eufy fake', () {
    BleDevice device =
        BleDevice(id: "id", name: "eufy fake", operations: operations);
    ScanResult scanResult = ScanResult(
      device: device,
      manufacturerData: Uint8List(0),
      serviceData: {},
      serviceUuids: [],
      rssi: 0,
    );
    expect(recognizer.recognize(scanResult: scanResult), isNull);
  });
}
