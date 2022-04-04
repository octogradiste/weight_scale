import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/src/ble/ble.dart';

/// The different states in which a [BleDevice] can be in.
///
/// Note: The state of a [BleDevice] is not guaranteed to transition via the
/// states [disconnecting] and [connecting].
enum BleDeviceState {
  connected,
  disconnected,
  connecting,
  disconnecting,
}

/// An abstract class which represent a ble device.
abstract class BleDevice {
  /// The name of the ble device.
  abstract final String name;

  /// The identifier for the ble device.
  ///
  /// On Android it's a MAC address such as '00:11:22:33:AA:BB' and on ios
  /// it's an 128 bit UUID such as '68753A44-4D6F-1226-9C60-0050E4C00067'.
  abstract final String id;

  /// Returns the services discoverd during service discovery.
  Future<List<Service>> get services;

  /// Returns a stream which emits every new ble state.
  Stream<BleDeviceState> get state;

  /// Returns the current state of this ble device.
  BleDeviceState get currentState;

  /// Connects to this ble device.
  ///
  /// Throws a [BleException] if the [timeout] is reached before a connection
  /// could be established.
  ///
  /// Throws a [BleException] if this device is currently connecting
  /// or is already connected.
  Future<void> connect({Duration timeout = const Duration(seconds: 20)});

  /// Disconnects from this ble device.
  ///
  /// Note: Won't have any effect if this device is already disconnected.
  Future<void> disconnect();

  /// Returns a list of the discoverd services on this ble device.
  Future<List<Service>> discoverServices();

  /// Returns the value of the [characteristic].
  Future<Uint8List> readCharacteristic(Characteristic characteristic);

  /// Writes to [characteristic] the [value] with or without a [response].
  Future<void> writeCharacteristic(
    Characteristic characteristic, {
    required Uint8List value,
    bool response = true,
  });

  /// Subscribes to [characteristic].
  ///
  /// Listen to the returned stream to get notified
  /// when the value of [characteristic] changes.
  ///
  /// When stopping listening to the stream the subscription to the
  /// [characteristic] ends.
  Future<Stream<Uint8List>> subscribeCharacteristic(
    Characteristic characteristic,
  );

  @override
  bool operator ==(other);

  @override
  int get hashCode;
}
