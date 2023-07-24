import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/recognizers/eufy_smart_scale_p1_recognizer.dart';
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';

void main() {
  late WeightScaleRecognizer recognizer;

  group('recognize', () {
    setUp(() {
      recognizer = EufySmartScaleP1Recognizer();
    });

    test('Should recognize scale When the name is eufy T9147', () {
      const device = BleDeviceInformation(id: "id", name: "eufy T9147");
      const scanResult = ScanResult(
        deviceInformation: device,
        serviceData: {},
        serviceUuids: [],
        rssi: 0,
      );
      expect(
        recognizer.recognize(scanResult: scanResult),
        const TypeMatcher<EufySmartScaleP1>(),
      );
    });

    test('Should not recognize scale When the name is eufy fake', () {
      const device = BleDeviceInformation(id: "id", name: "eufy fake");
      const scanResult = ScanResult(
        deviceInformation: device,
        serviceData: {},
        serviceUuids: [],
        rssi: 0,
      );
      expect(recognizer.recognize(scanResult: scanResult), isNull);
    });
  });
}
