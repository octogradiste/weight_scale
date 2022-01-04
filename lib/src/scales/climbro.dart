import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/util/state_stream.dart';

class Climbro implements WeightScale {
  late final BleDevice _device;

  bool _connected = false;

  final StateStream<double> _weight = StateStream(initValue: 0.0);

  final Uuid _service = Uuid("49535343-fe7d-4ae5-8fa9-9fafd205e455");
  final Uuid _characteristic = Uuid("49535343-1e4d-4bd9-ba61-23c647249616");

  Climbro({required BleDevice bleDevice}) {
    _device = bleDevice;
  }

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

    values.forEach((element) {
      if (element.length == 1) {
        _weight.setState(element.first.toDouble());
      }
    });

    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    try {
      _device.disconnect();
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    } finally {
      _connected = false;
    }
  }

  @override
  double get currentWeight => _weight.state;

  @override
  bool get isConnected => _connected;

  @override
  String get name => "Climbro";

  @override
  WeightScaleUnit get unit => WeightScaleUnit.KG;

  @override
  Stream<double> get weight => _weight.events;

  @override
  Stream<BleDeviceState> get state => _device.state;

  /// It finds the correct characteristic to subscribe to or
  /// throws an [WeightScaleException].
  Characteristic _characteristicToSubscribe(List<Service> services) {
    services = services.where((e) => e.uuid == _service).toList();
    if (services.length < 1)
      throw WeightScaleException("No matching ble service.");

    if (services.length > 1)
      throw WeightScaleException("Too many matching ble services.");

    List<Characteristic> characteristics = services.first.characteristics
        .where((characteristic) => characteristic.uuid == _characteristic)
        .toList();

    if (characteristics.length < 1)
      throw WeightScaleException("No matching ble characteristic.");

    if (characteristics.length > 1)
      throw WeightScaleException("Too many matching ble characteristics.");

    return characteristics.first;
  }
}
