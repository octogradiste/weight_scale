import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';

/// A class implementing most of the [WeightScale] interface.
///
/// To achieve this it needs to know the uuid of the service and characteristic
/// holding the weight data.
/// After setting up the notification on this characteristic, on every value
/// change the [onData] method will be called to transform the data to an
/// actual weight value. The same data will be send to the [hasStabilized]
/// method to determine if [takeWeightMeasurement] has terminated.
abstract class AbstractWeightScale implements WeightScale {
  final BleDevice _device;
  final _controller = StreamController<Weight>.broadcast();

  // If not null, this is the subscription to the characteristic emitting
  // weight data.
  StreamSubscription? _subscription;

  // If not null, this should complete when the weight has stabilized.
  Completer<Weight>? measuring;

  Weight _currentWeight = const Weight(0, WeightUnit.unknown);

  /// The uuid of the service holding the characteristic.
  final Uuid serviceUuid;

  /// The uuid of the characteristic holding the weight data.
  final Uuid characteristicUuid;

  /// Needs the underlying ble device as well as the uuid of the service and
  /// characteristic holding the weight data.
  AbstractWeightScale({
    required BleDevice device,
    required this.serviceUuid,
    required this.characteristicUuid,
  }) : _device = device;

  /// This should transform the data received by the scale to a
  /// weight measurement. If the data isn't a valid weight measurement, this
  /// should return null. In this case this null measurement won't be emitted
  /// by the [weight] stream and won't be the [currentWeight].
  Weight? onData(Uint8List data);

  /// This should return true if the weight measured by the scale has
  /// stabilized. Often the data send by the weight scale has a flag which is
  /// on when this is the case.
  bool hasStabilized(Uint8List data);

  @override
  BleDeviceInformation get information => _device.information;

  @override
  Stream<Weight> get weight => _controller.stream;

  @override
  Weight get currentWeight => _currentWeight;

  @override
  bool get isConnected => _device.currentState == BleDeviceState.connected;

  @override
  Stream<BleDeviceState> get state => _device.state;

  @override
  Future<Weight> takeWeightMeasurement() async {
    measuring ??= Completer();
    return measuring!.future;
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    if (_device.currentState == BleDeviceState.connecting ||
        _device.currentState == BleDeviceState.connected) {
      throw const WeightScaleException('Is already connected to the device!');
    }

    final List<Service> services;
    try {
      await _device.connect(timeout: timeout);
      services = await _device.discoverServices();
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }

    final Service service;
    try {
      service = services.where((s) => s.uuid == serviceUuid).first;
    } on StateError {
      throw const WeightScaleException('The service was not discovered.');
    }

    final Characteristic characteristic;
    try {
      characteristic = service.characteristics
          .where((c) => c.uuid == characteristicUuid)
          .first;
    } on StateError {
      throw const WeightScaleException(
        'The characteristic was not discovered.',
      );
    }

    try {
      final stream = await _device.subscribeCharacteristic(characteristic);
      _subscription = stream.listen((data) {
        final weight = onData(data);
        if (weight != null) {
          _currentWeight = weight;
          _controller.add(weight);
          if (hasStabilized(data) && measuring != null) {
            measuring!.complete(weight);
            measuring = null;
          }
        }
      });
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _device.disconnect();
  }
}
