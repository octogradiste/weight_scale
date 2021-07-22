import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_blue/gen/flutterblue.pbserver.dart' as protos;
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/weight_scale.dart';

class FlutterBlueConvert {
  ScanResult toScanResult(
    fb.ScanResult scanResult,
    BleOperations operations,
  ) {
    return ScanResult(
      device: toBleDevice(scanResult.device, operations),
      manufacturerData: Uint8List.fromList(scanResult
          .advertisementData.manufacturerData.values
          .reduce((value, element) {
        value.addAll(element);
        return value;
      })),
      serviceData: scanResult.advertisementData.serviceData
          .map((key, value) => MapEntry(Uuid(key), Uint8List.fromList(value))),
      serviceUuids: scanResult.advertisementData.serviceUuids
          .map((uuid) => Uuid(uuid))
          .toList(),
      rssi: scanResult.rssi,
      txPowerLevel: scanResult.advertisementData.txPowerLevel,
    );
  }

  BleDevice toBleDevice(
    fb.BluetoothDevice device,
    BleOperations operations,
  ) {
    return BleDevice(
      id: device.id.id,
      name: device.name,
      operations: operations,
    );
  }

  Service toService(fb.BluetoothService service) {
    return Service(
      deviceId: service.deviceId.id,
      uuid: toUuid(service.uuid),
      characteristics: service.characteristics.map(toCharacteristic).toList(),
    );
  }

  Characteristic toCharacteristic(
    fb.BluetoothCharacteristic characteristic,
  ) {
    return Characteristic(
      deviceId: characteristic.deviceId.id,
      serviceUuid: toUuid(characteristic.serviceUuid),
      uuid: toUuid(characteristic.uuid),
      descriptors: characteristic.descriptors.map(toDescriptor).toList(),
    );
  }

  Descriptor toDescriptor(fb.BluetoothDescriptor descriptor) {
    return Descriptor(
      deviceId: descriptor.deviceId.id,
      serviceUuid: toUuid(descriptor.serviceUuid),
      characteristicUuid: toUuid(descriptor.characteristicUuid),
      uuid: toUuid(descriptor.uuid),
      value: Uint8List.fromList(descriptor.lastValue),
    );
  }

  Uuid toUuid(fb.Guid guid) {
    return Uuid(guid.toString());
  }

  fb.BluetoothDevice toBluetoothDevice(BleDevice device) {
    return fb.BluetoothDevice.fromProto(protos.BluetoothDevice(
      remoteId: device.id,
      name: device.name,
      type: protos.BluetoothDevice_Type.UNKNOWN,
    ));
  }

  fb.BluetoothCharacteristic toBluetoothCharacteristic(
      Characteristic characteristic) {
    return fb.BluetoothCharacteristic.fromProto(protos.BluetoothCharacteristic(
      uuid: characteristic.uuid.uuid,
      remoteId: characteristic.deviceId,
      serviceUuid: characteristic.serviceUuid.uuid,
      descriptors: characteristic.descriptors
          .map((descriptor) => protos.BluetoothDescriptor(
                uuid: descriptor.uuid.uuid,
                remoteId: descriptor.deviceId,
                serviceUuid: descriptor.serviceUuid.uuid,
                characteristicUuid: descriptor.characteristicUuid.uuid,
                value: descriptor.value.toList(),
              )),
    ));
  }

  fb.Guid toGuid(Uuid uuid) {
    return fb.Guid(uuid.uuid);
  }
}
