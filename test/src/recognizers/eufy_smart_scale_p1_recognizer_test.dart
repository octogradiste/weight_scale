import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/recognizers/eufy_smart_scale_p1_recognizer.dart';
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';

import '../fake_ble_device.dart';

void main() {
  late WeightScaleRecognizer recognizer;

  setUp(() {
    recognizer = EufySmartScaleP1Recognizer();
  });

  test('[recognize] returns the scale for eufy T9147', () {
    BleDevice device = FakeBleDevice(id: "id", name: "eufy T9147");
    ScanResult scanResult = ScanResult(
      device: device,
      serviceData: const {},
      serviceUuids: const [],
      rssi: 0,
    );
    expect(
      recognizer.recognize(scanResult: scanResult),
      const TypeMatcher<EufySmartScaleP1>(),
    );
  });

  test('[recognize] returns null for eufy fake', () {
    BleDevice device = FakeBleDevice(id: "id", name: "eufy fake");
    ScanResult scanResult = ScanResult(
      device: device,
      serviceData: const {},
      serviceUuids: const [],
      rssi: 0,
    );
    expect(recognizer.recognize(scanResult: scanResult), isNull);
  });
}
