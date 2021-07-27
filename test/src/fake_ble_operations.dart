import 'package:weight_scale/src/ble_device.dart';
import 'dart:typed_data';

import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/characteristic.dart';

class FakeBleOperations implements BleOperations {
  final Duration operationDuration;

  FakeBleOperations(this.operationDuration);

  @override
  Future<void> connect({
    required BleDevice device,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return Future.delayed(operationDuration);
  }

  @override
  Future<void> disconnect({required BleDevice device}) {
    return Future.delayed(operationDuration);
  }

  @override
  Future<List<Service>> discoverService({required BleDevice device}) {
    return Future.delayed(operationDuration, () => List.empty());
  }

  @override
  Future<void> initialize() {
    return Future.delayed(operationDuration);
  }

  @override
  Future<Uint8List> readCharacteristic({
    required Characteristic characteristic,
  }) {
    return Future.delayed(
      operationDuration,
      () => Uint8List.fromList(List.empty()),
    );
  }

  @override
  Stream<List<ScanResult>> get scanResults => Stream.empty();

  @override
  Future<void> startScan({
    required Duration timeout,
    List<Uuid>? withServices,
  }) {
    return Future.delayed(operationDuration);
  }

  @override
  Future<void> stopScan() {
    return Future.delayed(operationDuration);
  }

  @override
  Future<Stream<Uint8List>> subscribeCharacteristic({
    required Characteristic characteristic,
  }) {
    return Future.delayed(operationDuration, () => Stream.empty());
  }

  @override
  Future<void> writeCharacteristic({
    required Characteristic characteristic,
    required Uint8List value,
    bool response = false,
  }) {
    return Future.delayed(operationDuration);
  }

  @override
  Future<void> addDisconnectCallback({
    required BleDevice device,
    required Future<void> Function() callback,
  }) async {}
}
