import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/model/uuid.dart';

class ScanResult extends Equatable {
  final BleDevice device;
  final Uint8List manufacturerData;
  final Map<Uuid, Uint8List> serviceData;
  final List<Uuid> serviceUuids;
  final int rssi;
  final int? txPowerLevel;

  const ScanResult({
    required this.device,
    required this.manufacturerData,
    required this.serviceData,
    required this.serviceUuids,
    required this.rssi,
    this.txPowerLevel,
  });

  @override
  List<Object?> get props => [
        device,
        manufacturerData,
        serviceData,
        serviceUuids,
        rssi,
        txPowerLevel,
      ];
}
