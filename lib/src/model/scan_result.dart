import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/model/uuid.dart';

class ScanResult {
  final BleDevice device;
  final Uint8List manufacturerData;
  final Map<Uuid, Uint8List> serviceData;
  final List<Uuid> serviceUuids;
  final int rssi;
  final int? txPowerLevel;

  ScanResult({
    required this.device,
    required this.manufacturerData,
    required this.serviceData,
    required this.serviceUuids,
    required this.rssi,
    this.txPowerLevel,
  });

  @override
  bool operator ==(Object other) {
    return other is ScanResult &&
        other.device == device &&
        other.manufacturerData == manufacturerData &&
        mapEquals(other.serviceData, serviceData) &&
        listEquals(other.serviceUuids, serviceUuids) &&
        other.rssi == rssi &&
        other.txPowerLevel == txPowerLevel;
  }

  @override
  int get hashCode => hashValues(
        device,
        manufacturerData,
        serviceData,
        serviceUuids,
        rssi,
        txPowerLevel,
      );
}
