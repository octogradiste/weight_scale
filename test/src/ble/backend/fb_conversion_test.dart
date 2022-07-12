import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_blue/gen/flutterblue.pbserver.dart' as protos;
import 'package:weight_scale/src/ble/backend/fb_backend.dart';
import 'package:weight_scale/src/ble/ble.dart';

/// Using the conversion methods to convert to flutter blue objects and then
/// back to compare with the original objects.
void main() {
  const descriptor = Descriptor(
    deviceId: 'id',
    serviceUuid: Uuid('83b504fc-374c-4868-945a-4cc58474d46e'),
    characteristicUuid: Uuid('62e25928-c9c3-4fb0-abef-f9e110473c3d'),
    uuid: Uuid('38a2d186-8d80-4913-bd70-24e701644896'),
  );

  const characteristic = Characteristic(
    deviceId: 'id',
    serviceUuid: Uuid('83b504fc-374c-4868-945a-4cc58474d46e'),
    uuid: Uuid('62e25928-c9c3-4fb0-abef-f9e110473c3d'),
    descriptors: [
      Descriptor(
        deviceId: 'id',
        serviceUuid: Uuid('83b504fc-374c-4868-945a-4cc58474d46e'),
        characteristicUuid: Uuid('62e25928-c9c3-4fb0-abef-f9e110473c3d'),
        uuid: Uuid('68f96847-c42a-416d-bcc6-6fb808723ead'),
      ),
      descriptor,
    ],
  );

  const service = Service(
    deviceId: 'id',
    uuid: Uuid('f495aa84-e42e-4ddd-868e-565b5b737fe0'),
    characteristics: [
      Characteristic(
        deviceId: 'id',
        serviceUuid: Uuid('f495aa84-e42e-4ddd-868e-565b5b737fe0'),
        uuid: Uuid('3dac59ed-ad28-4d1b-8658-c121545f01cc'),
      ),
      Characteristic(
        deviceId: 'id',
        serviceUuid: Uuid('f495aa84-e42e-4ddd-868e-565b5b737fe0'),
        uuid: Uuid('10b76e70-8504-4e9d-819e-06483fd68b04'),
      ),
    ],
    includedServices: [
      Service(
        deviceId: 'id',
        uuid: Uuid('f71ee578-dfe9-4962-9385-5b305b444f6a'),
        characteristics: [characteristic],
        includedServices: [],
        isPrimary: false,
      ),
    ],
    isPrimary: false,
  );

  late FbConversion conversion;

  setUp(() {
    conversion = FbConversion();
  });

  test('BleDeviceState', () {
    const states = BleDeviceState.values;
    final converted = states.map(
      (state) => conversion.fromBleDeviceState(state),
    );
    expect(
      converted.map((state) => conversion.toBleDeviceState(state)).toList(),
      states,
    );
  });

  test('BleDevice', () {
    final device = FbBleDevice(
      fb.BluetoothDevice.fromProto(protos.BluetoothDevice(
        name: 'name',
        remoteId: 'id',
        type: protos.BluetoothDevice_Type.LE,
      )),
      conversion,
    );
    final converted = conversion.fromBleDevice(device);
    expect(conversion.toBleDevice(converted), device);
  });

  test('ScanResult', () {
    final device = FbBleDevice(
      fb.BluetoothDevice.fromProto(protos.BluetoothDevice(
        name: 'name',
        remoteId: 'id',
        type: protos.BluetoothDevice_Type.LE,
      )),
      conversion,
    );
    final scanResult = ScanResult(
      device: device,
      serviceData: {
        const Uuid('c6fa47ab-868a-40bc-ba46-39a79017037a'):
            Uint8List.fromList([1, 2, 3]),
        const Uuid('5b27b6ea-bd5f-4481-a249-9946b76e8026'):
            Uint8List.fromList([4, 5]),
      },
      serviceUuids: const [
        Uuid('458265d2-604d-40a1-ba1c-ba53f443f3f9'),
        Uuid('7108da7b-abc1-413e-be6d-be11ca409bc7'),
      ],
      rssi: 15,
    );
    final converted = conversion.fromScanResult(scanResult);
    expect(conversion.toScanResult(converted), scanResult);
  });

  test('Service', () {
    final converted = conversion.fromService(service);
    expect(conversion.toService(converted), service);
  });

  test('Characteristic', () {
    final converted = conversion.fromCharacteristic(characteristic);
    expect(conversion.toCharacteristic(converted), characteristic);
  });

  test('Descriptor', () {
    final converted = conversion.fromDescriptor(descriptor);
    expect(conversion.toDescriptor(converted), descriptor);
  });

  test('Uuid', () {
    const uuid = Uuid('12670607-b9ed-488e-acc7-6567c14ede00');
    final converted = conversion.fromUuid(uuid);
    expect(conversion.toUuid(converted), uuid);
  });
}
