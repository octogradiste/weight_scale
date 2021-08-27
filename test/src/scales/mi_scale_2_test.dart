import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/src/scales/mi_sacle_2.dart';

import 'mi_scale_2_test.mocks.dart';

Service createMiScale2Service() {
  String deviceId = "00:00:00:00:00:00";
  Uuid serviceUuid = Uuid("0000181b-0000-1000-8000-00805f9b34fb");
  Uuid characteristicUuid = Uuid("00002a9c-0000-1000-8000-00805f9b34fb");
  return Service(deviceId: deviceId, uuid: serviceUuid, characteristics: [
    Characteristic(
      deviceId: deviceId,
      serviceUuid: serviceUuid,
      uuid: characteristicUuid,
      descriptors: [],
    )
  ]);
}

@GenerateMocks([BleDevice])
void main() {
  group('MiSacle2', () {
    group('connection', () {
      late MiScale2 miScale2;
      late BleDevice bleDevice;
      late Service service;
      late Duration timeout;

      setUp(() {
        bleDevice = MockBleDevice();
        miScale2 = MiScale2(bleDevice: bleDevice, unit: WeightScaleUnit.UNKOWN);

        service = createMiScale2Service();
        timeout = Duration(seconds: 10);
        when(bleDevice.connect(timeout: timeout)).thenAnswer((_) async {});
        when(bleDevice.discoverService()).thenAnswer((_) async => [service]);
        when(bleDevice.subscribeCharacteristic(
          characteristic: service.characteristics.first,
        )).thenAnswer((_) async => Stream.fromIterable([
              Uint8List.fromList(
                [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 216, 54, 0, 0, 0, 0, 0],
              ),
            ]));
        when(bleDevice.disconnect()).thenAnswer((_) async {});
      });

      test('default [isConnected] is false', () {
        expect(miScale2.isConnected, isFalse);
      });

      test('default [unit] same as in constructor', () {
        expect(miScale2.unit, WeightScaleUnit.UNKOWN);
      });

      test('[connect] makes the correct calls to [bleDevice]', () async {
        await miScale2.connect(timeout: timeout);
        verify(bleDevice.connect(timeout: timeout));
        verify(bleDevice.discoverService());
        verify(bleDevice.subscribeCharacteristic(
          characteristic: service.characteristics.first,
        ));
      });

      test('after connecting [isConnected] is true', () async {
        await miScale2.connect(timeout: timeout);
        expect(miScale2.isConnected, isTrue);
      });

      test('after connecting [weight] streams the correct values', () async {
        await miScale2.connect(timeout: timeout);
        double weight = await miScale2.weight.take(1).first;
        expect(weight, equals(70.2));
      });

      test('after connecting [unit] is set by data send from the scale, LBS',
          () async {
        await miScale2.connect(timeout: timeout);
        await miScale2.weight.take(1).first;
        // Because bit number seven is set to 1, the unit is LBS.
        expect(miScale2.unit, WeightScaleUnit.LBS);
      });

      test('after connecting [unit] is set by data send from the scale, KG',
          () async {
        when(bleDevice.subscribeCharacteristic(
          characteristic: service.characteristics.first,
        )).thenAnswer((_) async => Stream.fromIterable([
              Uint8List.fromList(
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 216, 54, 0, 0, 0, 0, 0],
              ),
            ]));
        await miScale2.connect(timeout: timeout);
        await miScale2.weight.take(1).first;
        // Because bit number seven and nine are set 0, the unit is KG.
        expect(miScale2.unit, WeightScaleUnit.KG);
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
    });
  });
}
