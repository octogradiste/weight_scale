@Timeout(Duration(seconds: 1))
import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/backend/fb_backend.dart';
import 'package:weight_scale/src/ble/ble.dart';

import 'fb_ble_device_test.mocks.dart';

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
  ],
);

const service = Service(
  deviceId: 'id',
  uuid: Uuid('83b504fc-374c-4868-945a-4cc58474d46e'),
  characteristics: [characteristic],
  includedServices: [],
  isPrimary: false,
);

const services = [
  Service(
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
    includedServices: [service],
    isPrimary: true,
  ),
  service,
];

@GenerateMocks([BluetoothDevice, BluetoothCharacteristic, FbConversion])
void main() {
  late FbConversion conversion;
  late MockBluetoothDevice mockDevice;
  late StreamController<BluetoothDeviceState> stateController;
  late BluetoothDeviceState currentState;
  late BleDevice device;

  void updateMockDeviceState(BluetoothDeviceState state) {
    currentState = state;
    stateController.add(state);
  }

  setUp((() {
    conversion = FbConversion();
    mockDevice = MockBluetoothDevice();

    stateController = StreamController.broadcast();
    currentState = BluetoothDeviceState.disconnected;

    when(mockDevice.id).thenReturn(const DeviceIdentifier('id'));
    when(mockDevice.name).thenReturn('test');
    when(mockDevice.state).thenAnswer((_) async* {
      yield currentState;
      yield* stateController.stream;
    });
    when(mockDevice.connect(timeout: anyNamed('timeout'))).thenAnswer(
        (_) async => updateMockDeviceState(BluetoothDeviceState.connected));
    when(mockDevice.disconnect()).thenAnswer(
        (_) async => updateMockDeviceState(BluetoothDeviceState.disconnected));
    when(mockDevice.discoverServices()).thenAnswer((_) async {
      return services
          .map((service) => conversion.fromService(service))
          .toList();
    });

    device = FbBleDevice(mockDevice, conversion);
  }));

  tearDown((() async {
    stateController.close();
  }));

  group('constructor', () {
    test('Should have the same name as the bluetooth device When constructed',
        () {
      expect(device.information.name, "test");
    });

    test('Should have the same id as the bluetooth device When constructed',
        () {
      expect(device.information.id, "id");
    });
  });

  group('services', () {
    test('Should be empty When not discovered services yet', () async {
      expect(await device.services, isEmpty);
    });

    test('Should have the discovered services When did discovery', () async {
      await device.connect();
      await device.discoverServices();
      expect(await device.services, services);
    });
  });

  group('state', () {
    test('Should be a broadcast stream', () {
      expect(device.state.isBroadcast, isTrue);
    });

    test('Should emit the same state as the device stream', () async {
      final states = device.state.take(7).toList();
      await flushMicroTasks();

      // Random states before connecting.
      updateMockDeviceState(BluetoothDeviceState.connecting);
      updateMockDeviceState(BluetoothDeviceState.disconnecting);
      await flushMicroTasks();

      // Emits  connected state.
      await device.connect();
      await flushMicroTasks();

      // Random state when connected.
      updateMockDeviceState(BluetoothDeviceState.disconnected);
      updateMockDeviceState(BluetoothDeviceState.connected);
      await flushMicroTasks();

      // Emits disconnected state.
      await device.disconnect();
      await flushMicroTasks();

      expect(await states, const [
        BleDeviceState.disconnected,
        BleDeviceState.connecting,
        BleDeviceState.disconnecting,
        BleDeviceState.connected,
        BleDeviceState.disconnected,
        BleDeviceState.connected,
        BleDeviceState.disconnected,
      ]);
    });
  });

  group('currentState', () {
    test('Should be set to disconnected When created', () async {
      expect(await device.currentState, BleDeviceState.disconnected);
    });

    test('Should equal the emitted states from the bluetooth device', () async {
      await device.connect();
      updateMockDeviceState(BluetoothDeviceState.connecting);
      await flushMicroTasks();
      expect(await device.currentState, BleDeviceState.connecting);
      updateMockDeviceState(BluetoothDeviceState.disconnecting);
      await flushMicroTasks();
      expect(await device.currentState, BleDeviceState.disconnecting);
      updateMockDeviceState(BluetoothDeviceState.connected);
      await flushMicroTasks();
      expect(await device.currentState, BleDeviceState.connected);
    });
  });

  group('connect', () {
    test(
        'Should call connect with null timeout on bluetooth device When called',
        () async {
      // when(mockDevice.connect()).thenAnswer((_) async =>
      //     mockDevice.updateState(BluetoothDeviceState.connected));
      const Duration timeout = Duration(seconds: 10);
      await device.connect(timeout: timeout);
      verify(mockDevice.connect(timeout: null));
    });

    test('Should throw a ble exception When timeout is reached', () {
      fakeAsync((async) {
        const timeout = Duration(seconds: 15);
        when(mockDevice.connect(timeout: null)).thenAnswer(
          (_) => Future.delayed(timeout * 2),
        );
        expect(
          device.connect(timeout: timeout),
          throwsBleException(),
        );
        async.elapse(timeout);
      });
    });

    test('Should be in disconnect state When timeout is reached', () async {
      fakeAsync((async) {
        const timeout = Duration(seconds: 15);
        when(mockDevice.connect(timeout: null)).thenAnswer((_) {
          return Future.delayed(timeout * 2);
        });
        device.state.take(2).toList().then((states) {
          expect(states, const [
            BleDeviceState.disconnected,
            BleDeviceState.disconnected,
          ]);
        });
        expect(
          device.connect(timeout: timeout),
          throwsBleException(),
        );
        // updateMockDeviceState(BluetoothDeviceState.connecting);
        async.flushMicrotasks();
        // expect(device.currentState, BleDeviceState.connecting);
        async.elapse(timeout);
      });
      expect(await device.currentState, BleDeviceState.disconnected);
    });

    test('Should throw a ble exception When connection fails', () {
      const timeout = Duration(seconds: 15);
      final exception = Exception('exception');
      when(mockDevice.connect(timeout: null)).thenThrow(exception);
      expect(
        device.connect(timeout: timeout),
        throwsBleException(exception: exception),
      );
    });

    test('Should be disconnected When connection fails', () async {
      const timeout = Duration(seconds: 15);
      final exception = Exception('exception');
      when(mockDevice.connect(timeout: null)).thenThrow(exception);
      expect(
        device.connect(timeout: timeout),
        throwsBleException(exception: exception),
      );
      expect(await device.currentState, BleDeviceState.disconnected);
    });

    test('Should throw a ble exception When is already connected', () async {
      await device.connect();
      expect(device.connect(), throwsBleException());
      stateController.add(BluetoothDeviceState.connecting);
      await flushMicroTasks();
      expect(device.connect(), throwsBleException());
    });
  });

  group('disconnect', () {
    test('Should call disconnect on bluetooth device When called', () async {
      await device.connect();
      await device.disconnect();
      verify(mockDevice.disconnect());
    });

    test('Should not call disconnect on bluetooth device When not connected',
        () async {
      await device.disconnect();
      verifyNever(mockDevice.disconnect());
    });

    test('Should throw a ble exception When disconnection fails', () async {
      final exception = Exception('exception');
      when(mockDevice.disconnect()).thenAnswer((_) {
        updateMockDeviceState(BluetoothDeviceState.disconnected);
        throw exception;
      });
      await device.connect();
      expect(device.disconnect(), throwsBleException(exception: exception));
      await flushMicroTasks();
      expect(await device.currentState, BleDeviceState.disconnected);
      // Disconnect is called in the tear down, so we need to prevent it from throwing.
      when(mockDevice.disconnect()).thenAnswer((_) async {
        stateController.add(BluetoothDeviceState.disconnected);
      });
    });
  });

  group('discoverServices', () {
    test('Should call discover services on bluetooth device When called',
        () async {
      await device.connect();
      await device.discoverServices();
      verify(mockDevice.discoverServices());
    });

    test(
        'Should throw an ble exception When discovering services before connecting',
        () async {
      expect(device.discoverServices(), throwsBleException());
    });

    test('Should throw a ble exception When discovering services fails',
        () async {
      final exception = Exception('exception');
      when(mockDevice.discoverServices()).thenThrow(exception);
      await device.connect();
      expect(
        device.discoverServices(),
        throwsBleException(exception: exception),
      );
    });
  });

  group('characteristic', () {
    late MockFbConversion mockConversion;
    late MockBluetoothCharacteristic mockCharacteristic;

    setUp(() {
      mockConversion = MockFbConversion();
      mockCharacteristic = MockBluetoothCharacteristic();
      when(mockConversion.fromCharacteristic(characteristic))
          .thenReturn(mockCharacteristic);
      when(mockConversion.toBleDeviceState(any)).thenAnswer((invocation) =>
          conversion.toBleDeviceState(invocation.positionalArguments[0]));

      device = FbBleDevice(mockDevice, mockConversion);
    });

    group('read', () {
      test(
          'Should throw an ble exception When reading a characteristic before connecting',
          () async {
        expect(device.readCharacteristic(characteristic), throwsBleException());
      });

      test('Should throw a ble exception When reading fails', () async {
        await device.connect();
        final exception = Exception('exception');
        when(mockCharacteristic.read()).thenThrow(exception);
        expect(
          device.readCharacteristic(characteristic),
          throwsBleException(exception: exception),
        );
      });

      test('Should return the correct values When reading', () async {
        await device.connect();
        const values = [1, 2, 3, 4];
        when(mockCharacteristic.read()).thenAnswer((_) async => values);
        expect(
          await device.readCharacteristic(characteristic),
          Uint8List.fromList(values),
        );
      });
    });

    group('write', () {
      test(
          'Should throw an ble exception When writing a characteristic before connecting',
          () async {
        expect(
          device.writeCharacteristic(characteristic, value: Uint8List(0)),
          throwsBleException(),
        );
      });

      test('Should throw a ble exception When writing fails', () async {
        await device.connect();
        final exception = Exception('exception');
        const values = [1, 2, 3, 4];
        when(mockCharacteristic.write(values, withoutResponse: true))
            .thenThrow(exception);

        expect(
          device.writeCharacteristic(
            characteristic,
            value: Uint8List.fromList(values),
            response: false,
          ),
          throwsBleException(exception: exception),
        );
      });

      test(
          'Should make correct call to the bluetooth characteristic When reading',
          () async {
        await device.connect();
        const values = [1, 2, 3, 4];
        when(mockCharacteristic.write(values, withoutResponse: false))
            .thenAnswer((_) async {});

        await device.writeCharacteristic(
          characteristic,
          value: Uint8List.fromList(values),
          response: true,
        );

        verify(mockCharacteristic.write(values, withoutResponse: false));
      });
    });

    group('subscribe', () {
      late StreamController<List<int>> valueController;

      setUp(() {
        valueController = StreamController();
        when(mockCharacteristic.value)
            .thenAnswer((_) => valueController.stream);
      });

      tearDown((() {
        valueController.close();
      }));

      test(
          'Should throw an ble exception When subscribing to a characteristic before connecting',
          () {
        expect(
          device.subscribeCharacteristic(characteristic),
          throwsBleException(),
        );
      });

      test(
          'Should throw a ble exception When setting the notification returns false',
          () async {
        await device.connect();
        when(mockCharacteristic.setNotifyValue(true))
            .thenAnswer((_) async => false);
        expect(
          device.subscribeCharacteristic(characteristic),
          throwsBleException(),
        );
      });

      test('Should throw a ble exception When subscribing fails', () async {
        await device.connect();
        final exception = Exception('exception');
        when(mockCharacteristic.setNotifyValue(true)).thenThrow(exception);
        expect(
          device.subscribeCharacteristic(characteristic),
          throwsBleException(exception: exception),
        );
      });

      test(
          'Should emit the same values as the bluetooth characteristic When listening to the returned stream',
          () async {
        await device.connect();
        when(mockCharacteristic.setNotifyValue(any)).thenAnswer(
          (_) async => true,
        );
        final values = (await device.subscribeCharacteristic(characteristic))
            .take(3)
            .toList();
        valueController.add(const [1, 2, 3]);
        valueController.add(const [4, 5]);
        valueController.add(const [6, 7, 8]);
        expect(await values, [
          Uint8List.fromList(const [1, 2, 3]),
          Uint8List.fromList(const [4, 5]),
          Uint8List.fromList(const [6, 7, 8]),
        ]);
      });

      test('Should disable notification When stop listening to the stream',
          () async {
        await device.connect();
        when(mockCharacteristic.setNotifyValue(any)).thenAnswer(
          (_) async => true,
        );
        final v = (await device.subscribeCharacteristic(characteristic)).first;
        valueController.add(const [1, 2, 3]);
        await v; // This will stop listening to the stream.
        verify(mockCharacteristic.setNotifyValue(true));
        verify(mockCharacteristic.setNotifyValue(false));
      });

      test(
          'Should throw an ble exception When disabling the notification returns false',
          () async {
        await device.connect();
        when(mockCharacteristic.setNotifyValue(true))
            .thenAnswer((_) async => true);
        when(mockCharacteristic.setNotifyValue(false))
            .thenAnswer((_) async => false);
        final stream = await device.subscribeCharacteristic(characteristic);
        final subscription = stream.listen(null);
        expect(subscription.cancel(), throwsBleException());
      });

      test(
          'Should throw an ble exception When disabling the notification fails',
          () async {
        await device.connect();
        final exception = Exception('exception');
        when(mockCharacteristic.setNotifyValue(true))
            .thenAnswer((_) async => true);
        when(mockCharacteristic.setNotifyValue(false)).thenThrow(exception);
        final stream = await device.subscribeCharacteristic(characteristic);
        final subscription = stream.listen(null);
        expect(subscription.cancel(), throwsBleException(exception: exception));
      });

      test('Should not do anything When already disconnected', () async {
        await device.connect();
        when(mockCharacteristic.setNotifyValue(true))
            .thenAnswer((_) async => true);
        final stream = await device.subscribeCharacteristic(characteristic);
        final subscription = stream.listen(null);
        await device.disconnect();
        await subscription.cancel(); // Canceling subscription after disconnect.
        verifyNever(mockCharacteristic.setNotifyValue(false));
      });
    });
  });
}

/// Simulates flushing the micro tasks by awaiting a zero delay.
Future<void> flushMicroTasks({Duration duration = Duration.zero}) {
  return Future.delayed(duration);
}

/// Matches if a [BleException] was thrown and has the given [exception]
/// as attribute.
Matcher throwsBleException<T>({T? exception}) {
  return throwsA(
    allOf(
      const TypeMatcher<BleException>(),
      predicate(
        (e) => (e as BleException).exception == exception,
        'Should contain the thrown exception.',
      ),
    ),
  );
}
