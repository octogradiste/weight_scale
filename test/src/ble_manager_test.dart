import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/src/backend/fb_ble_manager.dart';
import 'package:weight_scale/src/backend/fb_conversion.dart';

import 'ble_manager_test.mocks.dart';
import 'fake_ble_device.dart';

@GenerateMocks([fb.FlutterBlue])
void main() {
  group('BleService', () {
    group('initialize', () {
      late FbConversion conversion;
      late BleManager bleManager;
      late MockFlutterBlue flutterBlue;

      setUp(() async {
        conversion = FbConversion();
        flutterBlue = MockFlutterBlue();
        when(flutterBlue.scanResults).thenAnswer((_) => const Stream.empty());
        when(flutterBlue.startScan()).thenAnswer((_) async {});
        when(flutterBlue.stopScan()).thenAnswer((_) async {});
        bleManager = FbBleManager(flutterBlue, conversion);
        await bleManager.initialize();
      });

      test('[scanResults] was called once on [bleOperations].', () {
        verify(flutterBlue.scanResults).called(1);
      });

      test('[isScanning] is initially false.', () {
        expect(bleManager.isScanning, isFalse);
      });

      test('[scanResults] is a broadcast stream.', () {
        expect(bleManager.scanResults.isBroadcast, isTrue);
      });

      test('[isInitialized] is true.', () {
        expect(bleManager.isInitialized, isTrue);
      });

      test('[isInitialized] is false before initialization.', () {
        bleManager = FbBleManager(flutterBlue, conversion);
        expect(bleManager.isInitialized, isFalse);
      });

      test('[startScan] throws if not initialized.', () {
        bleManager = FbBleManager(flutterBlue, conversion);
        expect(
          () => bleManager.startScan(timeout: Duration.zero),
          throwsA(const TypeMatcher<BleException>()),
        );
      });

      test('[stopScan] throws if not initialized.', () {
        bleManager = FbBleManager(flutterBlue, conversion);
        expect(
          () => bleManager.stopScan(),
          throwsA(const TypeMatcher<BleException>()),
        );
      });
    });

    group('scanResults', () {
      late FbConversion conversion;
      late MockFlutterBlue flutterBlue;
      late BleManager bleService;
      late StreamController<List<fb.ScanResult>> controller;

      setUp(() async {
        conversion = FbConversion();
        flutterBlue = MockFlutterBlue();
        controller = StreamController();
        when(flutterBlue.scanResults).thenAnswer((_) => controller.stream);
        bleService = FbBleManager(flutterBlue, conversion);
        await bleService.initialize();
      });

      tearDown(() {
        controller.close();
      });

      test('[scanResults] same as in operations.', () async {
        List<ScanResult> list = List.from([
          ScanResult(
            device: FakeBleDevice(
              id: "id",
              name: "name",
            ),
            rssi: 0,
            serviceData: const {},
            serviceUuids: const [],
          )
        ]);

        final result = bleService.scanResults.first;

        controller.add(
          list.map((s) => conversion.fromScanResult(s)).toList(),
        );
        expectLater((await result).first.device.id, "id");
        expectLater((await result).first.device.name, "name");
      });
    });

    group('isScanning', () {
      late BleManager bleManager;
      late MockFlutterBlue flutterBlue;

      setUp(() async {
        flutterBlue = MockFlutterBlue();
        when(flutterBlue.scanResults).thenAnswer((_) => const Stream.empty());
        when(flutterBlue.startScan(timeout: anyNamed('timeout'))).thenAnswer(
          (real) =>
              Future.delayed(real.namedArguments[const Symbol('timeout')]),
        );
        when(flutterBlue.stopScan()).thenAnswer((_) async {});
        bleManager = FbBleManager(flutterBlue, FbConversion());
        await bleManager.initialize();
      });

      test('[isScanning] is initially false', () {
        expect(bleManager.isScanning, isFalse);
      });

      test('[startScan] sets [isScanning] to true.', () async {
        Duration timeout = const Duration(seconds: 10);
        bleManager.startScan(timeout: timeout);
        await Future.delayed(Duration.zero);
        expect(bleManager.isScanning, isTrue);
      });

      test('[stopScan] sets [isScanning] to false.', () async {
        bleManager.startScan(timeout: Duration.zero);
        await bleManager.stopScan();
        expect(bleManager.isScanning, isFalse);
      });
    });

    group('startScan', () {
      late FbConversion conversion;
      late MockFlutterBlue flutterBlue;
      late BleManager bleManager;

      setUp(() async {
        conversion = FbConversion();
        flutterBlue = MockFlutterBlue();
        when(flutterBlue.scanResults).thenAnswer(
          (_) => const Stream<List<fb.ScanResult>>.empty(),
        );
        bleManager = FbBleManager(flutterBlue, conversion);
        await bleManager.initialize();
      });

      test('Start scan operation gets called once with the same parameters.',
          () async {
        Duration timeout = const Duration(seconds: 1);
        List<Uuid> services = [
          const Uuid("49d74e06-b33a-4333-8d2a-65b9b2324774"),
          const Uuid("8d6c6107-9d62-4354-92aa-a4118ea2957f"),
        ];
        when(flutterBlue.startScan(
          timeout: timeout,
          withServices: anyNamed('withServices'),
        )).thenAnswer(
          (real) => Future.delayed(timeout),
        );
        bleManager.startScan(timeout: timeout, withServices: services);
        verify(flutterBlue.startScan(
          timeout: timeout,
          withServices: services.map((u) => conversion.fromUuid(u)).toList(),
        )).called(1);
      });

      test(
          'BleException in start operation, state is idle and [isScanning] is false.',
          () {
        Duration timeout = const Duration(seconds: 10);
        const exception = BleException("Just for testing...");
        when(flutterBlue.startScan(timeout: timeout)).thenThrow(exception);
        expect(
          bleManager.startScan(timeout: timeout),
          throwsA(const TypeMatcher<BleException>()),
        );

        expect(bleManager.isScanning, isFalse);
      });

      test('Throws if already scanning.', () {
        Duration timeout = const Duration(milliseconds: 50);
        when(flutterBlue.startScan(timeout: timeout)).thenAnswer(
          (real) => Future.delayed(timeout),
        );
        bleManager.startScan(timeout: timeout);
        expect(
          bleManager.startScan(timeout: Duration.zero),
          throwsA(const TypeMatcher<BleException>()),
        );
      });

      test('Rethrows BleOperationException if start scan operation throws it.',
          () {
        Duration timeout = Duration.zero;
        String msg = "Just for testing...";
        final exception = BleException(msg);
        when(flutterBlue.startScan(timeout: timeout)).thenThrow(exception);
        expect(
          bleManager.startScan(timeout: timeout),
          throwsA(allOf(
            const TypeMatcher<BleException>(),
            predicate((BleException e) => e.exception == exception),
          )),
        );
      });
    });

    group('stopScan', () {
      late MockFlutterBlue flutterBlue;
      late BleManager bleManager;

      setUp(() async {
        flutterBlue = MockFlutterBlue();
        when(flutterBlue.scanResults)
            .thenAnswer((_) => const Stream<List<fb.ScanResult>>.empty());
        when(flutterBlue.startScan(
          timeout: anyNamed('timeout'),
          withServices: anyNamed('withServices'),
        )).thenAnswer(
          (real) => Future.delayed(
            real.namedArguments[const Symbol('timeout')],
          ),
        );
        when(flutterBlue.stopScan()).thenAnswer((_) async {});
        bleManager = FbBleManager(flutterBlue, FbConversion());
        await bleManager.initialize();
      });

      test('Stop scan operation gets called once.', () async {
        bleManager.startScan(timeout: Duration.zero);
        await bleManager.stopScan();
        verify(flutterBlue.stopScan()).called(1);
      });

      test('If scan not started the stop operation is not called.', () async {
        await bleManager.stopScan();
        verifyNever(flutterBlue.stopScan());
      });

      test('Rethrows BleOperationException if stop scan operation throws it.',
          () {
        String msg = "Just for testing...";
        final exception = BleException(msg);
        when(flutterBlue.stopScan()).thenThrow(exception);
        bleManager.startScan(timeout: Duration.zero);
        expect(
          bleManager.stopScan(),
          throwsA(allOf(
            const TypeMatcher<BleException>(),
            predicate((BleException e) => e.exception == exception),
          )),
        );
      });

      test('BleException in stop operation, [isScanning] is false.', () {
        const exception = BleException("Just for testing...");
        when(flutterBlue.stopScan()).thenThrow(exception);

        bleManager.startScan(timeout: Duration.zero);
        expect(
          bleManager.stopScan(),
          throwsA(const TypeMatcher<BleException>()),
        );

        expect(bleManager.isScanning, isFalse);
      });
    });
  });
}
