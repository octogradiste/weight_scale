import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/climbro.dart';

import 'mi_scale_2_test.mocks.dart';

void main() {
  late MockBleDevice bleDevice;
  late Climbro climbro;

  const String deviceId = "id";
  const Uuid _service = Uuid("49535343-fe7d-4ae5-8fa9-9fafd205e455");
  const Uuid _characteristic = Uuid("49535343-1e4d-4bd9-ba61-23c647249616");

  const Characteristic characteristic = Characteristic(
    deviceId: deviceId,
    serviceUuid: _service,
    uuid: _characteristic,
  );

  void mockCorrectDevice() {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverServices()).thenAnswer(
      (_) async => [
        const Service(
          deviceId: deviceId,
          uuid: _service,
          characteristics: [characteristic],
        )
      ],
    );
    when(bleDevice.state).thenAnswer((_) => const Stream.empty());
    when(bleDevice.subscribeCharacteristic(any)).thenAnswer(
      (_) async => Stream.fromIterable([
        Uint8List.fromList([75]),
        Uint8List.fromList([0, 0, 0]),
        Uint8List.fromList([35]),
      ]),
    );
  }

  setUp(() {
    bleDevice = MockBleDevice();
    climbro = Climbro(bleDevice: bleDevice);
  });

  test('unit is KG', () {
    expect(climbro.unit, WeightScaleUnit.KG);
  });

  test('[state] calls the ble device', () {
    mockCorrectDevice();
    climbro.state;
    verify(bleDevice.state);
  });

  test('[connect] calls [connect] on the ble device', () async {
    mockCorrectDevice();
    Duration timeout = const Duration(seconds: 15);
    await climbro.connect(timeout: timeout);
    verify(bleDevice.connect(timeout: timeout));
  });

  test('[connect] calls [discoverDevices] on the ble device', () async {
    mockCorrectDevice();
    await climbro.connect();
    verify(bleDevice.discoverServices());
  });

  test(
      'if [connect] on ble device throws a [BleOperationException], it gets re-thrown as WeightScaleException.',
      () {
    String msg = "test";
    mockCorrectDevice();
    when(bleDevice.connect()).thenThrow(BleException(msg));
    expect(
        climbro.connect(),
        throwsA(allOf(
          const TypeMatcher<WeightScaleException>(),
          predicate((WeightScaleException e) => e.message == msg),
        )));
  });

  test(
      'if [connect] on ble device throws a [TimeoutException], it gets re-thrown as WeightScaleException.',
      () {
    mockCorrectDevice();
    when(bleDevice.connect()).thenThrow(TimeoutException("test"));
    expect(
        climbro.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
  });

  test('if no services is not discoverd throws a [WeightScaleException]', () {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverServices()).thenAnswer((_) async => List.empty());
    expect(
        climbro.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
  });

  test(
      'if no matching services is not discoverd throws a [WeightScaleException]',
      () async {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverServices()).thenAnswer(
      (_) async => [
        const Service(
          deviceId: deviceId,
          uuid: Uuid("00000000-0000-0000-0000-000000000000"),
          characteristics: [
            Characteristic(
              deviceId: deviceId,
              serviceUuid: Uuid("00000000-0000-0000-0000-000000000000"),
              uuid: _characteristic,
            ),
          ],
        ),
      ],
    );
    expect(
        climbro.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
  });

  test('if the characteristic is not discoverd throws a [WeightScaleException]',
      () {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverServices()).thenAnswer(
      (_) async => [
        const Service(
          deviceId: deviceId,
          uuid: _service,
          characteristics: [
            Characteristic(
              deviceId: deviceId,
              serviceUuid: _service,
              uuid: Uuid("00000000-0000-0000-0000-000000000000"),
            ),
          ],
        ),
      ],
    );
    expect(
        climbro.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
  });

  test('[connect] sets notification on characteristic', () async {
    mockCorrectDevice();
    await climbro.connect();
    verify(bleDevice.subscribeCharacteristic(characteristic));
  });

  test('before connecting [isConnected] is false', () {
    expect(climbro.isConnected, isFalse);
  });

  test('after connecting [isConnected] is true', () async {
    mockCorrectDevice();
    await climbro.connect();
    expect(climbro.isConnected, isTrue);
  });

  test('initial weight is 0.0', () {
    expect(climbro.currentWeight, 0.0);
  });

  test('after connecting weight emits 75 then 35', () async {
    mockCorrectDevice();
    expectLater(climbro.weight, emitsInOrder([75.0, 35.0]));
    await climbro.connect();
    await Future.delayed(const Duration(milliseconds: 2));
    expect(climbro.currentWeight, 35.0);
  });

  test('after disconnecting [isConnected] is false', () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenAnswer((_) async {});
    await climbro.connect();
    await climbro.disconnect();
    expect(climbro.isConnected, isFalse);
  });

  test('[disconnect] calls [disconnect] on ble device', () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenAnswer((_) async {});
    await climbro.connect();
    await climbro.disconnect();
    verify(bleDevice.disconnect());
  });

  test(
      'when ble device throws on [disconnect] it gets re-thrown and [isConnected] is false',
      () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenThrow(const BleException("test"));
    await climbro.connect();
    expect(climbro.disconnect(),
        throwsA(const TypeMatcher<WeightScaleException>()));
    await Future.delayed(
        const Duration(milliseconds: 2)); // Wait for disconnect to finish.
    expect(climbro.isConnected, isFalse);
  });
}
