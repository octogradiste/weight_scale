import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';
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
class FbBleDevice extends BleDevice {
  final BluetoothDevice _device;
  final FbConversion _conversion;

  final _stateController = StreamController<BleDeviceState>.broadcast();

  List<Service> _services = [];
  BleDeviceState _currentState = BleDeviceState.disconnected;

  @override
  final BleDeviceInformation information;

  FbBleDevice(BluetoothDevice device, FbConversion conversion)
      : information = BleDeviceInformation(name: device.name, id: device.id.id),
        _device = device,
        _conversion = conversion;

  @override
  Future<List<Service>> get services async => _services;

  @override
  Stream<BleDeviceState> get state => _stateController.stream;

  @override
  BleDeviceState get currentState => _currentState;

  bool get _isConnectingOrConnected =>
      currentState == BleDeviceState.connecting ||
      currentState == BleDeviceState.connected;

  /// Updates the [_currentState] and adds the [state] to the [_stateController].
  void _updateState(BleDeviceState state) {
    _currentState = state;
    _stateController.add(_currentState);
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    if (_isConnectingOrConnected) {
      throw BleException(
        'You are already connected!',
        detail: 'Currently in the ${currentState.name} state.',
      );
    }

    try {
      final connected = state.firstWhere((s) => s == BleDeviceState.connected);

      // We need to skip the first one, because it will just be the
      // current state, i.e. disconnected. This is due to the flutter blue
      // implementation of the state getter.
      final subscription = _device.state.skip(1).listen(null);
      subscription.onData((state) {
        _updateState(_conversion.toBleDeviceState(state));
        if (_currentState == BleDeviceState.disconnected) {
          subscription.cancel();
        }
      });

      await _device.connect(timeout: timeout);
      await connected; // Ensures that the connected state was emitted.
    } on TimeoutException catch (e) {
      throw BleException(
        "Couldn't connect in time.",
        detail: "Couldn't establish connection during  the $timeout.",
        exception: e,
      );
    } catch (e) {
      _updateState(BleDeviceState.disconnected);
      throw BleException("Connection failed.", exception: e);
    }
  }

  @override
  Future<void> disconnect() async {
    if (!_isConnectingOrConnected) return;
    try {
      final disconnected = state.firstWhere(
        (state) => state == BleDeviceState.disconnected,
      );
      await _device.disconnect();
      await disconnected; // Ensures that the disconnect state was emitted.
    } catch (e) {
      // The disconnected state might not have been emitted by the
      // bluetooth device.
      _updateState(BleDeviceState.disconnected);
      throw BleException("Disconnection failed.", exception: e);
    }
  }

  @override
  Future<List<Service>> discoverServices() async {
    if (!_isConnectingOrConnected) {
      throw BleException(
        "Can't discover the services if not connected.",
        detail: 'Currently in the ${currentState.name} state.',
      );
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
    if (!_isConnectingOrConnected) {
      throw BleException(
        "Can't read the characteristic if not connected.",
        detail: 'Currently in the ${currentState.name} state.',
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
    if (!_isConnectingOrConnected) {
      throw BleException(
        "Can' write the characteristic if not connected.",
        detail: 'Currently in the ${currentState.name} state.',
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
    if (!_isConnectingOrConnected) {
      throw BleException(
        "Can't subscribe to the characteristic if not connected.",
        detail: 'Currently in the ${currentState.name} state.',
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
    if (!_isConnectingOrConnected) return; // No need to (un)subscribe.
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
