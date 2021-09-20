import 'dart:typed_data';

import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/features.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/src/util/state_stream.dart';

/// Mi Body Composition Scale 2
class MiScale2 implements WeightScale, SetUnitFeature, ClearCacheFeature {
  final Uuid _bodyCompositionService =
      Uuid("0000181b-0000-1000-8000-00805f9b34fb");
  final Uuid _bodyCompositionMeasurement =
      Uuid("00002a9c-0000-1000-8000-00805f9b34fb");
  final Uuid _customService = Uuid("00001530-0000-3512-2118-0009af100700");
  final Uuid _scaleConfiguration = Uuid("00001542-0000-3512-2118-0009af100700");

  bool _isConnected = false;
  late WeightScaleUnit _unit;
  final StateStream<double> _weight = StateStream(initValue: 0.0);
  late final BleDevice _device;

  @override
  final String name = "Mi Body Composition Scale 2";
  @override
  late final weight = _weight.events;

  MiScale2({required BleDevice bleDevice, required WeightScaleUnit unit}) {
    _device = bleDevice;
    _unit = unit;
  }

  @override
  WeightScaleUnit get unit => _unit;

  @override
  double get currentWeight => _weight.state;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    await _device.connect(timeout: timeout);
    List<Service> services = await _device.discoverService();
    Characteristic characteristic = _findCharacteristic(services);
    Stream<Uint8List> values =
        await _device.subscribeCharacteristic(characteristic: characteristic);

    _isConnected = true;

    values.forEach((value) {
      ByteData data = ByteData.sublistView(value);
      if (data.lengthInBytes != 13) return;
      _unit = WeightScaleUnit.UNKNOWN;
      if (data.getUint8(0) % 2 == 1) {
        // If last bit of first byte is one then the weight is in LBS.
        _unit = WeightScaleUnit.LBS;
      } else if ((data.getUint8(1) >> 6) % 2 == 0) {
        // If second bit of second byte is one then the
        // weight is in Catty (aka UNKNOWN) else in KG.
        _unit = WeightScaleUnit.KG;
      }

      switch (_unit) {
        case WeightScaleUnit.KG:
          _weight.setState(data.getUint16(11, Endian.little) / 200);
          break;
        case WeightScaleUnit.LBS:
          _weight.setState(data.getUint16(11, Endian.little) / 100);
          break;
        case WeightScaleUnit.UNKNOWN:
          _weight.setState(0);
          break;
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    await _device.disconnect();
  }

  /// It finds the correct characteristic to subscribe to or
  /// throws an [WeightScaleConnectionException].
  Characteristic _findCharacteristic(List<Service> services) {
    services =
        services.where((e) => e.uuid == _bodyCompositionService).toList();
    if (services.length < 1)
      throw WeightScaleConnectionException("No matching ble service.");

    if (services.length > 1)
      throw WeightScaleConnectionException("Too many matching ble services.");

    List<Characteristic> characteristics = services.first.characteristics
        .where((characteristic) =>
            characteristic.uuid == _bodyCompositionMeasurement)
        .toList();

    if (characteristics.length < 1)
      throw WeightScaleConnectionException("No matching ble characteristic.");

    if (characteristics.length > 1)
      throw WeightScaleConnectionException(
          "Too many matching ble characteristics.");

    return characteristics.first;
  }

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
      await _device.writeCharacteristic(
        characteristic: Characteristic(
          deviceId: _device.id,
          serviceUuid: _customService,
          uuid: _scaleConfiguration,
        ),
        value: value,
        response: false,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    await _device.writeCharacteristic(
      characteristic: Characteristic(
        deviceId: _device.id,
        serviceUuid: _customService,
        uuid: _scaleConfiguration,
      ),
      value: Uint8List.fromList(const [6, 18, 0, 0]),
    );
  }
}
