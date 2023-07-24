import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/recognizers/climbro_recognizer.dart';

void main() {
  late WeightScaleRecognizer recognizer;

  group('recognize', () {
    setUp(() {
      recognizer = ClimbroRecognizer();
    });

    test('Should recognize and return the weight scale', () {
      const device = BleDeviceInformation(id: "id", name: "Climbro_12345");
      const scanResult = ScanResult(
        deviceInformation: device,
        serviceData: {},
        serviceUuids: [],
        rssi: 0,
      );
      WeightScale? scale = recognizer.recognize(scanResult: scanResult);
      expect(scale, isNotNull);
    });

    test('Should not recognize and return null', () {
      const device = BleDeviceInformation(id: "id", name: "not a climbro");
      const scanResult = ScanResult(
        deviceInformation: device,
        serviceData: {},
        serviceUuids: [],
        rssi: 0,
      );
      WeightScale? scale = recognizer.recognize(scanResult: scanResult);
      expect(scale, isNull);
    });
  });
}
