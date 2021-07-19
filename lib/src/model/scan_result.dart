import 'dart:typed_data';

import '../ble_device.dart';
import 'uuid.dart';

class ScanResult {
  final BleDevice device;
  final int rssi;
  final Uint8List manufacturerData;
  final Map<Uuid, Uint8List> serviceData;
  final List<Uuid> serviceUuids;

  ScanResult({
    required this.device,
    required this.rssi,
    required this.manufacturerData,
    required this.serviceData,
    required this.serviceUuids,
  });
}
