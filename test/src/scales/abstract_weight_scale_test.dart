import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/abstract_weight_scale.dart';

@GenerateNiceMocks([MockSpec<BluetoothDevice>()])
import 'abstract_weight_scale_test.mocks.dart';

class TestAbstractWeightScale extends AbstractWeightScale {
  bool stabilized = false;
  Weight? Function(Uint8List) onDataHandler = ((data) => null);

  @override
  final Uuid characteristicUuid;

  @override
  final Uuid serviceUuid;

  TestAbstractWeightScale({
    required super.device,
    required this.serviceUuid,
    required this.characteristicUuid,
  });

  @override
  String get name => "name";

  @override
  String get manufacturer => "manufacturer";

  @override
  bool hasStabilized(Uint8List data) {
    return stabilized;
  }

  @override
  Weight? onData(Uint8List data) {
    return onDataHandler(data);
  }
}

void main() {
  const information = BleDeviceInformation(name: "name", id: "id");
  const serviceUuid = Uuid('5cc63afd-37f2-46d6-8467-f9c27eced9ca');
  const characteristicUuid = Uuid('7801bcaf-aa7a-45af-b4c3-baf205d89478');

  const characteristic = Characteristic(
    deviceId: 'id',
    serviceUuid: serviceUuid,
    uuid: characteristicUuid,
  );

  const service = Service(
    deviceId: 'id',
    uuid: serviceUuid,
    characteristics: [characteristic],
    includedServices: [],
    isPrimary: true,
  );

  const otherService = Service(
    deviceId: 'id',
    uuid: Uuid('5b9e28a2-c64b-45d0-99b6-2286a874ad92'),
    characteristics: [
      Characteristic(
        deviceId: 'id',
        serviceUuid: Uuid('5b9e28a2-c64b-45d0-99b6-2286a874ad92'),
        uuid: Uuid('2fd5b7ea-42bb-468b-892b-55fdda8bd805'),
      )
    ],
    includedServices: [],
    isPrimary: true,
  );

  final throwsWeightScaleException =
      throwsA(const TypeMatcher<WeightScaleException>());

  late TestAbstractWeightScale scale;
  late MockBleDevice device;
  late StreamController<Uint8List> controller;

  setUp(() {
    device = MockBleDevice();
    controller = StreamController();

    when(device.information).thenReturn(information);
    when(device.currentState)
        .thenAnswer((_) async => BleDeviceState.disconnected);
    when(device.connect(timeout: anyNamed('timeout'))).thenAnswer((_) async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.connected);
    });
    when(device.discoverServices())
        .thenAnswer((_) async => [service, otherService]);
    when(device.subscribeCharacteristic(any))
        .thenAnswer((_) async => controller.stream);
    when(device.disconnect()).thenAnswer((_) async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.disconnected);
    });

    scale = TestAbstractWeightScale(
      device: device,
      serviceUuid: serviceUuid,
      characteristicUuid: characteristicUuid,
    );
  });

  tearDown(() {
    controller.close();
  });

  group('information', () {
    test('Should be the same as the ble device', () {
      expect(scale.information, information);
    });
  });

  group('weight', () {
    setUp(() async {
      await scale.connect();
      scale.onDataHandler =
          (data) => Weight(data.first.toDouble(), WeightUnit.lbs);
    });

    tearDown(() async {
      await scale.disconnect();
    });

    test('Should be a broadcast stream', () {
      expect(scale.weight.isBroadcast, isTrue);
    });

    test(
        'Should emit the transformed data When the characteristic has a new value',
        () async {
      final weights = scale.weight.take(2).toList();

      controller.add(Uint8List.fromList([24]));
      controller.add(Uint8List.fromList([10]));

      expect(await weights, [
        const Weight(24, WeightUnit.lbs),
        const Weight(10, WeightUnit.lbs),
      ]);
    });

    test('Should not emit data When the transformed data is null', () async {
      final weight = scale.weight.first;

      scale.onDataHandler = (_) => null;
      controller.add(Uint8List.fromList([24, 12, 2, 3]));

      await Future.delayed(Duration.zero);
      scale.onDataHandler = (_) => const Weight(10, WeightUnit.kg);
      controller.add(Uint8List.fromList([1, 3, 4]));

      expect(await weight, const Weight(10, WeightUnit.kg));
    });

    test(
        'Should unsubscribe of the characteristic notification stream When disconnecting',
        () async {
      await scale.disconnect();
      expect(controller.hasListener, isFalse);
    });
  });

  group('currentWeight', () {
    setUp(() async {
      await scale.connect();
      scale.onDataHandler =
          (data) => Weight(data.first.toDouble(), WeightUnit.kg);
    });

    test('Should be 0 When no data was emitted so far', () {
      expect(scale.currentWeight, const Weight(0, WeightUnit.kg));
    });

    test('Should be the last emitted value', () async {
      controller.add(Uint8List.fromList([24]));
      controller.add(Uint8List.fromList([10]));
      await Future.delayed(Duration.zero);
      expect(scale.currentWeight, const Weight(10, WeightUnit.kg));
    });
  });

  group('isConnected', () {
    test('Should be true When is connected', () async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.connected);
      expect(await scale.isConnected, true);
    });

    test('Should be false When is connecting', () async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.connecting);
      expect(await scale.isConnected, false);
    });

    test('Should be false When is disconnecting', () async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.disconnecting);
      expect(await scale.isConnected, false);
    });

    test('Should be false When is disconnected', () async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.disconnected);
      expect(await scale.isConnected, false);
    });
  });

  group('currentState', () {
    test('Should return the same as the ble device', () async {
      for (final state in BleDeviceState.values) {
        when(device.currentState).thenAnswer((_) async => state);
        expect(await scale.currentState, state);
      }
    });
  });

  group('connected', () {
    test('Should emit the same values as the ble device', () async {
      const states = [true, false, true, false, true, false];
      when(device.connected).thenAnswer((_) => Stream.fromIterable(states));
      final result = scale.connected.take(states.length).toList();
      expect(await result, states);
    });
  });

  group('takeWeightMeasurement', () {
    late bool hasMeasured;
    late Future<Weight> weight;

    setUp(() async {
      await scale.connect();

      hasMeasured = false;
      weight = scale.takeWeightMeasurement();
      weight.whenComplete(() => hasMeasured = true);
      scale.onDataHandler = (_) => const Weight(23, WeightUnit.kg);
    });

    tearDown(() async {
      await scale.disconnect();
    });

    test('Should complete When has stabilized returns true', () async {
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);

      controller.add(Uint8List.fromList([1, 1]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);

      controller.add(Uint8List.fromList([18]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);

      scale.stabilized = true;

      controller.add(Uint8List.fromList([45]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isTrue);
      expect(await weight, const Weight(23, WeightUnit.kg));
    });

    test(
        'Should also complete When called multiple times during the same measurement',
        () async {
      controller.add(Uint8List.fromList([1, 1]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);

      var otherHasMeasured = false;
      final other = scale.takeWeightMeasurement();
      other.whenComplete(() => otherHasMeasured = true);

      controller.add(Uint8List.fromList([18]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);
      expect(otherHasMeasured, isFalse);

      scale.stabilized = true;

      controller.add(Uint8List.fromList([45]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isTrue);
      expect(otherHasMeasured, isTrue);
      expect(await weight, const Weight(23, WeightUnit.kg));
      expect(await other, const Weight(23, WeightUnit.kg));
    });

    test('Should work When taking a second measurement', () async {
      controller.add(Uint8List.fromList([1, 1]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);

      scale.stabilized = true;

      controller.add(Uint8List.fromList([36]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isTrue);
      expect(await weight, const Weight(23, WeightUnit.kg));

      scale.stabilized = false;

      weight = scale.takeWeightMeasurement();
      hasMeasured = false;
      weight.whenComplete(() => hasMeasured = true);

      controller.add(Uint8List.fromList([18]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isFalse);

      scale.stabilized = true;

      controller.add(Uint8List.fromList([45]));
      await Future.delayed(Duration.zero);
      expect(hasMeasured, isTrue);
      expect(await weight, const Weight(23, WeightUnit.kg));
    });
  });

  group('connect', () {
    const timeout = Duration(seconds: 5);
    const bleException = BleException("testing");
    const scaleException = WeightScaleException("testing");

    test('Should call connect on the ble device When called', () async {
      await scale.connect(timeout: timeout);
      verify(device.connect(timeout: timeout));
    });

    test('Should throw a weight scale exception When connection fails', () {
      when(device.connect(timeout: timeout)).thenThrow(bleException);
      expect(scale.connect(timeout: timeout), throwsA(scaleException));
    });

    test('Should call discover devices on the ble device When called',
        () async {
      await scale.connect(timeout: timeout);
      verify(device.discoverServices());
    });

    test('Should throw a weight scale exception When the discovery fails', () {
      when(device.discoverServices()).thenThrow(bleException);
      expect(scale.connect(timeout: timeout), throwsA(scaleException));
    });

    test('Should not call connect on ble device When is already connected',
        () async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.connected);
      await scale.connect(timeout: timeout);

      verifyNever(device.connect(timeout: timeout));
    });

    test('Should try to reenable the notification When is already connected',
        () async {
      when(device.currentState)
          .thenAnswer((_) async => BleDeviceState.connected);
      await scale.connect(timeout: timeout);

      verify(device.discoverServices());
      verify(device.subscribeCharacteristic(characteristic));
    });

    test(
        'Should throw a weight scale exception When the service is not present',
        () async {
      when(device.discoverServices()).thenAnswer((_) async => [otherService]);
      expect(scale.connect(), throwsWeightScaleException);
    });

    test('Should throw a weight scale exception When no service is not present',
        () async {
      when(device.discoverServices()).thenAnswer((_) async => []);
      expect(scale.connect(), throwsWeightScaleException);
    });

    test(
        'Should throw a weight scale exception When the characteristic is not present',
        () async {
      const wrong = Service(
        deviceId: 'id',
        uuid: serviceUuid,
        characteristics: [
          Characteristic(
            deviceId: 'id',
            serviceUuid: serviceUuid,
            uuid: Uuid('54f9c48d-439f-4187-b72d-d880748c2406'),
          ),
        ],
        includedServices: [],
        isPrimary: true,
      );

      when(device.discoverServices()).thenAnswer((_) async => [wrong]);
      expect(scale.connect(), throwsWeightScaleException);
    });

    test('Should enable notification on the characteristic When called',
        () async {
      await scale.connect();
      verify(device.subscribeCharacteristic(characteristic));
    });

    test('Should throw a weight scale exception When subscribing fails', () {
      when(device.subscribeCharacteristic(characteristic))
          .thenThrow(bleException);
      expect(scale.connect(), throwsA(scaleException));
    });
  });

  group('disconnect', () {
    test('Should call disconnect on the ble device When called', () async {
      await scale.connect();
      await scale.disconnect();
      verify(device.disconnect());
    });
  });
}
