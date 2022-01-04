import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/util/state_stream.dart';

/// Mi Body Composition Scale 2
class MiScale2 implements WeightScale, SetUnitFeature, ClearCacheFeature {
  final Uuid _bcService = Uuid("0000181b-0000-1000-8000-00805f9b34fb");
  final Uuid _bcMeasurement = Uuid("00002a9c-0000-1000-8000-00805f9b34fb");
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
  Stream<BleDeviceState> get state => _device.state;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    late Stream<Uint8List> values;

    try {
      await _device.connect(timeout: timeout);
      List<Service> services = await _device.discoverService();
      Characteristic sub = _characteristicToSubscribe(services);
      values = await _device.subscribeCharacteristic(characteristic: sub);
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    } on TimeoutException {
      throw WeightScaleException("Couldn't connect in time.");
    }

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

    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    try {
      await _device.disconnect();
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    }
    _isConnected = false;
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

  /// It finds the correct characteristic to subscribe to or
  /// throws an [WeightScaleException].
  Characteristic _characteristicToSubscribe(List<Service> services) {
    services = services.where((e) => e.uuid == _bcService).toList();
    if (services.length < 1)
      throw WeightScaleException("No matching ble service.");

    if (services.length > 1)
      throw WeightScaleException("Too many matching ble services.");

    List<Characteristic> characteristics = services.first.characteristics
        .where((characteristic) => characteristic.uuid == _bcMeasurement)
        .toList();

    if (characteristics.length < 1)
      throw WeightScaleException("No matching ble characteristic.");

    if (characteristics.length > 1)
      throw WeightScaleException("Too many matching ble characteristics.");

    return characteristics.first;
  }
}
