import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/util/state_stream.dart';

abstract class SimpleWeightScale implements WeightScale {
  final Uuid serviceUuid;
  final Uuid characteristicUuid;

  final BleDevice _device;
  final StateStream<double> _weight = StateStream(initValue: 0.0);

  bool _isConnected = false;
  WeightUnit _unit;
  StreamSubscription<Uint8List>? _sub;

  abstract final Weight? Function(Uint8List) onData;

  @override
  late final weight = _weight.events;

  SimpleWeightScale({
    required BleDevice bleDevice,
    required WeightUnit unit,
    required this.serviceUuid,
    required this.characteristicUuid,
  })  : _device = bleDevice,
        _unit = unit;

  @override
  WeightUnit get unit => _unit;

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
      List<Service> services = await _device.discoverServices();
      Characteristic sub = _characteristicToSubscribe(services);
      values = await _device.subscribeCharacteristic(sub);
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }

    _sub = values.listen((data) {
      Weight? weight = onData(data);
      if (weight != null) {
        _weight.setState(weight.weight);
        _unit = weight.unit;
      }
    });

    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    try {
      await _sub?.cancel();
      await _device.disconnect();
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    } finally {
      _isConnected = false;
    }
  }

  /// It finds the correct characteristic to subscribe to or
  /// throws an [WeightScaleException].
  Characteristic _characteristicToSubscribe(List<Service> services) {
    services = services.where((e) => e.uuid == serviceUuid).toList();
    if (services.isEmpty) {
      throw const WeightScaleException("No matching ble service.");
    }

    if (services.length > 1) {
      throw const WeightScaleException("Too many matching ble services.");
    }

    List<Characteristic> characteristics = services.first.characteristics
        .where((characteristic) => characteristic.uuid == characteristicUuid)
        .toList();

    if (characteristics.isEmpty) {
      throw const WeightScaleException("No matching ble characteristic.");
    }

    if (characteristics.length > 1) {
      throw const WeightScaleException(
          "Too many matching ble characteristics.");
    }

    return characteristics.first;
  }
}
