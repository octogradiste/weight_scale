import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/ble_service.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/uuid.dart';

import 'fake_ble_operations.dart';
import 'ble_service_test.mocks.dart';

@GenerateMocks([BleOperations])
void main() {
  group('BleService', () {
    group('initialize', () {
      late BleOperations bleOperations;
      late BleService bleService;

      setUp(() {
        bleOperations = MockBleOperations();
        when(bleOperations.scanResults)
            .thenAnswer((_) => Stream<List<ScanResult>>.empty());
        bleService = BleService();
        bleService.initialize(operations: bleOperations);
      });

      test('Is a singleton.', () {
        BleService instance = BleService.instance;
        expect(BleService.instance, same(instance));
      });

      test('If initialized again returns immediately.', () {
        BleOperations newOperations = MockBleOperations();
        bleService.initialize(operations: newOperations);
        verifyNever(newOperations.initialize());
      });

      test('[scanResults] was called once on [bleOperations].', () {
        verify(bleOperations.scanResults).called(1);
      });

      test('[isScanning] is initially false.', () {
        expect(bleService.isScanning, isFalse);
      });

      test('[state] is a broadcast stream.', () {
        expect(bleService.state.isBroadcast, isTrue);
      });

      test('[scanResults] is a broadcast stream.', () {
        expect(bleService.scanResults.isBroadcast, isTrue);
      });

      test('Initialize operation is called once.', () {
        verify(bleOperations.initialize());
      });

      test('[isInitialized] is true.', () {
        expect(bleService.isInitialized, isTrue);
      });

      test('[isInitialized] is false before initialization.', () {
        bleService = BleService();
        expect(bleService.isInitialized, isFalse);
      });

      test('[startScan] throws if not initialized.', () {
        bleService = BleService();
        expect(bleService.startScan(timeout: Duration.zero),
            throwsA(TypeMatcher<BleServiceNotInitializedException>()));
      });

      test('[stopScan] throws if not initialized.', () {
        bleService = BleService();
        expect(bleService.stopScan(),
            throwsA(TypeMatcher<BleServiceNotInitializedException>()));
      });
    });

    group('scanResults', () {
      late BleOperations bleOperations;
      late BleService bleService;
      late StreamController<List<ScanResult>> controller;

      setUp(() {
        controller = StreamController();
        bleOperations = MockBleOperations();
        when(bleOperations.scanResults).thenAnswer((_) => controller.stream);
        bleService = BleService(); // A new instance for every test
        bleService.initialize(operations: bleOperations);
      });

      tearDown(() {
        controller.close();
      });

      test('[scanResults] same as in operations.', () {
        fakeAsync((async) {
          List<ScanResult> list = List.from([
            ScanResult(
              device: BleDevice(
                id: "id",
                name: "name",
                operations: MockBleOperations(),
              ),
              rssi: 0,
              manufacturerData: Uint8List.fromList(List.empty()),
              serviceData: {},
              serviceUuids: [],
            )
          ]);

          List<ScanResult>? lastResult;
          bleService.scanResults.listen((event) => lastResult = event);

          controller.add(list);
          async.flushMicrotasks();
          expect(lastResult, containsAllInOrder(list));
        });
      });
    });

    group('state', () {
      late BleOperations bleOperations;
      late BleService bleService;
      final Duration operationDuration = Duration.zero;

      setUp(() async {
        bleOperations = FakeBleOperations(operationDuration);
        bleService = BleService(); // A new instance for every test
        await bleService.initialize(operations: bleOperations);
      });

      test(
          '[startScan] changes the [state] to scanning and [isScanning] is true.',
          () async {
        Future<List<BleServiceState>> states =
            bleService.state.take(2).toList();

        Duration timeout = Duration(seconds: 10);
        Future<void> scanning = bleService.startScan(timeout: timeout);
        expect(bleService.isScanning, isTrue);
        await scanning;
        expect(bleService.isScanning, isFalse);
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleServiceState.scanning,
            BleServiceState.idle,
          ])),
        );
      });

      test('[stopScan] changes [state] to idle and [isScanning] is false.',
          () async {
        Future<List<BleServiceState>> states =
            bleService.state.take(2).toList();

        bleService.startScan(timeout: Duration.zero);
        await bleService.stopScan();
        expect(bleService.isScanning, isFalse);
        await expectLater(
          states,
          completion(containsAllInOrder([
            BleServiceState.scanning,
            BleServiceState.idle,
          ])),
        );
      });
    });

    group('startScan', () {
      late BleOperations bleOperations;
      late BleService bleService;

      setUp(() {
        bleOperations = MockBleOperations();
        when(bleOperations.scanResults)
            .thenAnswer((_) => Stream<List<ScanResult>>.empty());
        bleService = BleService(); // A new instance for every test
        bleService.initialize(operations: bleOperations);
      });

      test('Start scan operation gets called once with the same parameters.',
          () async {
        Duration timeout = Duration(seconds: 1);
        List<Uuid> services = [Uuid("1"), Uuid("2")];
        bleService.startScan(timeout: timeout, withServices: services);
        verify(bleOperations.startScan(
                timeout: timeout, withServices: services))
            .called(1);
      });

      test(
          'BleOperationException in start operation, state is idle and [isScanning] is false.',
          () {
        Future<List<BleServiceState>> states =
            bleService.state.take(2).toList();

        Duration timeout = Duration(seconds: 10);
        BleOperationException exception =
            const BleOperationException("Just for testing...");
        when(bleOperations.startScan(timeout: timeout)).thenThrow(exception);
        expect(bleService.startScan(timeout: timeout),
            throwsA(TypeMatcher<BleOperationException>()));

        expect(bleService.isScanning, isFalse);
        expectLater(
          states,
          completion(containsAllInOrder([
            BleServiceState.scanning,
            BleServiceState.idle,
          ])),
        );
      });

      test('Throws if already scanning.', () {
        Duration timeout = Duration(milliseconds: 50);
        bleService.startScan(timeout: timeout);
        expect(bleService.startScan(timeout: Duration.zero),
            throwsA(TypeMatcher<BleOperationException>()));
      });

      test('On Android throws if is called 6 time in 30 seconds.', () async {
        Duration timeout = Duration.zero;
        for (int i = 0; i < 5; i++) {
          bleService.startScan(timeout: timeout);
          await bleService.stopScan();
        }
        expect(bleService.startScan(timeout: timeout),
            throwsA(TypeMatcher<BleOperationException>()));
      });

      test('Rethrows BleOperationException if start scan operation throws it.',
          () {
        Duration timeout = Duration.zero;
        String msg = "Just for testing...";
        BleOperationException exception = BleOperationException(msg);
        when(bleOperations.startScan(timeout: timeout)).thenThrow(exception);
        expect(
          bleService.startScan(timeout: timeout),
          throwsA(allOf(
            TypeMatcher<BleOperationException>(),
            predicate((BleOperationException e) => e.message == msg),
          )),
        );
      });
    });

    group('stopScan', () {
      late BleOperations bleOperations;
      late BleService bleService;

      setUp(() {
        bleOperations = MockBleOperations();
        when(bleOperations.scanResults)
            .thenAnswer((_) => Stream<List<ScanResult>>.empty());
        bleService = BleService(); // A new instance for every test.
        bleService.initialize(operations: bleOperations);
      });

      test('Stop scan operation gets called once.', () async {
        bleService.startScan(timeout: Duration.zero);
        await bleService.stopScan();
        verify(bleOperations.stopScan()).called(1);
      });

      test('If scan not started the stop operation is not called.', () async {
        await bleService.stopScan();
        verifyNever(bleOperations.stopScan());
      });

      test('Rethrows BleOperationException if stop scan operation throws it.',
          () {
        String msg = "Just for testing...";
        BleOperationException exception = BleOperationException(msg);
        when(bleOperations.stopScan()).thenThrow(exception);
        bleService.startScan(timeout: Duration.zero);
        expect(
          bleService.stopScan(),
          throwsA(allOf(
            TypeMatcher<BleOperationException>(),
            predicate((BleOperationException e) => e.message == msg),
          )),
        );
      });

      test(
          'BleOperationException in stop operation, state is idle and [isScanning] is false.',
          () {
        Future<List<BleServiceState>> states =
            bleService.state.take(2).toList();

        BleOperationException exception =
            const BleOperationException("Just for testing...");
        when(bleOperations.stopScan()).thenThrow(exception);

        bleService.startScan(timeout: Duration.zero);
        expect(bleService.stopScan(),
            throwsA(TypeMatcher<BleOperationException>()));

        expect(bleService.isScanning, isFalse);
        expectLater(
          states,
          completion(containsAllInOrder([
            BleServiceState.scanning,
            BleServiceState.idle,
          ])),
        );
      });
    });
  });
}
