import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/eufy_smart_scale_p1.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_recognizer.dart';

class EufySmartScaleP1Recognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.device.name.startsWith("eufy T")) {
      return EufySmartScaleP1(bleDevice: scanResult.device);
    }
    return null;
  }
}
