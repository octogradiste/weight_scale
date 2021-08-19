import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_blue/gen/flutterblue.pb.dart' as protos;
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/src/backend/flutter_blue_convert.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/descriptor.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';

import '../ble_service_test.mocks.dart';

void main() {
  late FlutterBlueConvert convert;
  final String mac = "38-F1-23-31-5E-F6";
  final String id1 = "6989dc2f-07b3-4c21-a8ed-1d4fa8c512e2";
  final String id2 = "aab74c28-bab1-4320-9f4a-0a27ad852e26";
  final String id3 = "cd0593a8-01d7-45d5-96d7-07d4bc4aea5c";
  final String id4 = "6f71d79e-cc19-49a4-974b-f4b878a93a23";
  final String id5 = "ac783219-8fd0-48f3-b9b3-fc95b5d5c0c6";

  setUp(() {
    convert = FlutterBlueConvert();
  });

  test('toUuid', () {
    fb.Guid guid = fb.Guid(id1);
    Uuid uuid = convert.toUuid(guid);
    expect(uuid.uuid, id1);
  });

  test('toGuid', () {
    Uuid uuid = Uuid(id1);
    fb.Guid guid = convert.toGuid(uuid);
    expect(guid.toString(), id1);
  });

  test('toDescriptor', () {
    List<int> value = const [1, 2, 3];
    fb.BluetoothDescriptor fbDescriptor =
        fb.BluetoothDescriptor.fromProto(protos.BluetoothDescriptor(
      uuid: id1,
      characteristicUuid: id2,
      serviceUuid: id3,
      remoteId: mac,
      value: value,
    ));
    Descriptor descriptor = convert.toDescriptor(fbDescriptor);
    expect(descriptor.uuid.uuid, id1);
    expect(descriptor.characteristicUuid.uuid, id2);
    expect(descriptor.serviceUuid.uuid, id3);
    expect(descriptor.deviceId, mac);
    expect(descriptor.value.toList(), containsAllInOrder(value));
  });

  test('toCharacteristic', () {
    List<int> description1 = const [1, 2, 3];

    fb.BluetoothCharacteristic fbCharacteristic =
        fb.BluetoothCharacteristic.fromProto(protos.BluetoothCharacteristic(
      uuid: id1,
      serviceUuid: id2,
      remoteId: mac,
      descriptors: [
        protos.BluetoothDescriptor(
          characteristicUuid: id1,
          serviceUuid: id2,
          remoteId: mac,
          uuid: id3,
          value: description1,
        )
      ],
    ));

    Characteristic characteristic = convert.toCharacteristic(fbCharacteristic);

    expect(characteristic.uuid.uuid, id1);
    expect(characteristic.serviceUuid.uuid, id2);
    expect(characteristic.deviceId, mac);
    expect(characteristic.descriptors.length, 1);
    expect(
      characteristic.descriptors.first.toString(),
      Descriptor(
        deviceId: mac,
        serviceUuid: Uuid(id2),
        characteristicUuid: Uuid(id1),
        uuid: Uuid(id3),
        value: Uint8List.fromList(description1),
      ).toString(),
    );
  });

  test('toBluetoothCharacteristic', () {
    List<int> description1 = const [1, 2, 3];

    Characteristic characteristic = Characteristic(
      deviceId: mac,
      serviceUuid: Uuid(id2),
      uuid: Uuid(id1),
      descriptors: [
        Descriptor(
          deviceId: mac,
          serviceUuid: Uuid(id2),
          characteristicUuid: Uuid(id1),
          uuid: Uuid(id3),
          value: Uint8List.fromList(description1),
        )
      ],
    );

    fb.BluetoothCharacteristic fbCharacteristic =
        convert.toBluetoothCharacteristic(characteristic);

    expect(fbCharacteristic.uuid.toString(), id1);
    expect(fbCharacteristic.serviceUuid.toString(), id2);
    expect(fbCharacteristic.deviceId.id, mac);
    expect(fbCharacteristic.descriptors.length, 1);
    fb.BluetoothDescriptor fbDescriptor = fbCharacteristic.descriptors.first;
    expect(fbDescriptor.uuid.toString(), id3);
    expect(fbDescriptor.characteristicUuid.toString(), id1);
    expect(fbDescriptor.serviceUuid.toString(), id2);
    expect(fbDescriptor.deviceId.id, mac);
    expect(fbCharacteristic.descriptors.first.lastValue,
        containsAllInOrder(description1));
  });

  test('toService', () {
    protos.BluetoothCharacteristic protosCharacteristic =
        protos.BluetoothCharacteristic(
      uuid: id2,
      remoteId: mac,
      serviceUuid: id1,
    );
    fb.BluetoothService fbService =
        fb.BluetoothService.fromProto(protos.BluetoothService(
      uuid: id1,
      remoteId: mac,
      characteristics: [protosCharacteristic],
    ));
    Service service = convert.toService(fbService);
    expect(service.uuid.uuid, id1);
    expect(service.deviceId, mac);
    expect(service.characteristics.length, 1);
    expect(service.characteristics.first,
        convert.toCharacteristic(fbService.characteristics.first));
  });

  test("toBleDevice", () {
    fb.BluetoothDevice fbDevice = fb.BluetoothDevice.fromProto(
        protos.BluetoothDevice(name: "name", remoteId: "id"));

    BleDevice device = convert.toBleDevice(fbDevice, MockBleOperations());
    expect(device.name, "name");
    expect(device.id, "id");
  });

  test('toBluetoothDevice', () {
    BleDevice device =
        BleDevice(id: "id", name: "name", operations: MockBleOperations());

    fb.BluetoothDevice fbDevice = convert.toBluetoothDevice(device);
    expect(fbDevice.name, "name");
    expect(fbDevice.id.id, "id");
    expect(fbDevice.type, fb.BluetoothDeviceType.unknown);
  });

  test('toScanResult', () {
    fb.ScanResult fbScanResult = fb.ScanResult.fromProto(
      protos.ScanResult(
        device: protos.BluetoothDevice(remoteId: mac, name: "name"),
        advertisementData: protos.AdvertisementData(
          txPowerLevel: protos.Int32Value(value: 100),
          manufacturerData: {
            1: [1, 2, 3],
            2: [4, 5, 6],
          },
          serviceData: {
            id1: [3, 4, 5],
          },
          serviceUuids: [id2, id3, id4, id5],
        ),
        rssi: 44,
      ),
    );
    ScanResult scanResult =
        convert.toScanResult(fbScanResult, MockBleOperations());

    expect(scanResult.txPowerLevel, 100);
    expect(scanResult.rssi, 44);
    expect(scanResult.device.id, mac);
    expect(scanResult.device.name, "name");
    expect(scanResult.manufacturerData, Uint8List.fromList([1, 2, 3, 4, 5, 6]));
    expect(scanResult.serviceData, {
      Uuid(id1): Uint8List.fromList([3, 4, 5])
    });
    expect(
        scanResult.serviceUuids,
        containsAllInOrder([
          Uuid(id2),
          Uuid(id3),
          Uuid(id4),
          Uuid(id5),
        ]));
  });
}
