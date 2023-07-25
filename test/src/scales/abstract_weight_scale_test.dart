import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/backend/flutter_blue_plus_converter.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/scales/abstract_weight_scale.dart';

@GenerateNiceMocks([
  MockSpec<blue.BluetoothDevice>(),
  MockSpec<blue.BluetoothService>(),
  MockSpec<blue.BluetoothCharacteristic>(),
])
import 'abstract_weight_scale_test.mocks.dart';

class FakeAbstractWeightScale extends AbstractWeightScale {
  bool stabilized = false;
  Weight? Function(Uint8List) onDataHandler = ((data) => null);

  @override
  final Uuid characteristicUuid;

  @override
  final Uuid serviceUuid;

  FakeAbstractWeightScale({
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
  const timeout = Duration(seconds: 5);
  const information = BleDeviceInformation(name: 'name', id: 'id');
  const serviceUuid = Uuid('5cc63afd-37f2-46d6-8467-f9c27eced9ca');
  const characteristicUuid = Uuid('7801bcaf-aa7a-45af-b4c3-baf205d89478');

  // final characteristic = blue.BmBluetoothCharacteristic(
  //   remoteId: 'id',
  //   characteristicUuid: blue.Guid(characteristicUuid.uuid),
  //   serviceUuid: blue.Guid(serviceUuid.uuid),
  //   secondaryServiceUuid: null,
  //   descriptors: [],
  //   properties: blue.BmCharacteristicProperties.fromMap({}),
  //   value: [],
  // );

  // final service = blue.BluetoothService.fromProto(
  //   blue.BmBluetoothService(
  //     remoteId: 'id',
  //     serviceUuid: blue.Guid(serviceUuid.uuid),
  //     isPrimary: true,
  //     characteristics: [characteristic],
  //     includedServices: [],
  //   ),
  // );

  final otherCharacteristic = blue.BmBluetoothCharacteristic(
    remoteId: 'id',
    characteristicUuid: blue.Guid('2fd5b7ea-42bb-468b-892b-55fdda8bd805'),
    serviceUuid: blue.Guid('5b9e28a2-c64b-45d0-99b6-2286a874ad92'),
    secondaryServiceUuid: null,
    descriptors: [],
    properties: blue.BmCharacteristicProperties.fromMap({}),
    value: [],
  );

  final otherService = blue.BluetoothService.fromProto(
    blue.BmBluetoothService(
      remoteId: 'id',
      serviceUuid: blue.Guid('5b9e28a2-c64b-45d0-99b6-2286a874ad92'),
      isPrimary: true,
      characteristics: [otherCharacteristic],
      includedServices: [],
    ),
  );

  final throwsWeightScaleException =
      throwsA(const TypeMatcher<WeightScaleException>());

  late FakeAbstractWeightScale scale;
  late StreamController<List<int>> controller;
  late MockBluetoothDevice device;
  late MockBluetoothService service;
  late MockBluetoothCharacteristic characteristic;

  Future<T> throwException<T>(_) async {
    throw Exception();
  }

  void setDeviceState(blue.BluetoothConnectionState state) {
    when(device.connectionState).thenAnswer(
      (_) => Stream.value(state),
    );
  }

  Future<void> flushMicrotasks() async {
    await Future.delayed(Duration.zero);
  }

  setUp(() {
    controller = StreamController.broadcast();
    device = MockBluetoothDevice();
    characteristic = MockBluetoothCharacteristic();
    service = MockBluetoothService();

    when(characteristic.characteristicUuid)
        .thenReturn(blue.Guid(characteristicUuid.uuid));
    when(characteristic.setNotifyValue(any)).thenAnswer((_) async => true);
    when(characteristic.lastValueStream).thenAnswer((_) => controller.stream);

    when(service.serviceUuid).thenReturn(blue.Guid(serviceUuid.uuid));
    when(service.characteristics).thenReturn([characteristic]);

    when(device.remoteId).thenReturn(const blue.DeviceIdentifier('id'));
    when(device.localName).thenReturn('name');
    setDeviceState(blue.BluetoothConnectionState.disconnected);
    when(device.discoverServices())
        .thenAnswer((_) async => [service, otherService]);

    scale = FakeAbstractWeightScale(
      device: device,
      serviceUuid: serviceUuid,
      characteristicUuid: characteristicUuid,
    );
  });

//   tearDown(() {
//     controller.close();
//   });

  group('information', () {
    test('Should be the same as the bluetooth device', () {
      expect(scale.information, information);
    });
  });

  group('connect', () {
    test('Should call connect on the ble device When called', () async {
      await scale.connect(timeout: timeout);
      verify(device.connect(timeout: timeout)).called(1);
    });

    test('Should not call connect on ble device When already connected',
        () async {
      setDeviceState(blue.BluetoothConnectionState.connected);
      await scale.connect(timeout: timeout);
      verifyNever(device.connect(timeout: timeout));
    });

    test('Should throw a weight scale exception When connection fails', () {
      when(device.connect(timeout: timeout)).thenAnswer(throwException);
      expect(scale.connect(timeout: timeout), throwsWeightScaleException);
    });

    test('Should discover services When called', () async {
      await scale.connect(timeout: timeout);
      verify(device.discoverServices()).called(1);
    });

    test('Should throw a weight scale exception When discovery fails', () {
      when(device.discoverServices()).thenAnswer(throwException);
      expect(scale.connect(timeout: timeout), throwsWeightScaleException);
    });

    test('Should throw a weight scale exception When cannot find service', () {
      when(device.discoverServices()).thenAnswer((_) async => [otherService]);
      expect(scale.connect(timeout: timeout), throwsWeightScaleException);
    });

    test('Should throw a exception When cannot find characteristic', () {
      final wrong = blue.BluetoothService.fromProto(
        blue.BmBluetoothService(
          remoteId: 'id',
          serviceUuid: blue.Guid(serviceUuid.uuid),
          isPrimary: true,
          characteristics: [otherCharacteristic],
          includedServices: [],
        ),
      );
      when(device.discoverServices()).thenAnswer((_) async => [wrong]);
      expect(scale.connect(timeout: timeout), throwsWeightScaleException);
    });

    test('Should enable notification on the characteristic When called',
        () async {
      await scale.connect();
      verify(characteristic.setNotifyValue(true)).called(1);
    });

    test('Should throw exception When cannot enable notification', () {
      when(characteristic.setNotifyValue(true)).thenAnswer(throwException);
      expect(scale.connect(), throwsWeightScaleException);
    });

    test('Should throw exception When setNotifyValue returns false', () {
      when(characteristic.setNotifyValue(true)).thenAnswer((_) async => false);
      expect(scale.connect(), throwsWeightScaleException);
    });

    test('Should listen to lastValueStream When called', () async {
      await scale.connect();
      expect(controller.hasListener, isTrue);
    });

    test('Should disable notification When already connected', () async {
      await scale.connect();
      setDeviceState(blue.BluetoothConnectionState.connected);
      await scale.connect();
      verify(characteristic.setNotifyValue(false)).called(1);
    });

    test('Should not listen to lastValueStream When already connected',
        () async {
      await scale.connect();
      setDeviceState(blue.BluetoothConnectionState.connected);
      when(characteristic.lastValueStream)
          .thenAnswer((_) => const Stream.empty());
      await scale.connect();
      expect(controller.hasListener, isFalse);
    });
  });

  group('disconnect', () {
    setUp(() async {
      await scale.connect();
    });

    test('Should call disconnect on the ble device', () async {
      await scale.disconnect();
      verify(device.disconnect());
    });

    test('Should unsubscribe of the lastValueStream', () async {
      await scale.disconnect();
      expect(controller.hasListener, isFalse);
    });

    test('Should disable notification', () async {
      await scale.disconnect();
      await flushMicrotasks();
      verify(characteristic.setNotifyValue(false)).called(1);
    });

    test('Should throw an exception When cannot disconnect', () {
      when(device.disconnect()).thenAnswer(throwException);
      expect(scale.disconnect(), throwsWeightScaleException);
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

      await flushMicrotasks();
      scale.onDataHandler = (_) => const Weight(10, WeightUnit.kg);
      controller.add(Uint8List.fromList([1, 3, 4]));

      expect(await weight, const Weight(10, WeightUnit.kg));
    });
  });

  group('currentWeight', () {
    setUp(() async {
      await scale.connect();
      scale.onDataHandler =
          (data) => Weight(data.first.toDouble(), WeightUnit.kg);
    });

    tearDown(() async {
      await scale.disconnect();
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
      setDeviceState(blue.BluetoothConnectionState.connected);
      expect(await scale.isConnected, true);
    });

    test('Should be false When is not connected', () async {
      const states = [
        blue.BluetoothConnectionState.connecting,
        blue.BluetoothConnectionState.disconnecting,
        blue.BluetoothConnectionState.disconnected,
      ];

      for (final state in states) {
        setDeviceState(state);
        expect(await scale.isConnected, false);
      }
    });
  });

  group('currentState', () {
    test('Should return the same as the ble device', () async {
      for (final state in blue.BluetoothConnectionState.values) {
        setDeviceState(state);
        expect(
          await scale.currentState,
          FlutterBluePlusConverter.toBleDeviceState(state),
        );
      }
    });
  });

  // group('connected', () {
  //   test('Should emit the same values as the ble device', () async {
  //     const states = [true, false, true, false, true, false];
  //     when(device.connectionState).thenAnswer(
  //       (_) => Stream.fromIterable(states),
  //     );
  //     final result = scale.connected.take(states.length).toList();
  //     expect(await result, states);
  //   });
  // });

//   group('takeWeightMeasurement', () {
//     late bool hasMeasured;
//     late Future<Weight> weight;

//     setUp(() async {
//       await scale.connect();

//       hasMeasured = false;
//       weight = scale.takeWeightMeasurement();
//       weight.whenComplete(() => hasMeasured = true);
//       scale.onDataHandler = (_) => const Weight(23, WeightUnit.kg);
//     });

//     tearDown(() async {
//       await scale.disconnect();
//     });

//     test('Should complete When has stabilized returns true', () async {
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);

//       controller.add(Uint8List.fromList([1, 1]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);

//       controller.add(Uint8List.fromList([18]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);

//       scale.stabilized = true;

//       controller.add(Uint8List.fromList([45]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isTrue);
//       expect(await weight, const Weight(23, WeightUnit.kg));
//     });

//     test(
//         'Should also complete When called multiple times during the same measurement',
//         () async {
//       controller.add(Uint8List.fromList([1, 1]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);

//       var otherHasMeasured = false;
//       final other = scale.takeWeightMeasurement();
//       other.whenComplete(() => otherHasMeasured = true);

//       controller.add(Uint8List.fromList([18]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);
//       expect(otherHasMeasured, isFalse);

//       scale.stabilized = true;

//       controller.add(Uint8List.fromList([45]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isTrue);
//       expect(otherHasMeasured, isTrue);
//       expect(await weight, const Weight(23, WeightUnit.kg));
//       expect(await other, const Weight(23, WeightUnit.kg));
//     });

//     test('Should work When taking a second measurement', () async {
//       controller.add(Uint8List.fromList([1, 1]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);

//       scale.stabilized = true;

//       controller.add(Uint8List.fromList([36]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isTrue);
//       expect(await weight, const Weight(23, WeightUnit.kg));

//       scale.stabilized = false;

//       weight = scale.takeWeightMeasurement();
//       hasMeasured = false;
//       weight.whenComplete(() => hasMeasured = true);

//       controller.add(Uint8List.fromList([18]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isFalse);

//       scale.stabilized = true;

//       controller.add(Uint8List.fromList([45]));
//       await Future.delayed(Duration.zero);
//       expect(hasMeasured, isTrue);
//       expect(await weight, const Weight(23, WeightUnit.kg));
//     });
//   });

//   group('connect', () {
//     const timeout = Duration(seconds: 5);
//     const bleException = BleException("testing");
//     const scaleException = WeightScaleException("testing");

//     test('Should call connect on the ble device When called', () async {
//       await scale.connect(timeout: timeout);
//       verify(device.connect(timeout: timeout));
//     });

//     test('Should throw a weight scale exception When connection fails', () {
//       when(device.connect(timeout: timeout)).thenThrow(bleException);
//       expect(scale.connect(timeout: timeout), throwsA(scaleException));
//     });

//     test('Should call discover devices on the ble device When called',
//         () async {
//       await scale.connect(timeout: timeout);
//       verify(device.discoverServices());
//     });

//     test('Should throw a weight scale exception When the discovery fails', () {
//       when(device.discoverServices()).thenThrow(bleException);
//       expect(scale.connect(timeout: timeout), throwsA(scaleException));
//     });

//     test('Should not call connect on ble device When is already connected',
//         () async {
//       when(device.currentState)
//           .thenAnswer((_) async => BleDeviceState.connected);
//       await scale.connect(timeout: timeout);

//       verifyNever(device.connect(timeout: timeout));
//     });

//     test('Should try to reenable the notification When is already connected',
//         () async {
//       when(device.currentState)
//           .thenAnswer((_) async => BleDeviceState.connected);
//       await scale.connect(timeout: timeout);

//       verify(device.discoverServices());
//       verify(device.subscribeCharacteristic(characteristic));
//     });

//     test(
//         'Should throw a weight scale exception When the service is not present',
//         () async {
//       when(device.discoverServices()).thenAnswer((_) async => [otherService]);
//       expect(scale.connect(), throwsWeightScaleException);
//     });

//     test('Should throw a weight scale exception When no service is not present',
//         () async {
//       when(device.discoverServices()).thenAnswer((_) async => []);
//       expect(scale.connect(), throwsWeightScaleException);
//     });

//     test(
//         'Should throw a weight scale exception When the characteristic is not present',
//         () async {
//       const wrong = Service(
//         deviceId: 'id',
//         uuid: serviceUuid,
//         characteristics: [
//           Characteristic(
//             deviceId: 'id',
//             serviceUuid: serviceUuid,
//             uuid: Uuid('54f9c48d-439f-4187-b72d-d880748c2406'),
//           ),
//         ],
//         includedServices: [],
//         isPrimary: true,
//       );

//       when(device.discoverServices()).thenAnswer((_) async => [wrong]);
//       expect(scale.connect(), throwsWeightScaleException);
//     });

//     test('Should enable notification on the characteristic When called',
//         () async {
//       await scale.connect();
//       verify(device.subscribeCharacteristic(characteristic));
//     });

//     test('Should throw a weight scale exception When subscribing fails', () {
//       when(device.subscribeCharacteristic(characteristic))
//           .thenThrow(bleException);
//       expect(scale.connect(), throwsA(scaleException));
//     });
//   });
}
