import 'dart:typed_data';

import 'package:weight_scale/src/scales/mi_scale_2.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/weight_scale_recognizer.dart';

class MiScale2Recognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.device.name == "MIBFS") {
      ByteData data = ByteData.sublistView(scanResult.serviceData.values.first);
      WeightScaleUnit unit = WeightScaleUnit.UNKNOWN;
      if (data.getUint8(0) % 2 == 1) {
        // If last bit of first byte is one then the weight is in LBS.
        unit = WeightScaleUnit.LBS;
      } else if ((data.getUint8(1) >> 6) % 2 == 0) {
        // If second bit of second byte is one then the
        // weight is in Catty (aka UNKNOWN) else in KG.
        unit = WeightScaleUnit.KG;
      }

      return MiScale2(bleDevice: scanResult.device, unit: unit);
    }
  }
}
