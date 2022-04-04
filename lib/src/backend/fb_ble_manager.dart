import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/src/backend/fb_ble_device.dart';
import 'fb_conversion.dart';

/// The implementation of a [BleManager] using flutter blue.
class FbBleManager implements BleManager {
  final fb.FlutterBlue _fb;
  final FbConversion _conversion;
  final _controller = StreamController<List<ScanResult>>.broadcast();
  bool _isInitialized = false;
  bool _isScanning = false;

  FbBleManager(fb.FlutterBlue fb, FbConversion conversion)
      : _fb = fb,
        _conversion = conversion;

  @override
  Future<Set<BleDevice>> get connectedDevices async {
    final List<fb.BluetoothDevice> devices;
    try {
      devices = await _fb.connectedDevices;
    } catch (e) {
      throw BleException('Failed to get connected devices.', exception: e);
    }
    return devices.map((d) => FbBleDevice(d, _conversion)).toSet();
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isScanning => _isScanning;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _fb.scanResults.forEach((results) {
        _controller.add(
          results.map((result) => _conversion.toScanResult(result)).toList(),
        );
      });
    } catch (e) {
      throw BleException('Initialization failed.', exception: e);
    }
    _isInitialized = true;
  }

  @override
  Stream<List<ScanResult>> get scanResults => _controller.stream;

  @override
  Future<void> startScan({
    List<Uuid>? withServices,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!_isInitialized) {
      throw const BleException("Started a scan before initializing.");
    } else if (_isScanning) {
      throw const BleException("Is already scanning!");
    }

    _isScanning = true;
    try {
      await _fb.startScan(
        timeout: timeout,
        withServices:
            withServices?.map((e) => _conversion.fromUuid(e)).toList() ?? [],
      );
    } catch (e) {
      throw BleException("BLE scanning failed.", exception: e);
    } finally {
      _isScanning = false;
    }
  }

  @override
  Future<void> stopScan() async {
    if (!_isInitialized) {
      throw const BleException("Stopped a scan before initializing.");
    }
    if (!_isScanning) return;
    try {
      await _fb.stopScan();
    } catch (e) {
      throw BleException("Stopping BLE scan failed.", exception: e);
    } finally {
      _isScanning = false;
    }
  }
}
