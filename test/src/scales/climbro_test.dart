import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/climbro.dart';

import 'mi_scale_2_test.mocks.dart';

void main() {
  late BleDevice bleDevice;
  late Climbro climbro;

  final String deviceId = "id";
  final Uuid _service = Uuid("49535343-FE7D-4AE5-8FA9-9FAFD205E455");
  final Uuid _characteristic = Uuid("49535343-1E4D-4BD9-BA61-23C647249616");

  final Characteristic characteristic = Characteristic(
    deviceId: deviceId,
    serviceUuid: _service,
    uuid: _characteristic,
  );

  void mockCorrectDevice() {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverService()).thenAnswer(
      (_) async => [
        Service(
          deviceId: deviceId,
          uuid: _service,
          characteristics: [characteristic],
        )
      ],
    );
    when((bleDevice as MockBleDevice).subscribeCharacteristic(
      characteristic: anyNamed("characteristic"),
    )).thenAnswer(
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

  test('[connect] calls [connect] on the ble device', () async {
    mockCorrectDevice();
    Duration timeout = Duration(seconds: 15);
    await climbro.connect(timeout: timeout);
    verify(bleDevice.connect(timeout: timeout));
  });

  test('[connect] calls [discoverDevices] on the ble device', () async {
    mockCorrectDevice();
    await climbro.connect();
    verify(bleDevice.discoverService());
  });

  test(
      'if [connect] on ble device throws a [BleOperationException], it gets re-thrown as WeightScaleException.',
      () {
    String msg = "test";
    when(bleDevice.connect()).thenThrow(BleOperationException(msg));
    expect(
        climbro.connect(),
        throwsA(allOf(
          TypeMatcher<WeightScaleException>(),
          predicate((WeightScaleException e) => e.message == msg),
        )));
  });

  test(
      'if [connect] on ble device throws a [TimeoutException], it gets re-thrown as WeightScaleException.',
      () {
    when(bleDevice.connect()).thenThrow(TimeoutException("test"));
    expect(climbro.connect(), throwsA(TypeMatcher<WeightScaleException>()));
  });

  test('if no services is not discoverd throws a [WeightScaleException]', () {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverService()).thenAnswer((_) async => List.empty());
    expect(climbro.connect(), throwsA(TypeMatcher<WeightScaleException>()));
  });

  test(
      'if no matching services is not discoverd throws a [WeightScaleException]',
      () async {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverService()).thenAnswer(
      (_) async => [
        Service(
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
    expect(climbro.connect(), throwsA(TypeMatcher<WeightScaleException>()));
  });

  test('if the characteristic is not discoverd throws a [WeightScaleException]',
      () {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverService()).thenAnswer(
      (_) async => [
        Service(
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
    expect(climbro.connect(), throwsA(TypeMatcher<WeightScaleException>()));
  });

  test('[connect] sets notification on characteristic', () async {
    mockCorrectDevice();
    await climbro.connect();
    verify(bleDevice.subscribeCharacteristic(characteristic: characteristic));
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
    await Future.delayed(Duration.zero);
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
    when(bleDevice.disconnect()).thenThrow(BleOperationException("test"));
    await climbro.connect();
    expect(climbro.disconnect(), throwsA(TypeMatcher<WeightScaleException>()));
    expect(climbro.isConnected, isFalse);
  });
}
