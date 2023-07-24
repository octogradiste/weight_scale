import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/src/ble/backend/flutter_blue_plus_converter.dart';
import 'package:weight_scale/src/ble/model.dart';

void main() {
  late FlutterBluePlusConverter converter;

  setUp(() {
    converter = FlutterBluePlusConverter();
  });

  test('BleDeviceState', () {
    expect(
      converter.toBleDeviceState(blue.BluetoothConnectionState.connecting),
      BleDeviceState.connecting,
    );
    expect(
      converter.toBleDeviceState(blue.BluetoothConnectionState.connected),
      BleDeviceState.connected,
    );
    expect(
      converter.toBleDeviceState(blue.BluetoothConnectionState.disconnecting),
      BleDeviceState.disconnecting,
    );
    expect(
      converter.toBleDeviceState(blue.BluetoothConnectionState.disconnected),
      BleDeviceState.disconnected,
    );
  });

  test('ScanResult', () {
    final expected = ScanResult(
      deviceInformation: const BleDeviceInformation(name: 'name', id: 'id'),
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
      txPowerLevel: 5,
    );

    final actual =
        converter.toScanResult(blue.ScanResult.fromProto(blue.BmScanResult(
      advertisementData: blue.BmAdvertisementData(
        localName: 'name',
        txPowerLevel: 5,
        connectable: true,
        manufacturerData: {},
        serviceUuids: [
          '458265d2-604d-40a1-ba1c-ba53f443f3f9',
          '7108da7b-abc1-413e-be6d-be11ca409bc7',
        ],
        serviceData: {
          'c6fa47ab-868a-40bc-ba46-39a79017037a': Uint8List.fromList([1, 2, 3]),
          '5b27b6ea-bd5f-4481-a249-9946b76e8026': Uint8List.fromList([4, 5]),
        },
      ),
      device: blue.BmBluetoothDevice(
        remoteId: 'id',
        localName: 'name',
        type: blue.BmBluetoothSpecEnum.le,
      ),
      rssi: 15,
    )));
    expect(actual, expected);
  });

  test('Uuid', () {
    const uuid = '12670607-b9ed-488e-acc7-6567c14ede00';
    expect(converter.toUuid(blue.Guid(uuid)), const Uuid(uuid));
  });
}
