import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

class MiScale2Recognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.deviceInformation.name == "MIBFS") {
      return MiScale2(
        device: blue.BluetoothDevice.fromId(scanResult.deviceInformation.id),
      );
    }
    return null;
  }
}
