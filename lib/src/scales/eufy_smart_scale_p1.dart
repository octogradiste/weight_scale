import 'dart:typed_data';

import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/abstract_weight_scale.dart';

class EufySmartScaleP1 extends AbstractWeightScale {
  @override
  final serviceUuid = const Uuid("0000fff0-0000-1000-8000-00805f9b34fb");

  @override
  final characteristicUuid = const Uuid("0000fff4-0000-1000-8000-00805f9b34fb");

  EufySmartScaleP1({
    required super.device,
  });

  @override
  final String name = "Eufy Smart Scale P1";

  @override
  final String manufacturer = "Eufy by Anker";

  @override
  Weight? onData(Uint8List data) {
    ByteData bytes = ByteData.sublistView(data);
    if (bytes.lengthInBytes != 11) return null;
    return Weight(bytes.getUint16(3, Endian.little) / 100, WeightUnit.kg);
  }

  @override
  bool hasStabilized(Uint8List data) {
    ByteData bytes = ByteData.sublistView(data);
    if (bytes.lengthInBytes != 11) return false;
    return (bytes.getInt16(1) != 0 || bytes.getInt32(5) != 0);
  }
}
