import 'dart:typed_data';

import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/simple_weight_scale.dart';

class Climbro extends SimpleWeightScale {
  Climbro({required BleDevice bleDevice})
      : super(
          bleDevice: bleDevice,
          unit: WeightScaleUnit.KG,
          serviceUuid: const Uuid("49535343-fe7d-4ae5-8fa9-9fafd205e455"),
          characteristicUuid:
              const Uuid("49535343-1e4d-4bd9-ba61-23c647249616"),
        );

  @override
  String get name => "Climbro";

  @override
  Weight? Function(Uint8List) get onData => _onData;

  Weight? _onData(Uint8List data) {
    if (data.length == 1) {
      return Weight(data.first.toDouble(), WeightScaleUnit.KG);
    }
    return null;
  }
}
