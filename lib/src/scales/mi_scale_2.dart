import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/simple_weight_scale.dart';

/// Mi Body Composition Scale 2
class MiScale2 extends SimpleWeightScale
    implements SetUnitFeature, ClearCacheFeature {
  final Uuid _customService = Uuid("00001530-0000-3512-2118-0009af100700");
  final Uuid _scaleConfiguration = Uuid("00001542-0000-3512-2118-0009af100700");
  final BleDevice _device;

  MiScale2({required BleDevice bleDevice, required WeightScaleUnit unit})
      : _device = bleDevice,
        super(
          bleDevice: bleDevice,
          unit: unit,
          characteristicUuid: Uuid("00002a9c-0000-1000-8000-00805f9b34fb"),
          serviceUuid: Uuid("0000181b-0000-1000-8000-00805f9b34fb"),
        );

  @override
  final String name = "Mi Body Composition Scale 2";

  @override
  final Weight? Function(Uint8List) onData = (value) {
    late WeightScaleUnit unit;
    ByteData data = ByteData.sublistView(value);
    if (data.lengthInBytes != 13) return null;
    unit = WeightScaleUnit.UNKNOWN;
    if (data.getUint8(0) % 2 == 1) {
      // If last bit of first byte is one then the weight is in LBS.
      unit = WeightScaleUnit.LBS;
    } else if ((data.getUint8(1) >> 6) % 2 == 0) {
      // If second bit of second byte is one then the
      // weight is in Catty (aka UNKNOWN) else in KG.
      unit = WeightScaleUnit.KG;
    }

    switch (unit) {
      case WeightScaleUnit.KG:
        return Weight(data.getUint16(11, Endian.little) / 200, unit);
      case WeightScaleUnit.LBS:
        return Weight(data.getUint16(11, Endian.little) / 100, unit);
      case WeightScaleUnit.UNKNOWN:
        return Weight(0, unit);
    }
  };

  @override
  Future<void> setUnit(WeightScaleUnit unit) async {
    Uint8List? value;
    switch (unit) {
      case WeightScaleUnit.KG:
        value = Uint8List.fromList([6, 4, 0, 0]);
        break;
      case WeightScaleUnit.LBS:
        value = Uint8List.fromList([6, 4, 0, 1]);
        break;
      case WeightScaleUnit.UNKNOWN:
        value = null;
        break;
    }

    if (value != null) {
      try {
        await _device.writeCharacteristic(
          characteristic: Characteristic(
            deviceId: _device.id,
            serviceUuid: _customService,
            uuid: _scaleConfiguration,
          ),
          value: value,
          response: false,
        );
      } on BleOperationException catch (e) {
        throw WeightScaleException(e.message);
      }
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _device.writeCharacteristic(
        characteristic: Characteristic(
          deviceId: _device.id,
          serviceUuid: _customService,
          uuid: _scaleConfiguration,
        ),
        value: Uint8List.fromList(const [6, 18, 0, 0]),
      );
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    }
  }
}
