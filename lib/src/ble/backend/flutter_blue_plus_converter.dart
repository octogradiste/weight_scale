import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/src/ble/model.dart';

/// A helper class for converting from and to flutter blue objects.
class FlutterBluePlusConverter {
  static BleDeviceState toBleDeviceState(blue.BluetoothConnectionState state) {
    if (state == blue.BluetoothConnectionState.connected) {
      return BleDeviceState.connected;
    } else {
      return BleDeviceState.disconnected;
    }
  }

  static BleDeviceInformation toBleDeviceInformation(
    blue.BluetoothDevice device,
  ) {
    return BleDeviceInformation(
      id: device.remoteId.str,
      name: device.localName,
    );
  }

  static ScanResult toScanResult(blue.ScanResult scanResult) {
    return ScanResult(
      deviceInformation: toBleDeviceInformation(scanResult.device),
      serviceData: scanResult.advertisementData.serviceData
          .map((key, value) => MapEntry(Uuid(key), Uint8List.fromList(value))),
      serviceUuids: scanResult.advertisementData.serviceUuids
          .map((uuid) => Uuid(uuid))
          .toList(),
      rssi: scanResult.rssi,
      txPowerLevel: scanResult.advertisementData.txPowerLevel,
    );
  }

  static Uuid toUuid(blue.Guid guid) {
    return Uuid(guid.toString());
  }
}
