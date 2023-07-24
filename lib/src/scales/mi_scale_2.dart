import 'dart:typed_data';

import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/abstract_weight_scale.dart';

/// Mi Body Composition Scale 2
class MiScale2 extends AbstractWeightScale {
  MiScale2({required super.device});

  @override
  final characteristicUuid = const Uuid("00002a9c-0000-1000-8000-00805f9b34fb");

  @override
  final serviceUuid = const Uuid("0000181b-0000-1000-8000-00805f9b34fb");

  @override
  final name = "Mi Body Composition Scale 2";

  @override
  final manufacturer = "Xiaomi";

  @override
  Weight? onData(Uint8List data) {
    ByteData bytes = ByteData.sublistView(data);
    if (bytes.lengthInBytes != 13) return null;

    if (bytes.getInt8(0) & 1 != 0) {
      // Weight is in lbs.
      return Weight(bytes.getUint16(11, Endian.little) / 100, WeightUnit.lbs);
    } else if (bytes.getInt8(1) & 0x40 != 0) {
      // Weight is in catty.
      return null;
    } else {
      // Weight is in kg.
      return Weight(bytes.getUint16(11, Endian.little) / 200, WeightUnit.kg);
    }
  }

  @override
  bool hasStabilized(Uint8List data) {
    ByteData bytes = ByteData.sublistView(data);
    if (bytes.lengthInBytes != 13) return false;
    return bytes.getInt8(1) & 0x20 != 0;
  }
}
