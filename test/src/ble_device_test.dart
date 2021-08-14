import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/service.dart';
import 'package:weight_scale/src/model/uuid.dart';

import 'fake_ble_operations.dart';
import 'ble_service_test.mocks.dart';

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

Service createFakeService() {
  return Service(
    deviceId: "deviceId",
    uuid: Uuid("uuid"),
    characteristics: List.from([createFakeCharacteristic()]),
  );
}

Uint8List createFakeValue() => Uint8List.fromList(List.empty());

void main() {
  group('BleDevice', () {
    group('equality', () {
      late BleOperations operations;
      late BleDevice device;

      setUp(() {
        operations = MockBleOperations();
        device = BleDevice(id: "id", name: "name", operations: operations);
      });

      test('equal id and name', () {
        BleDevice other = BleDevice(
          id: "id",
          name: "name",
          operations: operations,
        );
        expect(device, equals(other));
      });

      test('equal id and different name', () {
        BleDevice other = BleDevice(
          id: "id",
          name: "other",
          operations: operations,
        );
        expect(device != other, true);
      });

      test('different id and equal name', () {
        BleDevice other = BleDevice(
          id: "other",
          name: "name",
          operations: operations,
        );
        expect(device != other, true);
      });
    });

    group('methods', () {
      late BleOperations bleOperations;
      late BleDevice device;
      late Characteristic characteristic;
      late Service service;

      setUp(() {
        bleOperations = MockBleOperations();
        device = createFakeBleDevice(bleOperations);
        characteristic = createFakeCharacteristic();
        service = createFakeService();
      });

      test('state changes when disconnect call back is called', () async {
        Future<void> Function() callback =
            () => throw "Not assigned to real Invocation";
        when((bleOperations as MockBleOperations).addDisconnectCallback(
          device: device,
          callback: anyNamed("callback"),
        )).thenAnswer((realInvocation) async {
          callback = realInvocation.namedArguments[Symbol("callback")];
        });
        device = createFakeBleDevice(bleOperations);
        await callback();
        expect(device.currentState, BleDeviceState.disconnected);
      });

      test('[discoverService] returns same as the discover operation.',
          () async {
        when(bleOperations.discoverService(device: device))
            .thenAnswer((_) => Future.value(List.from([service])));

        List<Service> services = await device.discoverService();
        expect(services, containsAllInOrder([service]));
      });

      test(
          'After [discoverService] completes, the [services] getter returns same as the discover operation.',
          () async {
        when(bleOperations.discoverService(device: device))
            .thenAnswer((_) => Future.value(List.from([service])));

        await device.discoverService();
        expect(device.services, containsAllInOrder([service]));
      });

      test('[readCharacteristic] returns same as the read operation.',
          () async {
        Uint8List value = Uint8List.fromList([255, 13, 29]);
        when(bleOperations.readCharacteristic(characteristic: characteristic))
            .thenAnswer((_) => Future.value(value));

        Uint8List read =
            await device.readCharacteristic(characteristic: characteristic);
        expect(read, containsAllInOrder(value));
      });

      test('[subscribeCharacteristic] returns same as the subscribe operation.',
          () async {
        Uint8List value = Uint8List.fromList([255, 13, 29]);
        Stream<Uint8List> stream = Stream.fromIterable([value]);
        when(bleOperations.subscribeCharacteristic(
                characteristic: characteristic))
            .thenAnswer((_) => Future.value(stream));

        Stream<Uint8List> result = await device.subscribeCharacteristic(
            characteristic: characteristic);
        await expectLater(
          result,
          emitsInOrder([
            containsAllInOrder(value),
            emitsDone,
          ]),
        );
      });
    });

    test('operations are queued', () {
      fakeAsync((async) {
        Duration operationDuration = Duration(seconds: 1);
        BleOperations bleOperations = FakeBleOperations(operationDuration);
        BleDevice device = createFakeBleDevice(bleOperations);
        Characteristic characteristic = createFakeCharacteristic();

        List<int> order = List.empty(growable: true);
        device.connect().then((_) => order.add(1));
        device.discoverService().then((_) => order.add(2));
        device
            .readCharacteristic(characteristic: characteristic)
            .then((_) => order.add(3));
        device
            .writeCharacteristic(
              characteristic: characteristic,
              value: createFakeValue(),
            )
            .then((_) => order.add(4));
        device
            .writeCharacteristic(
              characteristic: characteristic,
              value: createFakeValue(),
              response: false,
            )
            .then((_) => order.add(5));
        device
            .subscribeCharacteristic(characteristic: characteristic)
            .then((_) => order.add(6));

        device.disconnect().then((_) => order.add(7));

        async.elapse(operationDuration);
        expect(order.length, 1);
        expect(order, containsAllInOrder([1]));

        async.elapse(operationDuration);
        expect(order.length, 2);
        expect(order, containsAllInOrder([1, 2]));

        async.elapse(operationDuration);
        expect(order.length, 3);
        expect(order, containsAllInOrder([1, 2, 3]));

        async.elapse(operationDuration);
        expect(order.length, 4);
        expect(order, containsAllInOrder([1, 2, 3, 4]));

        async.elapse(operationDuration);
        expect(order.length, 5);
        expect(order, containsAllInOrder([1, 2, 3, 4, 5]));

        async.elapse(operationDuration);
        expect(order.length, 6);
        expect(order, containsAllInOrder([1, 2, 3, 4, 5, 6]));

        async.elapse(operationDuration);
        expect(order.length, 7);
        expect(order, containsAllInOrder([1, 2, 3, 4, 5, 6, 7]));
      });
    });

    group('throwing errors', () {
      late BleDevice device;
      late BleOperations bleOperations;
      late Characteristic characteristic;
      late BleOperationException exception;

      setUp(() {
        bleOperations = MockBleOperations();
        device = createFakeBleDevice(bleOperations);
        characteristic = createFakeCharacteristic();
        exception = BleOperationException("Just for testing");
      });

      test('After timeout [connect] throws a timeout exception.', () async {
        fakeAsync((async) {
          Duration timeout = Duration(seconds: 10);
          when(bleOperations.connect(device: device, timeout: timeout))
              .thenAnswer((_) => Future.delayed(timeout * 2));
          expect(device.connect(timeout: timeout),
              throwsA(TypeMatcher<TimeoutException>()));
          async.elapse(timeout * 2);
        });
      });

      test(
          'If connect operation throws, device rethrows and state is [disconnected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        Duration timeout = Duration(seconds: 10);
        when(bleOperations.connect(device: device, timeout: timeout))
            .thenThrow(exception);
        expect(device.connect(timeout: timeout), throwsA(exception));
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.connecting,
            BleDeviceState.disconnected,
          ])),
        );
      });

      test(
          'If disconnect operation throws, device rethrows and state is [disconnected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        when(bleOperations.disconnect(device: device)).thenThrow(exception);
        expect(device.disconnect(), throwsA(exception));
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.disconnecting,
            BleDeviceState.disconnected,
          ])),
        );
      });

      test(
          'If discovering operation throws, device rethrows and state is [connected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        when(bleOperations.discoverService(device: device))
            .thenThrow(exception);
        expect(device.discoverService(), throwsA(exception));
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.discoveringServices,
            BleDeviceState.connected,
          ])),
        );
      });

      test(
          'If read operation throws, device rethrows and state is [connected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        when(bleOperations.readCharacteristic(characteristic: characteristic))
            .thenThrow(exception);
        expect(device.readCharacteristic(characteristic: characteristic),
            throwsA(exception));
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.readingCharacteristic,
            BleDeviceState.connected,
          ])),
        );
      });

      test(
          'If wirte operation throws, device rethrows and state is [connected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        Uint8List value = Uint8List.fromList(List.empty());
        when(bleOperations.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: true,
        )).thenThrow(exception);
        expect(
          device.writeCharacteristic(
            characteristic: characteristic,
            value: value,
            response: true,
          ),
          throwsA(exception),
        );
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.writingCharacteristic,
            BleDeviceState.connected,
          ])),
        );
      });

      test(
          'If wirte without response operation throws, device rethrows and state is [connected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        Uint8List value = Uint8List.fromList(List.empty());
        when(bleOperations.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: false,
        )).thenThrow(exception);
        expect(
          device.writeCharacteristic(
            characteristic: characteristic,
            value: value,
            response: false,
          ),
          throwsA(exception),
        );
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.writingCharacteristic,
            BleDeviceState.connected,
          ])),
        );
      });

      test(
          'If subscribe service operation throws, device rethrows and state is [connected].',
          () async {
        Future<List<BleDeviceState>> states = device.state.take(2).toList();

        when(bleOperations.subscribeCharacteristic(
                characteristic: characteristic))
            .thenThrow(exception);
        expect(device.subscribeCharacteristic(characteristic: characteristic),
            throwsA(exception));
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleDeviceState.subscribingCharacteristic,
            BleDeviceState.connected,
          ])),
        );
      });
    });

    group('calling operations', () {
      late BleDevice device;
      late BleOperations bleOperations;
      late Characteristic characteristic;

      setUp(() {
        bleOperations = MockBleOperations();
        device = createFakeBleDevice(bleOperations);
        characteristic = createFakeCharacteristic();
      });

      test('Verify connect operations gets called.', () {
        Duration timeout = Duration(milliseconds: 20);
        device.connect(timeout: timeout);
        verify(bleOperations.connect(device: device, timeout: timeout));
      });

      test('Verify disconnect operations gets called.', () {
        device.disconnect();
        verify(bleOperations.disconnect(device: device));
      });

      test('Verify discovering services operations gets called.', () {
        when(bleOperations.discoverService(device: device))
            .thenAnswer((_) => Future.value(List.empty()));
        device.discoverService();
        verify(bleOperations.discoverService(device: device));
      });

      test('Verify read operations gets called.', () {
        when(bleOperations.readCharacteristic(characteristic: characteristic))
            .thenAnswer((_) => Future.value(Uint8List.fromList(List.empty())));
        device.readCharacteristic(characteristic: characteristic);
        verify(bleOperations.readCharacteristic(
          characteristic: characteristic,
        ));
      });

      test('Verify write operations gets called.', () {
        Uint8List value = Uint8List.fromList(List.empty());
        device.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: true,
        );
        verify(bleOperations.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: true,
        ));
      });

      test('Verify write without response operations gets called.', () {
        Uint8List value = Uint8List.fromList(List.empty());
        device.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: false,
        );
        verify(bleOperations.writeCharacteristic(
          characteristic: characteristic,
          value: value,
          response: false,
        ));
      });

      test('Verify subscribe characteristic operations gets called.', () {
        when(bleOperations.subscribeCharacteristic(
          characteristic: characteristic,
        )).thenAnswer((_) => Future.value(Stream.empty()));
        device.subscribeCharacteristic(characteristic: characteristic);
        verify(bleOperations.subscribeCharacteristic(
          characteristic: characteristic,
        ));
      });
    });

    group('state', () {
      late BleDevice device;
      late BleOperations bleOperations;
      late Characteristic characteristic;

      setUp(() {
        bleOperations = MockBleOperations();
        device = createFakeBleDevice(bleOperations);
        characteristic = createFakeCharacteristic();
      });

      test('Initially the state is [disconnected].', () {
        expect(device.currentState, BleDeviceState.disconnected);
      });

      test('While connecting the state is [connecting].', () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        Future<void> operation = device.connect();
        expect(device.currentState, BleDeviceState.connecting);
        await operation;
        expect(device.currentState, BleDeviceState.connected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.connecting,
            BleDeviceState.connected,
          ]),
        );
      });

      test('While disconnecting the state is [disconnecting].', () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        Future<void> operation = device.disconnect();
        expect(device.currentState, BleDeviceState.disconnecting);
        await operation;
        expect(device.currentState, BleDeviceState.disconnected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.disconnecting,
            BleDeviceState.disconnected,
          ]),
        );
      });

      test('While discovering the state is [discoveringServices].', () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        when(bleOperations.discoverService(device: device))
            .thenAnswer((_) => Future.value(List.empty()));
        Future<List<Service>> operation = device.discoverService();
        expect(device.currentState, BleDeviceState.discoveringServices);
        await operation;
        expect(device.currentState, BleDeviceState.connected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.discoveringServices,
            BleDeviceState.connected,
          ]),
        );
      });

      test('While reading the state is [readingCharacteristic].', () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        when(bleOperations.readCharacteristic(characteristic: characteristic))
            .thenAnswer((_) => Future.value(Uint8List.fromList(List.empty())));
        Future<Uint8List> operation = device.readCharacteristic(
          characteristic: characteristic,
        );
        expect(device.currentState, BleDeviceState.readingCharacteristic);
        await operation;
        expect(device.currentState, BleDeviceState.connected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.readingCharacteristic,
            BleDeviceState.connected,
          ]),
        );
      });

      test('While writing the state is [writingCharacteristic].', () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        Future<void> operation = device.writeCharacteristic(
          characteristic: characteristic,
          value: Uint8List.fromList(List.empty()),
        );
        expect(device.currentState, BleDeviceState.writingCharacteristic);
        await operation;
        expect(device.currentState, BleDeviceState.connected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.writingCharacteristic,
            BleDeviceState.connected,
          ]),
        );
      });

      test(
          'While writing with no response the state is [writingCharacteristic].',
          () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        Future<void> operation = device.writeCharacteristic(
          characteristic: characteristic,
          value: Uint8List.fromList(List.empty()),
          response: false,
        );
        expect(device.currentState, BleDeviceState.writingCharacteristic);
        await operation;
        expect(device.currentState, BleDeviceState.connected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.writingCharacteristic,
            BleDeviceState.connected,
          ]),
        );
      });

      test('While subscribing the state is [subscribingCharacteristic].',
          () async {
        Future<List<BleDeviceState>> futureStates =
            device.state.take(2).toList();
        when(bleOperations.subscribeCharacteristic(
          characteristic: characteristic,
        )).thenAnswer((_) => Future.value(Stream.empty()));
        Future<Stream<Uint8List>> operation = device.subscribeCharacteristic(
          characteristic: characteristic,
        );
        expect(device.currentState, BleDeviceState.subscribingCharacteristic);
        await operation;
        expect(device.currentState, BleDeviceState.connected);
        List<BleDeviceState> states = await futureStates;
        expect(
          states,
          containsAllInOrder([
            BleDeviceState.subscribingCharacteristic,
            BleDeviceState.connected,
          ]),
        );
      });
    });
  });
}
