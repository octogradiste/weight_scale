import 'dart:typed_data';

import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

class MiScale2Recognizer implements WeightScaleRecognizer {
  @override
  WeightScale? recognize({required ScanResult scanResult}) {
    if (scanResult.device.information.name == "MIBFS") {
      ByteData data = ByteData.sublistView(scanResult.serviceData.values.first);
      WeightUnit unit = WeightUnit.unknown;
      if (data.getUint8(0) % 2 == 1) {
        // If last bit of first byte is one then the weight is in LBS.
        unit = WeightUnit.lbs;
      } else if ((data.getUint8(1) >> 6) % 2 == 0) {
        // If second bit of second byte is one then the
        // weight is in Catty (aka UNKNOWN) else in KG.
        unit = WeightUnit.kg;
      }

      return MiScale2(bleDevice: scanResult.device, unit: unit);
    }
    return null;
  }
}
