import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/util/state_stream.dart';

enum BleDeviceState {
  connected,
  disconnected,
  connecting,
  disconnecting,
  discoveringServices,
  readingCharacteristic,
  writingCharacteristic,
  subscribingCharacteristic,
}

/// A ble device you can perform operations on.
///
/// All operations are guaranteed to be queued and run synchronously. This
/// results in a more sable way to communicate with the device.
class BleDevice {
  final StateStream<BleDeviceState> _state =
      StateStream(initValue: BleDeviceState.disconnected);
  late final BleOperations _operations;
  List<Service> _services = List.empty();

  final String id;
  final String name;

  BleDevice({
    required this.id,
    required this.name,
    required BleOperations operations,
  }) {
    _operations = operations;
  }

  Stream<BleDeviceState> get state => _state.events;
  BleDeviceState get currentState => _state.state;
  List<Service> get services => _services;

  @override
  bool operator ==(Object other) {
    return other is BleDevice && other.id == id && other.name == name;
  }

  @override
  int get hashCode => hashValues(id, name);

  /// Connects to this device.
  ///
  /// Throws a [TimeoutException] if it could not connect after [timeout].
  /// The default timeout is 15 secondes.
  Future<void> connect({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    _state.setState(BleDeviceState.connecting);
    bool connected = false;
    try {
      await _operations
          .connect(device: this, timeout: timeout)
          .timeout(timeout);
      connected = true;
    } finally {
      if (connected) {
        _state.setState(BleDeviceState.connected);
      } else {
        _state.setState(BleDeviceState.disconnected);
      }
    }
  }

  /// Disconnects from this device.
  Future<void> disconnect() async {
    _state.setState(BleDeviceState.disconnecting);
    try {
      await _operations.disconnect(device: this);
    } finally {
      _state.setState(BleDeviceState.disconnected);
    }
  }

  /// Returns a list of the discoverd services.
  ///
  /// If the method call completes successfully, the services can
  /// also be accessed by the getter [services].
  Future<List<Service>> discoverService() async {
    _state.setState(BleDeviceState.discoveringServices);
    try {
      _services = await _operations.discoverService(device: this);
    } finally {
      _state.setState(BleDeviceState.connected);
    }
    return _services;
  }

  /// Returns the value of the [characteristic].
  Future<Uint8List> readCharacteristic({
    required Characteristic characteristic,
  }) async {
    _state.setState(BleDeviceState.readingCharacteristic);
    late final Uint8List value;
    try {
      value =
          await _operations.readCharacteristic(characteristic: characteristic);
    } finally {
      _state.setState(BleDeviceState.connected);
    }
    return value;
  }

  /// Writes to [characteristic] the [value] with or without a [response].
  Future<void> writeCharacteristic({
    required Characteristic characteristic,
    required Uint8List value,
    bool response = true,
  }) async {
    _state.setState(BleDeviceState.writingCharacteristic);
    try {
      await _operations.writeCharacteristic(
        characteristic: characteristic,
        value: value,
        response: response,
      );
    } finally {
      _state.setState(BleDeviceState.connected);
    }
  }

  /// Subscribes to [characteristic].
  ///
  /// Listen to the returned stream to get notified
  /// when the value of [characteristic] changes.
  ///
  /// When closing the returned stream, the subscription
  /// to the characteristic ends.
  Future<Stream<Uint8List>> subscribeCharacteristic({
    required Characteristic characteristic,
  }) async {
    _state.setState(BleDeviceState.subscribingCharacteristic);
    late Stream<Uint8List> stream;
    try {
      stream = await _operations.subscribeCharacteristic(
          characteristic: characteristic);
    } finally {
      _state.setState(BleDeviceState.connected);
    }
    return stream;
  }
}
