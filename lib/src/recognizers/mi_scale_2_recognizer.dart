import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

class MiScale2Recognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.device.information.name == "MIBFS") {
      return MiScale2(device: scanResult.device);
    }
    return null;
  }
}
