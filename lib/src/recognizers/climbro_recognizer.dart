import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/climbro.dart';

class ClimbroRecognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.deviceInformation.name.startsWith("Climbro_")) {
      return Climbro(
        device: blue.BluetoothDevice.fromId(scanResult.deviceInformation.id),
      );
    }
    return null;
  }
}
