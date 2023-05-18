import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:flutter_blue_plus/gen/flutterblueplus.pbserver.dart' as protos;
import 'package:weight_scale/src/ble/ble.dart';

import 'fb_backend.dart';

/// A helper class for converting from and to flutter blue objects.
class FbConversion {
  fb.BluetoothDeviceState fromBleDeviceState(BleDeviceState state) {
    switch (state) {
      case BleDeviceState.connected:
        return fb.BluetoothDeviceState.connected;
      case BleDeviceState.disconnected:
        return fb.BluetoothDeviceState.disconnected;
      case BleDeviceState.connecting:
        return fb.BluetoothDeviceState.connecting;
      case BleDeviceState.disconnecting:
        return fb.BluetoothDeviceState.disconnecting;
    }
  }

  BleDevice toBleDevice(fb.BluetoothDevice device) {
    return FbBleDevice(device, this);
  }

  fb.BluetoothDevice fromBleDevice(BleDevice device) {
    return fb.BluetoothDevice.fromProto(_protoFromBleDevice(device));
  }

  protos.BluetoothDevice _protoFromBleDevice(BleDevice device) {
    return protos.BluetoothDevice(
      remoteId: device.information.id,
      name: device.information.name,
      type: protos.BluetoothDevice_Type.LE,
    );
  }

  BleDeviceState toBleDeviceState(fb.BluetoothDeviceState state) {
    switch (state) {
      case fb.BluetoothDeviceState.disconnected:
        return BleDeviceState.disconnected;
      case fb.BluetoothDeviceState.connecting:
        return BleDeviceState.connecting;
      case fb.BluetoothDeviceState.connected:
        return BleDeviceState.connected;
      case fb.BluetoothDeviceState.disconnecting:
        return BleDeviceState.disconnecting;
    }
  }

  ScanResult toScanResult(fb.ScanResult scanResult) {
    return ScanResult(
      device: toBleDevice(scanResult.device),
      serviceData: scanResult.advertisementData.serviceData
          .map((key, value) => MapEntry(Uuid(key), Uint8List.fromList(value))),
      serviceUuids: scanResult.advertisementData.serviceUuids
          .map((uuid) => Uuid(uuid))
          .toList(),
      rssi: scanResult.rssi,
      txPowerLevel: scanResult.advertisementData.txPowerLevel,
    );
  }

  fb.ScanResult fromScanResult(ScanResult scanResult) {
    return fb.ScanResult.fromProto(_protoFromScanResult(scanResult));
  }

  protos.ScanResult _protoFromScanResult(ScanResult scanResult) {
    return protos.ScanResult(
      device: _protoFromBleDevice(scanResult.device),
      advertisementData: protos.AdvertisementData(
        txPowerLevel: protos.Int32Value(value: scanResult.txPowerLevel),
        serviceData: scanResult.serviceData.map(
          (key, value) => MapEntry(key.uuid, value.toList()),
        ),
        serviceUuids: scanResult.serviceUuids.map((u) => u.uuid),
      ),
      rssi: scanResult.rssi,
    );
  }

  Service toService(fb.BluetoothService service) {
    return Service(
      deviceId: service.deviceId.id,
      uuid: toUuid(service.uuid),
      characteristics: service.characteristics
          .map((characteristic) => toCharacteristic(characteristic))
          .toList(),
      includedServices: service.includedServices
          .map((includedService) => toService(includedService))
          .toList(),
      isPrimary: service.isPrimary,
    );
  }

  fb.BluetoothService fromService(Service service) {
    return fb.BluetoothService.fromProto(_protoFromService(service));
  }

  protos.BluetoothService _protoFromService(Service service) {
    return protos.BluetoothService(
      uuid: service.uuid.uuid,
      remoteId: service.deviceId,
      characteristics: service.characteristics
          .map((characteristic) => _protoFromCharacteristic(characteristic)),
      includedServices: service.includedServices
          .map((includedService) => _protoFromService(includedService)),
      isPrimary: service.isPrimary,
    );
  }

  Characteristic toCharacteristic(fb.BluetoothCharacteristic characteristic) {
    return Characteristic(
      deviceId: characteristic.deviceId.id,
      serviceUuid: toUuid(characteristic.serviceUuid),
      uuid: toUuid(characteristic.uuid),
      descriptors: characteristic.descriptors
          .map((descriptor) => toDescriptor(descriptor))
          .toList(),
    );
  }

  fb.BluetoothCharacteristic fromCharacteristic(Characteristic characteristic) {
    return fb.BluetoothCharacteristic.fromProto(
      _protoFromCharacteristic(characteristic),
    );
  }

  protos.BluetoothCharacteristic _protoFromCharacteristic(
    Characteristic characteristic,
  ) {
    return protos.BluetoothCharacteristic(
      uuid: characteristic.uuid.uuid,
      remoteId: characteristic.deviceId,
      serviceUuid: characteristic.serviceUuid.uuid,
      descriptors: characteristic.descriptors
          .map((descriptor) => _protoFromDescriptor(descriptor)),
    );
  }

  Descriptor toDescriptor(fb.BluetoothDescriptor descriptor) {
    return Descriptor(
      deviceId: descriptor.deviceId.id,
      serviceUuid: toUuid(descriptor.serviceUuid),
      characteristicUuid: toUuid(descriptor.characteristicUuid),
      uuid: toUuid(descriptor.uuid),
    );
  }

  fb.BluetoothDescriptor fromDescriptor(Descriptor descriptor) {
    return fb.BluetoothDescriptor.fromProto(_protoFromDescriptor(descriptor));
  }

  protos.BluetoothDescriptor _protoFromDescriptor(Descriptor descriptor) {
    return protos.BluetoothDescriptor(
      uuid: descriptor.uuid.uuid,
      remoteId: descriptor.deviceId,
      serviceUuid: descriptor.serviceUuid.uuid,
      characteristicUuid: descriptor.characteristicUuid.uuid,
    );
  }

  Uuid toUuid(fb.Guid guid) {
    return Uuid(guid.toString());
  }

  fb.Guid fromUuid(Uuid uuid) {
    return fb.Guid(uuid.uuid);
  }
}
