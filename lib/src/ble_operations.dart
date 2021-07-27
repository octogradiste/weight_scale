import 'dart:typed_data';

import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';

/// An exception thrown when a ble operation fails.
class BleOperationException implements Exception {
  /// This [message] is guaranteed to be user readable.
  final String message;
  const BleOperationException(this.message);
}

abstract class BleOperations {
  abstract final Stream<List<ScanResult>> scanResults;

  Future<void> initialize();

  Future<void> startScan({required Duration timeout, List<Uuid>? withServices});

  Future<void> stopScan();

  Future<void> connect({
    required BleDevice device,
    Duration timeout = const Duration(seconds: 15),
  });

  Future<void> disconnect({required BleDevice device});

  Future<void> addDisconnectCallback({
    required BleDevice device,
    required Future<void> Function() callback,
  });

  Future<List<Service>> discoverService({required BleDevice device});

  Future<Uint8List> readCharacteristic({
    required Characteristic characteristic,
  });

  Future<void> writeCharacteristic({
    required Characteristic characteristic,
    required Uint8List value,
    bool response = true,
  });

  Future<Stream<Uint8List>> subscribeCharacteristic({
    required Characteristic characteristic,
  });
}
