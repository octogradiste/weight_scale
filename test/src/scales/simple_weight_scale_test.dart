import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/simple_weight_scale.dart';

import 'mi_scale_2_test.mocks.dart';

class FakeSimpleWeightScale extends SimpleWeightScale {
  FakeSimpleWeightScale({
    required BleDevice bleDevice,
    required WeightScaleUnit unit,
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
  }) : super(
          bleDevice: bleDevice,
          unit: unit,
          serviceUuid: serviceUuid,
          characteristicUuid: characteristicUuid,
        );

  Weight? Function(Uint8List) current = (value) {
    if (value.length == 1) {
      return Weight(value.first.toDouble(), WeightScaleUnit.KG);
    }
    return null;
  };

  @override
  String get name => "A fake simple weight scale.";

  @override
  Weight? Function(Uint8List p1) get onData => current;
}

void main() {
  late BleDevice bleDevice;
  late SimpleWeightScale scale;

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
    when((bleDevice as MockBleDevice).subscribeCharacteristic(any)).thenAnswer(
      (_) async => Stream.fromIterable([
        Uint8List.fromList([75]),
        Uint8List.fromList([0, 0, 0]),
        Uint8List.fromList([35]),
      ]),
    );
  }

  setUp(() {
    bleDevice = MockBleDevice();
    scale = FakeSimpleWeightScale(
      bleDevice: bleDevice,
      unit: WeightScaleUnit.KG,
      serviceUuid: _service,
      characteristicUuid: _characteristic,
    );
  });

  test('[weight] is a broadcast stream', () {
    expect(scale.weight.isBroadcast, isTrue);
  });

  test('unit is KG', () {
    expect(scale.unit, WeightScaleUnit.KG);
  });

  test('[state] calls the ble device', () {
    mockCorrectDevice();
    scale.state;
    verify(bleDevice.state);
  });

  test('[connect] calls [connect] on the ble device', () async {
    mockCorrectDevice();
    Duration timeout = const Duration(seconds: 15);
    await scale.connect(timeout: timeout);
    verify(bleDevice.connect(timeout: timeout));
  });

  test('[connect] calls [discoverDevices] on the ble device', () async {
    mockCorrectDevice();
    await scale.connect();
    verify(bleDevice.discoverServices());
  });

  test(
      'if [connect] on ble device throws a [BleOperationException], it gets re-thrown as WeightScaleException.',
      () {
    String msg = "test";
    mockCorrectDevice();
    when(bleDevice.connect()).thenThrow(BleException(msg));
    expect(
        () => scale.connect(),
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
      () => scale.connect(),
      throwsA(const TypeMatcher<WeightScaleException>()),
    );
  });

  test('if no services is not discoverd throws a [WeightScaleException]', () {
    when(bleDevice.connect()).thenAnswer((_) async {});
    when(bleDevice.discoverServices()).thenAnswer((_) async => List.empty());
    expect(scale.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
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
    expect(scale.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
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
    expect(scale.connect(), throwsA(const TypeMatcher<WeightScaleException>()));
  });

  test('[connect] sets notification on characteristic', () async {
    mockCorrectDevice();
    await scale.connect();
    verify(bleDevice.subscribeCharacteristic(characteristic));
  });

  test('before connecting [isConnected] is false', () {
    expect(scale.isConnected, isFalse);
  });

  test('after connecting [isConnected] is true', () async {
    mockCorrectDevice();
    await scale.connect();
    expect(scale.isConnected, isTrue);
  });

  test('initial weight is 0.0', () {
    expect(scale.currentWeight, 0.0);
  });

  test('after connecting weight emits 75 then 35', () async {
    mockCorrectDevice();
    expectLater(scale.weight, emitsInOrder([75.0, 35.0]));
    await scale.connect();
    await Future.delayed(Duration.zero);
    expect(scale.currentWeight, 35.0);
  });

  test('after disconnecting [isConnected] is false', () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenAnswer((_) async {});
    await scale.connect();
    await scale.disconnect();
    expect(scale.isConnected, isFalse);
  });

  test('[disconnect] calls [disconnect] on ble device', () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenAnswer((_) async {});
    await scale.connect();
    await scale.disconnect();
    verify(bleDevice.disconnect());
  });

  test('when ble device throws on [disconnect] it gets re-thrown', () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenThrow(const BleException("test"));
    await scale.connect();
    expect(
        scale.disconnect(), throwsA(const TypeMatcher<WeightScaleException>()));
  });

  test('when ble device throws on [disconnect] then [isConnected] is false',
      () async {
    mockCorrectDevice();
    when(bleDevice.disconnect()).thenThrow(const BleException("test"));
    await scale.connect();
    try {
      await scale.disconnect();
    } catch (_) {}
    expect(scale.isConnected, isFalse);
  });

  test('when reconnecting to the same scale, does not send weight twice',
      () async {
    mockCorrectDevice();

    StreamController<Uint8List> controller = StreamController.broadcast();

    when((bleDevice as MockBleDevice).subscribeCharacteristic(any))
        .thenAnswer((_) async => controller.stream);

    var weights = scale.weight.takeWhile((element) => element != 1).toList();
    await scale.connect();
    await scale.disconnect();
    await scale.connect();
    controller.add(Uint8List.fromList([8]));
    controller.add(Uint8List.fromList([3]));
    controller.add(Uint8List.fromList([1]));
    controller.close();
    expect(await weights, containsAllInOrder([8, 3]));
    expect((await weights).length, 2);
  });
}
