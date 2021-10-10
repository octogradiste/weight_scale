import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/scales/climbro.dart';

class ClimbroRecognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.device.name.startsWith("Climbro_")) {
      return Climbro(bleDevice: scanResult.device);
    }
  }
}
