import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/util/async_task_queue.dart';
import 'package:weight_scale/src/util/state_stream.dart';

/// The different states of the [BleDevice].
///
/// The states [discoveringServices], [readingCharacteristic],
/// [writingCharacteristic] and [subscribingCharacteristic] also mean that the
/// device is connected.
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
/// results in a more stable way to communicate with the ble device.
class BleDevice {
  final AsyncTaskQueue _queue = AsyncTaskQueue();
  final StateStream<BleDeviceState> _state =
      StateStream(initValue: BleDeviceState.disconnected);
  late final BleOperations _operations;
  List<Service> _services = List.empty();

  bool _addedCallback = false;

  final String id;
  final String name;

  BleDevice({
    required this.id,
    required this.name,
    required BleOperations operations,
  }) : _operations = operations;

  /// This stream emits the state of this device.
  ///
  /// Note: It's possible that the [state] skips [BleDeviceState.disconnecting]
  /// and goes directly to [BleDeviceState.disconnected].
  Stream<BleDeviceState> get state => _state.events;
  BleDeviceState get currentState => _state.state;

  /// A list of the discovered services.
  ///
  /// Unless you [discoverService] this list will be empty.
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

    if (!_addedCallback) {
      _operations.addDisconnectCallback(
        device: this,
        callback: () async => _state.setState(BleDeviceState.disconnected),
      );
      _addedCallback = true;
    }

    bool connected = false;
    try {
      await _queue.add(() async {
        await _operations
            .connect(device: this, timeout: timeout)
            .timeout(timeout);
      });
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
      await _queue.add(() async {
        await _operations.disconnect(device: this);
      });
    } finally {
      _state.setState(BleDeviceState.disconnected);
    }
  }

  /// Returns a list of the discovered services.
  ///
  /// If the method call completes successfully, the services can
  /// also be accessed by the getter [services].
  Future<List<Service>> discoverService() async {
    _state.setState(BleDeviceState.discoveringServices);
    try {
      _services = await _queue.add<List<Service>>(
          () async => await _operations.discoverService(device: this));
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
      value = await _queue.add<Uint8List>(() async =>
          await _operations.readCharacteristic(characteristic: characteristic));
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
      await _queue.add(() async {
        await _operations.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: response,
        );
      });
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
      stream = await _queue.add<Stream<Uint8List>>(() async => await _operations
          .subscribeCharacteristic(characteristic: characteristic));
    } finally {
      _state.setState(BleDeviceState.connected);
    }
    return stream;
  }
}
