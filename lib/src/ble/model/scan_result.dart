import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:weight_scale/src/ble/model.dart';

class ScanResult extends Equatable {
  final BleDeviceInformation deviceInformation;
  final Map<Uuid, Uint8List> serviceData;
  final List<Uuid> serviceUuids;
  final int rssi;
  final int? txPowerLevel;

  const ScanResult({
    required this.deviceInformation,
    required this.serviceData,
    required this.serviceUuids,
    required this.rssi,
    this.txPowerLevel,
  });

  @override
  List<Object?> get props => [
        deviceInformation,
        serviceData,
        serviceUuids,
        rssi,
        txPowerLevel,
      ];
}
