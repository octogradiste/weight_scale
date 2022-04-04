import 'dart:typed_data';

import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/simple_weight_scale.dart';

class EufySmartScaleP1 extends SimpleWeightScale {
  EufySmartScaleP1({
    required BleDevice bleDevice,
  }) : super(
          bleDevice: bleDevice,
          unit: WeightUnit.kg,
          serviceUuid: const Uuid("0000fff0-0000-1000-8000-00805f9b34fb"),
          characteristicUuid:
              const Uuid("0000fff4-0000-1000-8000-00805f9b34fb"),
        );

  @override
  String get name => "Eufy Smart Scale P1";

  @override
  Weight? Function(Uint8List data) get onData => (value) {
        ByteData data = ByteData.sublistView(value);
        if (data.lengthInBytes != 11) return null;
        return Weight(
          data.getUint16(3, Endian.little) / 100,
          WeightUnit.kg,
        );
      };
}
