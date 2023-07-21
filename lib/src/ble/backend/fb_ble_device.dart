import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:weight_scale/src/ble/ble.dart';

import 'fb_backend.dart';

/// An implementation of a [BleDevice] using flutter blue.
///
/// The [state] is taken directly from the flutter blue [BluetoothDevice] state.
/// This ensures that the [state] is always reflecting the true state of the
/// actual ble device. Note that this is not true before connecting and after
/// disconnecting, because in those cases the [state] as well as the
/// [currentState] is always [BleDeviceState.disconnected] no matter what states
/// the [BluetoothDevice] emits. Of course the [BluetoothDevice] is not expected
/// to emit any stats while it's not connected.
/// On android the dis- and connecting states are not emitted.
class FbBleDevice extends BleDevice {
  final BluetoothDevice _device;
  final FbConversion _conversion;

  List<Service> _services = [];

  @override
  final BleDeviceInformation information;

  FbBleDevice(BluetoothDevice device, FbConversion conversion)
      : information = BleDeviceInformation(name: device.name, id: device.id.id),
        _device = device,
        _conversion = conversion;

  @override
  Future<List<Service>> get services async => _services;

  @override
  Stream<bool> get connected => _device.state
      .map((state) => state == BluetoothDeviceState.connected)
      .asBroadcastStream();

  @override
  Future<BleDeviceState> get currentState =>
      _device.state.first.then((state) => _conversion.toBleDeviceState(state));

  Future<bool> get _isConnected async =>
      await currentState == BleDeviceState.connected;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    if (await _isConnected) {
      throw const BleException('You are already connected!');
    }

    try {
      final done = connected.firstWhere(
        (connected) => connected,
        // Happens when the connection fails and the connected stream is closed.
        orElse: () => false,
      );
      await _device
          .connect(timeout: null, autoConnect: false)
          .timeout(timeout, onTimeout: () async => throw TimeoutException(''));

      await done; // Ensures that the connected state was emitted.
    } on TimeoutException {
      _device.disconnect();
      throw BleException(
        "Couldn't connect in time.",
        detail: "Couldn't establish connection during the $timeout.",
      );
    } catch (e) {
      throw BleException("Connection failed.", exception: e);
    }
  }

  @override
  Future<void> disconnect() async {
    if (!(await _isConnected)) return;
    try {
      final done = connected.firstWhere(
        (state) => !state,
        // Happens when the connection fails and the connected stream is closed.
        orElse: () => true,
      );
      await _device.disconnect();
      await done; // Ensures that the disconnect state was emitted.
    } catch (e) {
      throw BleException("Disconnection failed.", exception: e);
    }
  }

  @override
  Future<List<Service>> discoverServices() async {
    if (!(await _isConnected)) {
      throw const BleException("Can't discover the services if not connected.");
    }

    try {
      final services = await _device.discoverServices();
      _services =
          services.map((service) => _conversion.toService(service)).toList();
      return _services;
    } catch (e) {
      throw BleException("Service discovery failed.", exception: e);
    }
  }

  @override
  Future<Uint8List> readCharacteristic(Characteristic characteristic) async {
    if (!(await _isConnected)) {
      throw const BleException(
        "Can't read the characteristic if not connected.",
      );
    }

    try {
      final c = _conversion.fromCharacteristic(characteristic);
      return Uint8List.fromList(await c.read());
    } catch (e) {
      throw BleException("Couldn't read the characteristic.", exception: e);
    }
  }

  @override
  Future<void> writeCharacteristic(
    Characteristic characteristic, {
    required Uint8List value,
    bool response = true,
  }) async {
    if (!(await _isConnected)) {
      throw const BleException(
        "Can' write the characteristic if not connected.",
      );
    }

    try {
      final c = _conversion.fromCharacteristic(characteristic);
      await c.write(value.toList(), withoutResponse: !response);
    } catch (e) {
      throw BleException("Couldn't write to the characteristic.", exception: e);
    }
  }

  @override
  Future<Stream<Uint8List>> subscribeCharacteristic(
    Characteristic characteristic,
  ) async {
    if (!(await _isConnected)) {
      throw const BleException(
        "Can't subscribe to the characteristic if not connected.",
      );
    }

    final c = _conversion.fromCharacteristic(characteristic);

    final subscription = c.value.listen(null);
    final controller = StreamController<Uint8List>();

    controller.onCancel = () async {
      await subscription.cancel();
      await controller.close();
      await _setNotify(c, false);
    };

    subscription.onData((data) => controller.add(Uint8List.fromList(data)));

    await _setNotify(c, true);

    return controller.stream;
  }

  /// Sets the notification on the [characteristic] to [notify].
  ///
  /// Will throw an ble exception if setting the notification fails.
  Future<void> _setNotify(
    BluetoothCharacteristic characteristic,
    bool notify,
  ) async {
    if (!(await _isConnected)) return; // No need to (un)subscribe.
    final action = notify ? 'enable' : 'disable';

    bool successful;
    try {
      successful = await characteristic.setNotifyValue(notify);
    } catch (e) {
      throw BleException(
        'Failed to $action notification.',
        detail: 'Tried to $action notification on $characteristic.',
        exception: e,
      );
    }

    if (!successful) {
      throw BleException(
        "Couldn't $action the notification!",
        detail: "Couldn't $action the notification for $characteristic",
      );
    }
  }
}
