import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/abstract_weight_scale.dart';

/// Mi Body Composition Scale 2
class MiScale2 extends AbstractWeightScale
    implements SetUnitFeature, ClearCacheFeature {
  final Characteristic _configCharacteristic;
  final BleDevice _device;

  MiScale2({required super.device})
      : _device = device,
        _configCharacteristic = Characteristic(
          deviceId: device.information.id,
          serviceUuid: const Uuid("00001530-0000-3512-2118-0009af100700"),
          uuid: const Uuid("00001542-0000-3512-2118-0009af100700"),
        );

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
    late WeightUnit unit;
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

  @override
  Future<void> setUnit(WeightUnit unit) async {
    Uint8List value;
    switch (unit) {
      case WeightUnit.kg:
        value = Uint8List.fromList([6, 4, 0, 0]);
        break;
      case WeightUnit.lbs:
        value = Uint8List.fromList([6, 4, 0, 1]);
        break;
      case WeightUnit.unknown:
        return;
    }

    try {
      await _device.writeCharacteristic(
        _configCharacteristic,
        value: value,
        response: false,
      );
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _device.writeCharacteristic(
        _configCharacteristic,
        value: Uint8List.fromList(const [6, 18, 0, 0]),
      );
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }
  }
}
