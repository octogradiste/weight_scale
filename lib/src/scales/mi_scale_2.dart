import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/simple_weight_scale.dart';

/// Mi Body Composition Scale 2
class MiScale2 extends SimpleWeightScale
    implements SetUnitFeature, ClearCacheFeature {
  final Uuid _customService =
      const Uuid("00001530-0000-3512-2118-0009af100700");
  final Uuid _scaleConfiguration =
      const Uuid("00001542-0000-3512-2118-0009af100700");
  final BleDevice _device;

  MiScale2({required BleDevice bleDevice, required WeightUnit unit})
      : _device = bleDevice,
        super(
          bleDevice: bleDevice,
          unit: unit,
          characteristicUuid:
              const Uuid("00002a9c-0000-1000-8000-00805f9b34fb"),
          serviceUuid: const Uuid("0000181b-0000-1000-8000-00805f9b34fb"),
        );

  @override
  final String name = "Mi Body Composition Scale 2";

  @override
  Weight? Function(Uint8List) get onData => _onData;

  Weight? _onData(Uint8List value) {
    late WeightUnit unit;
    ByteData data = ByteData.sublistView(value);
    if (data.lengthInBytes != 13) return null;
    unit = WeightUnit.unknown;
    if (data.getUint8(0) % 2 == 1) {
      // If last bit of first byte is one then the weight is in LBS.
      unit = WeightUnit.lbs;
    } else if ((data.getUint8(1) >> 6) % 2 == 0) {
      // If second bit of second byte is one then the
      // weight is in Catty (aka UNKNOWN) else in KG.
      unit = WeightUnit.kg;
    }

    switch (unit) {
      case WeightUnit.kg:
        return Weight(data.getUint16(11, Endian.little) / 200, unit);
      case WeightUnit.lbs:
        return Weight(data.getUint16(11, Endian.little) / 100, unit);
      case WeightUnit.unknown:
        return Weight(0, unit);
    }
  }

  @override
  Future<void> setUnit(WeightUnit unit) async {
    Uint8List? value;
    switch (unit) {
      case WeightUnit.kg:
        value = Uint8List.fromList([6, 4, 0, 0]);
        break;
      case WeightUnit.lbs:
        value = Uint8List.fromList([6, 4, 0, 1]);
        break;
      case WeightUnit.unknown:
        value = null;
        break;
    }

    if (value != null) {
      try {
        await _device.writeCharacteristic(
          Characteristic(
            deviceId: _device.information.id,
            serviceUuid: _customService,
            uuid: _scaleConfiguration,
          ),
          value: value,
          response: false,
        );
      } on BleException catch (e) {
        throw WeightScaleException(e.message);
      }
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _device.writeCharacteristic(
        Characteristic(
          deviceId: _device.information.id,
          serviceUuid: _customService,
          uuid: _scaleConfiguration,
        ),
        value: Uint8List.fromList(const [6, 18, 0, 0]),
      );
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }
  }
}
