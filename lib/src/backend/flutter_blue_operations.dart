import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:weight_scale/src/backend/flutter_blue_convert.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';

class FlutterBlueOperations implements BleOperations {
  final fb.FlutterBlue fbInstance;
  final FlutterBlueConvert fbConvert;

  FlutterBlueOperations(this.fbInstance, this.fbConvert);

  @override
  Future<void> connect({
    required BleDevice device,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    fb.BluetoothDevice bluetoothDevice = fbConvert.toBluetoothDevice(device);
    try {
      await bluetoothDevice.connect(timeout: timeout);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Connection failed.");
    }
  }

  @override
  Future<void> disconnect({required BleDevice device}) async {
    fb.BluetoothDevice bluetoothDevice = fbConvert.toBluetoothDevice(device);
    try {
      await bluetoothDevice.disconnect();
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Disconnection failed.");
    }
  }

  @override
  Future<void> addDisconnectCallback({
    required BleDevice device,
    required Future<void> Function() callback,
  }) async {
    fb.BluetoothDevice bluetoothDevice = fbConvert.toBluetoothDevice(device);
    await bluetoothDevice.state.forEach((element) async {
      if (element == fb.BluetoothDeviceState.disconnected) {
        await callback();
      }
    });
  }

  @override
  Future<List<Service>> discoverService({required BleDevice device}) async {
    fb.BluetoothDevice bluetoothDevice = fbConvert.toBluetoothDevice(device);
    try {
      List<fb.BluetoothService> services =
          await bluetoothDevice.discoverServices();
      return services.map(fbConvert.toService).toList();
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Discovering services failed.");
    }
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<Uint8List> readCharacteristic({
    required Characteristic characteristic,
  }) async {
    fb.BluetoothCharacteristic bluetoothCharacteristic =
        fbConvert.toBluetoothCharacteristic(characteristic);

    try {
      List<int> value = await bluetoothCharacteristic.read();
      return Uint8List.fromList(value);
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Reading to characteristic failed.");
    }
  }

  @override
  Stream<List<ScanResult>> get scanResults =>
      fbInstance.scanResults.map((list) => list
          .map((scanResult) => fbConvert.toScanResult(scanResult, this))
          .toList());

  @override
  Future<void> startScan({
    required Duration timeout,
    List<Uuid>? withServices,
  }) async {
    try {
      await fbInstance.startScan(
        withServices: withServices?.map(fbConvert.toGuid).toList() ?? const [],
        timeout: timeout,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Scanning failed.");
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      await fbInstance.stopScan();
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Stopping scan failed.");
    }
  }

  @override
  Future<Stream<Uint8List>> subscribeCharacteristic({
    required Characteristic characteristic,
  }) async {
    fb.BluetoothCharacteristic bluetoothCharacteristic =
        fbConvert.toBluetoothCharacteristic(characteristic);

    try {
      await bluetoothCharacteristic.setNotifyValue(true);
      Stream<List<int>> value = bluetoothCharacteristic.value;
      return value.map((list) => Uint8List.fromList(list));
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Subscribing to characteristic failed.");
    }
  }

  @override
  Future<void> writeCharacteristic({
    required Characteristic characteristic,
    required Uint8List value,
    bool response = true,
  }) async {
    fb.BluetoothCharacteristic bluetoothCharacteristic =
        fbConvert.toBluetoothCharacteristic(characteristic);

    try {
      await bluetoothCharacteristic.write(value.toList(),
          withoutResponse: !response);
    } catch (e) {
      debugPrint(e.toString());
      throw BleOperationException("Writing to characteristic failed.");
    }
  }
}
