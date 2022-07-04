import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/climbro.dart';

class ClimbroRecognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.device.information.name.startsWith("Climbro_")) {
      return Climbro(device: scanResult.device);
    }
    return null;
  }
}
