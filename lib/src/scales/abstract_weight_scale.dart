import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/src/ble/backend/flutter_blue_plus_converter.dart';
import 'package:weight_scale/weight_scale.dart';

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
  final blue.BluetoothDevice _device;
  final _controller = StreamController<Weight>.broadcast();

  // Assigned when connecting to the device and called during disconnect.
  // Performs cleanup (cancel subscription and disable notification).
  Future<void> Function() _onDisconnect = () => Future.value();

  // If not null, this should complete when the weight has stabilized.
  // This will be reset to null once the weight has stabilized.
  Completer<Weight>? _measuring;

  Weight _currentWeight = const Weight(0, WeightUnit.kg);

  /// The uuid of the service holding the characteristic.
  abstract final Uuid serviceUuid;

  /// The uuid of the characteristic holding the weight data.
  abstract final Uuid characteristicUuid;

  /// Needs the underlying ble [device] as well as the uuid of the service and
  /// characteristic holding the weight data.
  AbstractWeightScale({
    required blue.BluetoothDevice device,
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
  BleDeviceInformation get information =>
      BleDeviceInformation(name: _device.localName, id: _device.remoteId.str);

  @override
  Stream<Weight> get weight => _controller.stream;

  @override
  Weight get currentWeight => _currentWeight;

  @override
  Future<bool> get isConnected async =>
      await currentState == BleDeviceState.connected;

  @override
  Future<BleDeviceState> get currentState => _device.connectionState
      .map(FlutterBluePlusConverter.toBleDeviceState)
      .first;

  @override
  Stream<bool> get connected => _device.connectionState
      .map((state) => state == blue.BluetoothConnectionState.connected);

  @override
  Future<Weight> takeWeightMeasurement() async {
    // If no measurement is currently being done, create a new completer.
    // Else we can just return the future of the ongoing measurement.
    _measuring ??= Completer();
    return _measuring!.future;
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    // Connect to device if not already connected.
    if (await currentState != BleDeviceState.connected) {
      try {
        await _device.connect(timeout: timeout);
      } catch (_) {
        throw const WeightScaleException("Could not connect to device.");
      }
    } else {
      _onDisconnect();
    }
    // Ensure connected state has been emitted.
    // Discover services.
    final List<blue.BluetoothService> services;
    try {
      services = await _device.discoverServices();
    } catch (_) {
      throw const WeightScaleException("Could not discover services.");
    }

    // Find correct service.
    final blue.BluetoothService service;
    try {
      service = services.firstWhere(
        (s) => s.serviceUuid == blue.Guid(serviceUuid.uuid),
      );
    } on StateError catch (_) {
      throw const WeightScaleException("Could not find service.");
    }

    // Find correct characteristic.
    final blue.BluetoothCharacteristic characteristic;
    try {
      characteristic = service.characteristics.firstWhere(
        (c) => c.characteristicUuid == blue.Guid(characteristicUuid.uuid),
      );
    } on StateError catch (_) {
      throw const WeightScaleException("Could not find characteristic.");
    }

    // Subscribe to characteristic.
    var success = false;
    try {
      success = await characteristic.setNotifyValue(true);
    } catch (_) {
      success = false;
    }

    if (!success) {
      throw const WeightScaleException("Could not enable notification.");
    }

    // Listen to stream and convert data to weight.
    // If [hasStabilized] is true, complete the [measuring] completer.
    final subscription = characteristic.lastValueStream.listen(
      (dataInt) {
        final data = Uint8List.fromList(dataInt); // TODO: Change onData to int
        final weight = onData(data);
        if (weight != null) {
          _currentWeight = weight;
          _controller.add(weight);
          if (_measuring != null && hasStabilized(data)) {
            _measuring!.complete(weight);
            _measuring = null;
          }
        }
      },
    );

    _onDisconnect = () async {
      await subscription.cancel();
      await characteristic.setNotifyValue(false);
    };
  }

  @override
  Future<void> disconnect() async {
    // Perform cleanup.
    await _onDisconnect();

    // Disconnect from device.
    try {
      await _device.disconnect();
    } catch (_) {
      throw const WeightScaleException("Could not disconnect from device.");
    }
  }
}
