import 'dart:async';
import 'dart:typed_data';

import 'package:weight_scale/src/ble/ble.dart';

/// The different states in which a [BleDevice] can be in.
enum BleDeviceState {
  connected,
  disconnected,
  connecting,
  disconnecting,
}

/// A bluetooth low energy device to which you can [connect] to and then
/// perform some read/write operations on its characteristics.
///
/// Typically you would start by connecting to the [BleDevice].
/// Then you probably need to discover the services on this device by calling
/// the [discoverServices] method. This will return the discoverd services
/// as a future. Once discoverd the services are also available via the
/// [services] getter and don't need to be rediscovered.
/// From those discoverd services, you might find a [Service] containing the
/// [Characteristic] you're after and write to it with [writeCharacteristic].
/// You can also [readCharacteristic] or subscribe to changes by calling
/// [subscribeCharacteristic].
abstract class BleDevice {
  /// Information about this ble device.
  abstract final BleDeviceInformation information;

  /// Returns the services discoverd during service discovery.
  Future<List<Service>> get services;

  /// Returns stream which emits a boolean value whenever the connection
  /// changes from connected to disconnected or vice versa.
  Stream<bool> get connected;

  /// Returns the current state of this ble device.
  Future<BleDeviceState> get currentState;

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

  /// Writes to the [characteristic] the [value] with or without a [response].
  Future<void> writeCharacteristic(
    Characteristic characteristic, {
    required Uint8List value,
    bool response = true,
  });

  /// Subscribes to [characteristic].
  ///
  /// Listen to the returned stream to get notified
  /// when the value of the [characteristic] changes.
  ///
  /// When stopping listening to the stream the subscription to the
  /// [characteristic] ends.
  Future<Stream<Uint8List>> subscribeCharacteristic(
    Characteristic characteristic,
  );

  @override
  bool operator ==(other) {
    return (other is BleDevice && other.information == information);
  }

  @override
  int get hashCode => information.hashCode;
}
