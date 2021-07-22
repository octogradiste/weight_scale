import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/backend/flutter_blue_convert.dart';
import 'package:weight_scale/src/backend/flutter_blue_operations.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/uuid.dart';

import 'flutter_blue_operations_test.mocks.dart';

BleDevice createFakeBleDevice(BleOperations operations) {
  return BleDevice(
    id: "id",
    name: "name",
    operations: operations,
  );
}

Characteristic createFakeCharacteristic() {
  return Characteristic(
    deviceId: "deviceId",
    serviceUuid: Uuid("serviceUuid"),
    uuid: Uuid("uuid"),
  );
}

@GenerateMocks([
  FlutterBlueConvert,
  fb.FlutterBlue,
  fb.BluetoothDevice,
  fb.BluetoothCharacteristic,
])
void main() {
  group('verify fb calls', () {
    late fb.FlutterBlue fbInstance;
    late fb.BluetoothDevice fbDevice;
    late fb.BluetoothCharacteristic fbCharacteristic;
    late FlutterBlueOperations fbOperations;
    late FlutterBlueConvert fbConvert;
    late BleDevice bleDevice;
    late Characteristic characteristic;

    setUp(() {
      fbInstance = MockFlutterBlue();
      fbDevice = MockBluetoothDevice();
      fbCharacteristic = MockBluetoothCharacteristic();
      fbConvert = MockFlutterBlueConvert();
      fbOperations = FlutterBlueOperations(fbInstance, fbConvert);
      bleDevice = createFakeBleDevice(fbOperations);
      characteristic = createFakeCharacteristic();
    });

    test('start scan', () async {
      Duration timeout = Duration(seconds: 10);
      when(fbInstance.startScan(withServices: const [], timeout: timeout))
          .thenAnswer((_) async {});
      await fbOperations.startScan(timeout: timeout, withServices: const []);
      verify(fbInstance.startScan(withServices: const [], timeout: timeout));
    });

    test('stop scan', () async {
      when(fbInstance.stopScan()).thenAnswer((_) async {});
      await fbOperations.stopScan();
      verify(fbInstance.stopScan());
    });

    test('connect', () async {
      Duration timeout = Duration(seconds: 10);
      when(fbConvert.toBluetoothDevice(bleDevice)).thenReturn(fbDevice);
      when(fbDevice.connect(timeout: timeout)).thenAnswer((_) async {});
      await fbOperations.connect(device: bleDevice, timeout: timeout);
      verify(fbDevice.connect(timeout: timeout));
    });

    test('disconnect', () async {
      when(fbConvert.toBluetoothDevice(bleDevice)).thenReturn(fbDevice);
      when(fbDevice.disconnect()).thenAnswer((_) async {});
      await fbOperations.disconnect(device: bleDevice);
      verify(fbDevice.disconnect());
    });

    test('discover service', () async {
      when(fbConvert.toBluetoothDevice(bleDevice)).thenReturn(fbDevice);
      when(fbDevice.discoverServices()).thenAnswer((_) async => List.empty());
      await fbOperations.discoverService(device: bleDevice);
      verify(fbDevice.discoverServices());
    });

    test('read characteristic', () async {
      when(fbConvert.toBluetoothCharacteristic(characteristic))
          .thenReturn(fbCharacteristic);
      when(fbCharacteristic.read()).thenAnswer((_) async => List.empty());
      await fbOperations.readCharacteristic(characteristic: characteristic);
      verify(fbCharacteristic.read());
    });

    test('write characteristic', () async {
      when(fbConvert.toBluetoothCharacteristic(characteristic))
          .thenReturn(fbCharacteristic);
      Uint8List value = Uint8List(0);
      when(fbCharacteristic.write(value, withoutResponse: true))
          .thenAnswer((_) async {});
      await fbOperations.writeCharacteristic(
        characteristic: characteristic,
        value: value,
        response: false,
      );
      verify(fbCharacteristic.write(value, withoutResponse: true));
    });

    test('subscribe characteristic', () async {
      when(fbConvert.toBluetoothCharacteristic(characteristic))
          .thenReturn(fbCharacteristic);
      when(fbCharacteristic.setNotifyValue(true)).thenAnswer((_) async => true);
      when(fbCharacteristic.value).thenAnswer((_) => Stream.empty());
      await fbOperations.subscribeCharacteristic(
          characteristic: characteristic);
      verify(fbCharacteristic.setNotifyValue(true));
      verify(fbCharacteristic.value);
    });
  });

  group('throwing ble excepitions', () {
    late fb.FlutterBlue fbInstance;
    late fb.BluetoothDevice fbDevice;
    late fb.BluetoothCharacteristic fbCharacteristic;
    late FlutterBlueOperations fbOperations;
    late FlutterBlueConvert fbConvert;
    late BleDevice bleDevice;
    late Characteristic characteristic;

    setUp(() {
      fbInstance = MockFlutterBlue();
      fbDevice = MockBluetoothDevice();
      fbCharacteristic = MockBluetoothCharacteristic();
      fbConvert = MockFlutterBlueConvert();
      fbOperations = FlutterBlueOperations(fbInstance, fbConvert);
      bleDevice = createFakeBleDevice(fbOperations);
      characteristic = createFakeCharacteristic();
    });

    test('start scan', () {
      Duration timeout = Duration(seconds: 10);
      List<Uuid> services = [
        Uuid("6989dc2f-07b3-4c21-a8ed-1d4fa8c512e2"),
        Uuid("aab74c28-bab1-4320-9f4a-0a27ad852e26"),
      ];
      List<fb.Guid> withServices =
          services.map((e) => fb.Guid(e.uuid)).toList();
      when(fbInstance.startScan(withServices: withServices, timeout: timeout))
          .thenThrow(Exception());
      when(fbConvert.toGuid(services[0])).thenAnswer((_) => withServices[0]);
      when(fbConvert.toGuid(services[1])).thenAnswer((_) => withServices[1]);
      when(fbOperations.startScan(timeout: timeout, withServices: services))
          .thenAnswer((_) async {});
      expect(fbOperations.startScan(timeout: timeout, withServices: services),
          throwsA(TypeMatcher<BleOperationException>()));
    });

    test('stop scan', () {
      when(fbInstance.stopScan()).thenThrow(Exception());
      expect(fbOperations.stopScan(),
          throwsA(TypeMatcher<BleOperationException>()));
    });

    test('connect', () {
      Duration timeout = Duration(seconds: 10);
      when(fbConvert.toBluetoothDevice(bleDevice)).thenReturn(fbDevice);
      when(fbDevice.connect(timeout: timeout)).thenThrow(Exception());
      expect(fbOperations.connect(device: bleDevice, timeout: timeout),
          throwsA(TypeMatcher<BleOperationException>()));
    });

    test('disconnect', () {
      when(fbConvert.toBluetoothDevice(bleDevice)).thenReturn(fbDevice);
      when(fbDevice.disconnect()).thenThrow(Exception());
      expect(fbOperations.disconnect(device: bleDevice),
          throwsA(TypeMatcher<BleOperationException>()));
    });

    test('discover service', () {
      when(fbConvert.toBluetoothDevice(bleDevice)).thenReturn(fbDevice);
      when(fbDevice.discoverServices()).thenThrow(Exception());
      expect(fbOperations.discoverService(device: bleDevice),
          throwsA(TypeMatcher<BleOperationException>()));
    });

    test('write characteristic', () {
      when(fbConvert.toBluetoothCharacteristic(characteristic))
          .thenReturn(fbCharacteristic);
      Uint8List value = Uint8List(0);
      when(fbCharacteristic.write(value, withoutResponse: true))
          .thenThrow(Exception());
      expect(
        fbOperations.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: false,
        ),
        throwsA(TypeMatcher<BleOperationException>()),
      );
    });

    test('read characteristic', () {
      when(fbConvert.toBluetoothCharacteristic(characteristic))
          .thenReturn(fbCharacteristic);
      when(fbCharacteristic.read()).thenThrow(Exception());
      expect(fbOperations.readCharacteristic(characteristic: characteristic),
          throwsA(TypeMatcher<BleOperationException>()));
    });

    test('subscribe characteristic', () {
      when(fbCharacteristic.setNotifyValue(true)).thenAnswer((_) async => true);
      when(fbCharacteristic.value).thenThrow(Exception());
      when(fbConvert.toBluetoothCharacteristic(characteristic))
          .thenReturn(fbCharacteristic);
      expect(
        fbOperations.subscribeCharacteristic(characteristic: characteristic),
        throwsA(TypeMatcher<BleOperationException>()),
      );
    });
  });
}
