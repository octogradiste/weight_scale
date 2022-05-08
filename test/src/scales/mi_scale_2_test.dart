import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

import 'mi_scale_2_test.mocks.dart';

Service createMiScale2Service() {
  String deviceId = "00:00:00:00:00:00";
  Uuid serviceUuid = const Uuid("0000181b-0000-1000-8000-00805f9b34fb");
  Uuid characteristicUuid = const Uuid("00002a9c-0000-1000-8000-00805f9b34fb");
  return Service(
    deviceId: deviceId,
    uuid: serviceUuid,
    characteristics: [
      Characteristic(
        deviceId: deviceId,
        serviceUuid: serviceUuid,
        uuid: characteristicUuid,
        descriptors: const [],
      )
    ],
    includedServices: const [],
    isPrimary: true,
  );
}

const Uuid customService = Uuid("00001530-0000-3512-2118-0009af100700");
const Uuid scaleConfiguration = Uuid("00001542-0000-3512-2118-0009af100700");

@GenerateMocks([BleDevice])
void main() {
  group('MiScale2', () {
    late MiScale2 miScale2;
    late BleDevice bleDevice;
    late Service service;
    late Duration timeout;

    setUp(() {
      bleDevice = MockBleDevice();
      when(bleDevice.information).thenReturn(
        const BleDeviceInformation(name: "MIBFS", id: "00:00:00:00:00:00"),
      );
      miScale2 = MiScale2(bleDevice: bleDevice, unit: WeightUnit.unknown);

      service = createMiScale2Service();
      timeout = const Duration(seconds: 10);
      when(bleDevice.connect(timeout: timeout)).thenAnswer((_) async {});
      when(bleDevice.discoverServices()).thenAnswer((_) async => [service]);
      when(bleDevice.state).thenAnswer((_) => const Stream.empty());
      when(bleDevice.subscribeCharacteristic(service.characteristics.first))
          .thenAnswer((_) async => Stream.fromIterable([
                Uint8List.fromList(
                  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 216, 54],
                ),
              ]));
      when(bleDevice.disconnect()).thenAnswer((_) async {});
    });

    test('default [isConnected] is false', () {
      expect(miScale2.isConnected, isFalse);
    });

    test('default [unit] same as in constructor', () {
      expect(miScale2.unit, WeightUnit.unknown);
    });

    test('[state] calls the ble device', () {
      miScale2.state;
      verify(bleDevice.state);
    });

    test('[connect] makes the correct calls to [bleDevice]', () async {
      await miScale2.connect(timeout: timeout);
      verify(bleDevice.connect(timeout: timeout));
      verify(bleDevice.discoverServices());
      verify(bleDevice.subscribeCharacteristic(service.characteristics.first));
    });

    test('after connecting [isConnected] is true', () async {
      await miScale2.connect(timeout: timeout);
      expect(miScale2.isConnected, isTrue);
    });

    test('after connecting [weight] streams the correct values', () async {
      await miScale2.connect(timeout: timeout);
      double weight = await miScale2.weight.take(1).first;
      expect(weight, equals(140.4));
    });

    test('after connecting [unit] is set by data send from the scale, LBS',
        () async {
      await miScale2.connect(timeout: timeout);
      await miScale2.weight.take(1).first;
      // Because bit number seven is set to 1, the unit is LBS.
      expect(miScale2.unit, WeightUnit.lbs);
    });

    test('after connecting [unit] is set by data send from the scale, KG',
        () async {
      when(bleDevice.subscribeCharacteristic(service.characteristics.first))
          .thenAnswer((_) async => Stream.fromIterable([
                Uint8List.fromList(
                  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 216, 54],
                ),
              ]));
      await miScale2.connect(timeout: timeout);
      double weight = await miScale2.weight.take(1).first;
      // Because bit number seven and nine are set 0, the unit is KG.
      expect(miScale2.unit, WeightUnit.kg);
      expect(weight, 70.2);
    });

    test('after disconnecting [isConnected] is false again', () async {
      await miScale2.connect(timeout: timeout);
      await miScale2.disconnect();
      expect(miScale2.isConnected, isFalse);
    });

    test('[disconnect] makes correct call to [bleDevice]', () async {
      await miScale2.connect(timeout: timeout);
      await miScale2.disconnect();
      verify(bleDevice.disconnect());
    });

    test('[clearCache] sends 0x06 0x12 0x00 0x00.', () async {
      await miScale2.clearCache();
      Characteristic characteristic = Characteristic(
        deviceId: bleDevice.information.id,
        serviceUuid: customService,
        uuid: scaleConfiguration,
      );
      verify(bleDevice.writeCharacteristic(
        characteristic,
        value: Uint8List.fromList([06, 18, 0, 0]),
      ));
    });

    test('[setUnit] KG sends 0x06 0x04 0x00 0x00.', () async {
      await miScale2.setUnit(WeightUnit.kg);
      Characteristic characteristic = Characteristic(
        deviceId: bleDevice.information.id,
        serviceUuid: customService,
        uuid: scaleConfiguration,
      );
      verify(bleDevice.writeCharacteristic(
        characteristic,
        value: Uint8List.fromList([6, 4, 0, 0]),
        response: false,
      ));
    });

    test('[setUnit] LBS sends 0x06 0x04 0x00 0x01.', () async {
      await miScale2.setUnit(WeightUnit.lbs);
      Characteristic characteristic = Characteristic(
        deviceId: bleDevice.information.id,
        serviceUuid: customService,
        uuid: scaleConfiguration,
      );
      verify(bleDevice.writeCharacteristic(
        characteristic,
        value: Uint8List.fromList([6, 4, 0, 1]),
        response: false,
      ));
    });

    test('[setUnit] to UNKNOWN makes no writes.', () async {
      await miScale2.setUnit(WeightUnit.unknown);
      verifyNever((bleDevice as MockBleDevice).writeCharacteristic(any));
    });
  });
}
