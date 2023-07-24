import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';
import 'package:weight_scale/weight_scale.dart';

class EufySmartScaleP1Recognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.deviceInformation.name.startsWith("eufy T")) {
      return EufySmartScaleP1(
          device: blue.BluetoothDevice.fromId(scanResult.deviceInformation.id));
    }
    return null;
  }
}
