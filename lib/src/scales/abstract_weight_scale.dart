import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/scale.dart';

/// A class implementing most of the [WeightScale] interface.
///
/// To achieve this, it needs to know the uuid of the service and the uuid of
/// the characteristic which contains the weight data.
/// When you connect to the scale, it will automatically set up the notification
/// on this characteristic. The received data is then passed to the [onData]
/// method which must transform the raw data to a [Weight] object. If [onData]
/// returns null the measurement is ignored.
/// The [hasStabilized] method is used to determine if the received weight
/// can be counted as a valid measurement which is then returned by the
/// [takeWeightMeasurement] method.
abstract class AbstractWeightScale implements WeightScale {
  final BleDevice _device;
  final _controller = StreamController<Weight>.broadcast();

  // If not null, this is the subscription to the characteristic emitting the
  // weight data.
  StreamSubscription? _subscription;

  // If not null, this should complete when the weight has stabilized.
  // This will be reset to null once the weight has stabilized.
  Completer<Weight>? measuring;

  Weight _currentWeight = const Weight(0, WeightUnit.kg);

  /// The uuid of the service holding the characteristic.
  abstract final Uuid serviceUuid;

  /// The uuid of the characteristic holding the weight data.
  abstract final Uuid characteristicUuid;

  /// Needs the underlying ble [device] as well as the uuid of the service and
  /// characteristic holding the weight data.
  AbstractWeightScale({
    required BleDevice device,
  }) : _device = device;

  /// This should transform the data received by the scale to a
  /// weight measurement. If the data isn't a valid weight measurement, this
  /// should return null. In this case, the null measurement won't be emitted
  /// by the [weight] stream and won't be the [currentWeight].
  Weight? onData(Uint8List data);

  /// This should return true if the weight measured by the scale has
  /// stabilized.
  ///
  /// Often this is indicated by a flag in the received data. If this is not
  /// the case you can also implement this feature in software
  /// (see [WeightScaleSoftwareStabilizer]).
  bool hasStabilized(Uint8List data);

  @override
  BleDeviceInformation get information => _device.information;

  @override
  Stream<Weight> get weight => _controller.stream;

  @override
  Weight get currentWeight => _currentWeight;

  @override
  Future<bool> get isConnected async =>
      await _device.currentState == BleDeviceState.connected;

  @override
  Future<BleDeviceState> get currentState => _device.currentState;

  @override
  Stream<BleDeviceState> get state => _device.state;

  @override
  Future<Weight> takeWeightMeasurement() async {
    // If no measurement is currently being done, create a new completer.
    // Else we can just return the future of the ongoing measurement.
    measuring ??= Completer();
    return measuring!.future;
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    final List<Service> services;
    try {
      if (await _device.currentState != BleDeviceState.connected) {
        await _device.connect(timeout: timeout);
      }
      services = await _device.discoverServices();
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }

    final Service service;
    try {
      // Finds the correct service.
      service = services.where((s) => s.uuid == serviceUuid).first;
    } on StateError {
      throw const WeightScaleException('The service was not discovered.');
    }

    final Characteristic characteristic;
    try {
      // Finds the correct characteristic.
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
          if (measuring != null && hasStabilized(data)) {
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
