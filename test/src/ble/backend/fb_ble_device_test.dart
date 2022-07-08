import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/backend/fb_backend.dart';
import 'package:weight_scale/src/ble/ble.dart';

import 'fb_ble_device_test.mocks.dart';

@GenerateMocks([BluetoothDevice, BluetoothCharacteristic, FbConversion])
void main() {
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

  late FbConversion conversion;
  late MockBluetoothDevice mockDevice;
  late StreamController<BluetoothDeviceState> stateController;
  late BleDevice device;

  setUp((() {
    conversion = FbConversion();
    mockDevice = MockBluetoothDevice();
    stateController = StreamController();
    when(mockDevice.name).thenReturn("test");
    when(mockDevice.id).thenReturn(const DeviceIdentifier("id"));
    when(mockDevice.state).thenAnswer((_) => stateController.stream);
    when(mockDevice.connect(
      timeout: anyNamed("timeout"),
      autoConnect: anyNamed("autoConnect"),
    )).thenAnswer((_) async {
      // The first state emitted, will get skipped. This is because of the
      // flutter blue implementation of the state getter which will return as
      // the first state the current state, i.e. disconnected.
      stateController.add(BluetoothDeviceState.disconnected);
      stateController.add(BluetoothDeviceState.connecting);
      stateController.add(BluetoothDeviceState.connected);
    });
    when(mockDevice.disconnect()).thenAnswer((_) async {
      stateController.add(BluetoothDeviceState.disconnecting);
      stateController.add(BluetoothDeviceState.disconnected);
    });
    when(mockDevice.discoverServices()).thenAnswer(
      (_) async =>
          services.map((service) => conversion.fromService(service)).toList(),
    );

    device = FbBleDevice(mockDevice, conversion);
  }));

  tearDown((() async {
    await device.disconnect();
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
    test('Should be empty When not discoverd services yet', () async {
      expect(await device.services, isEmpty);
    });

    test('Should have the discoverd services When did discovery', () async {
      await device.connect();
      await device.discoverServices();
      expect(await device.services, services);
    });
  });

  group('state', () {
    setUp(() {
      stateController = StreamController.broadcast();
      when(mockDevice.state).thenAnswer((_) => stateController.stream);
    });

    test('Should be a broadcast stream', () {
      expect(device.state.isBroadcast, isTrue);
    });

    test('Should only start to emit states When connecting', () async {
      const timeout = Duration(seconds: 10);
      final connectionCompleter = Completer();
      when(mockDevice.connect(timeout: timeout)).thenAnswer(
        (_) => connectionCompleter.future,
      );

      final states = device.state.take(3).toList();

      // Emitting states before connecting.
      stateController.add(BluetoothDeviceState.connected);
      stateController.add(BluetoothDeviceState.disconnecting);
      stateController.add(BluetoothDeviceState.disconnected);
      await flushMicroTasks();

      device.connect(timeout: timeout);
      await flushMicroTasks();
      // The first state emitted, should get skipped. This is because of the
      // flutter blue implementation of the state getter which will return as
      // the first state the current state, i.e. disconnected.
      stateController.add(BluetoothDeviceState.disconnected);

      stateController.add(BluetoothDeviceState.connecting);
      stateController.add(BluetoothDeviceState.connected);
      connectionCompleter.complete(); // Complete connection procedure.
      stateController.add(BluetoothDeviceState.disconnecting);
      expect(await states, [
        BleDeviceState.connecting,
        BleDeviceState.connected,
        BleDeviceState.disconnecting,
      ]);
    });

    test('Should emit same states as the bluetooth device When connected',
        () async {
      await device.connect();
      final states = device.state.take(3).toList();
      stateController.add(BluetoothDeviceState.disconnecting);
      stateController.add(BluetoothDeviceState.connecting);
      stateController.add(BluetoothDeviceState.connected);
      expect(await states, [
        BleDeviceState.disconnecting,
        BleDeviceState.connecting,
        BleDeviceState.connected,
      ]);
    });

    test('Should stop emitting states When disconnected', () async {
      final states = device.state.take(8).toList();

      await device.connect();
      stateController.add(BluetoothDeviceState.connecting);
      await flushMicroTasks();

      await device.disconnect();
      // Should not get emitted.
      stateController.add(BluetoothDeviceState.disconnected);
      stateController.add(BluetoothDeviceState.disconnecting);
      stateController.add(BluetoothDeviceState.connecting);
      stateController.add(BluetoothDeviceState.connected);
      await flushMicroTasks();

      await device.connect();
      stateController.add(BluetoothDeviceState.connected);
      await flushMicroTasks();

      expect(await states, [
        BleDeviceState.connecting,
        BleDeviceState.connected,
        BleDeviceState.connecting,
        BleDeviceState.disconnecting,
        BleDeviceState.disconnected,
        BleDeviceState.connecting,
        BleDeviceState.connected,
        BleDeviceState.connected,
      ]);
    });

    test('Should stop emitting states When state change to disconnected',
        () async {
      final states = device.state.take(6).toList();

      await device.connect();

      stateController.add(BluetoothDeviceState.disconnected); // Stops emitting.
      stateController.add(BluetoothDeviceState.disconnecting);
      stateController.add(BluetoothDeviceState.connecting);
      stateController.add(BluetoothDeviceState.connected);
      await flushMicroTasks();

      await device.connect();
      stateController.add(BluetoothDeviceState.connected);
      await flushMicroTasks();

      expect(await states, [
        BleDeviceState.connecting,
        BleDeviceState.connected,
        BleDeviceState.disconnected,
        BleDeviceState.connecting,
        BleDeviceState.connected,
        BleDeviceState.connected,
      ]);
    });
  });

  group('currentState', () {
    test('Should be set to disconnected When created', () {
      expect(device.currentState, BleDeviceState.disconnected);
    });

    test('Should equal the emitted states from the bluetooth device', () async {
      await device.connect();
      stateController.add(BluetoothDeviceState.connecting);
      await flushMicroTasks();
      expect(device.currentState, BleDeviceState.connecting);
      stateController.add(BluetoothDeviceState.disconnecting);
      await flushMicroTasks();
      expect(device.currentState, BleDeviceState.disconnecting);
      stateController.add(BluetoothDeviceState.connected);
      await flushMicroTasks();
      expect(device.currentState, BleDeviceState.connected);
    });
  });

  group('connect', () {
    test(
        'Should call connect with same timeout on bluetooth device When called',
        () async {
      const Duration timeout = Duration(seconds: 10);
      await device.connect(timeout: timeout);
      verify(mockDevice.connect(timeout: timeout));
    });

    test('Should throw a ble exception When timeout is reached', () {
      fakeAsync((async) {
        const timeout = Duration(seconds: 15);
        final exception = TimeoutException('test');
        when(mockDevice.connect(timeout: timeout)).thenAnswer(
          (_) => Future.delayed(timeout).then((_) => throw exception),
        );
        expect(
          device.connect(timeout: timeout),
          throwsBleException(exception: exception),
        );
        async.elapse(timeout);
      });
    });

    test('Should throw a ble exception When connection fails', () {
      const timeout = Duration(seconds: 15);
      final exception = Exception('exception');
      when(mockDevice.connect(timeout: timeout)).thenThrow(exception);
      expect(
        device.connect(timeout: timeout),
        throwsBleException(exception: exception),
      );
    });

    test('Should be disconnected When connection fails', () {
      const timeout = Duration(seconds: 15);
      final exception = Exception('exception');
      when(mockDevice.connect(timeout: timeout)).thenThrow(exception);
      expect(
        device.connect(timeout: timeout),
        throwsBleException(exception: exception),
      );
      expect(device.currentState, BleDeviceState.disconnected);
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
      when(mockDevice.disconnect()).thenThrow(exception);
      await device.connect();
      expect(device.disconnect(), throwsBleException(exception: exception));
      expect(device.currentState, BleDeviceState.disconnected);
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

      stateController = StreamController();
      when(mockDevice.state).thenAnswer((_) => stateController.stream);
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
