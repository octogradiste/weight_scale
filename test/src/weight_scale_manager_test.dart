import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

import 'ble/backend/fb_ble_device_test.dart';
import 'fake_ble_device.dart';
@GenerateNiceMocks([MockSpec<BleManager>()])
import 'weight_scale_manager_test.mocks.dart';

void main() {
  late StreamController<List<ScanResult>> scanController;
  late MockBleManager bleManager;
  late WeightScaleManager manager;

  setUp(() {
    scanController = StreamController.broadcast();
    bleManager = MockBleManager();
    when(bleManager.scanResults).thenAnswer((_) => scanController.stream);
    when(bleManager.initialize()).thenAnswer((_) async {});
    when(bleManager.startScan()).thenAnswer((_) async {});
    when(bleManager.stopScan()).thenAnswer((_) async {});
    manager = WeightScaleManager(manager: bleManager);
  });

  tearDown(() {
    scanController.close();
  });

  group('isInitialized', () {
    test('Should be false When not yet initialized', () {
      expect(manager.isInitialized, isFalse);
    });

    test('Should be true When has initialized', () async {
      await manager.initialize();
      expect(manager.isInitialized, isTrue);
    });

    test('Should be true When initialized multiple times', () async {
      await manager.initialize();
      await manager.initialize();
      expect(manager.isInitialized, isTrue);
    });

    test('Should be false When initialize on the ble device throws', () {
      when(bleManager.initialize()).thenThrow(const BleException('test'));
      expect(
        manager.initialize(),
        throwsWeightScaleException(message: equals('test')),
      );
      expect(manager.isInitialized, isFalse);
    });

    test('Should be false When scan results of the ble device throws', () {
      when(bleManager.scanResults).thenThrow(const BleException('test'));
      expect(
        manager.initialize(),
        throwsWeightScaleException(message: equals('test')),
      );
      expect(manager.isInitialized, isFalse);
    });
  });

  group('isScanning', () {
    setUp(() async {
      await manager.initialize();
    });

    tearDown(() {
      manager.stopScan();
    });

    test('Should be false When scan has not started yet', () {
      expect(manager.isScanning, isFalse);
    });

    test('Should be true When scan has been started', () async {
      manager.startScan();
      expect(manager.isScanning, isTrue);
    });

    test('Should be false When starting the scan has failed', () {
      when(bleManager.startScan(timeout: anyNamed('timeout')))
          .thenThrow(const BleException('test'));

      expect(
        manager.startScan(),
        throwsWeightScaleException(message: equals('test')),
      );
      expect(manager.isScanning, isFalse);
    });
  });

  group('recognizers', () {
    test('Should be empty When not yet initialized', () {
      expect(manager.recognizers, isEmpty);
    });
  });

  group('initialize', () {
    test('Should call initialize on the ble device When called', () async {
      await manager.initialize();
      verify(bleManager.initialize());
    });

    test('Should add all recognizers to the recognizers list When called',
        () async {
      await manager.initialize();
      expect(manager.recognizers.length, 3);
    });

    test(
        'Should not recall initialize on the ble manager When called a second time',
        () async {
      await manager.initialize();
      await manager.initialize();
      verify(bleManager.initialize()).called(1);
    });

    test(
        'Should throw a weight scale exception When scan results of the ble manager throws',
        () {
      when(bleManager.scanResults).thenThrow(const BleException('test'));
      expect(
        manager.initialize(),
        throwsWeightScaleException(message: equals('test')),
      );
    });
  });

  group('register', () {
    test('Should add recognizer to the list', () {
      MiScale2Recognizer recognizer = MiScale2Recognizer();
      manager.register(recognizer);
      expect(manager.recognizers.length, 1);
      expect(manager.recognizers.first, recognizer);
    });
  });

  group('startScan', () {
    late Duration timeout;

    setUp(() async {
      timeout = const Duration(seconds: 1);
      await manager.initialize();
    });

    test('Should throw a weight scale exception When is not yet initialized',
        () {
      manager = WeightScaleManager(manager: bleManager);
      expect(
        manager.startScan(timeout: timeout),
        throwsWeightScaleException(message: isNotEmpty),
      );
      verifyNever(bleManager.startScan(timeout: anyNamed('timeout')));
    });

    test('Should call start scan on ble device with the same timeout parameter',
        () {
      manager.startScan(timeout: timeout);
      verify(bleManager.startScan(timeout: timeout));
    });

    test('Should recognize MIBFS and add it to the scales stream', () async {
      const id = "00:00:00:00:00:00";
      final device = FakeBleDevice(id: id, name: "MIBFS");

      manager.startScan(timeout: timeout);

      final futureScales = manager.scales.first;
      scanController.add([
        ScanResult(
          device: device,
          serviceData: {
            const Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13),
          },
          serviceUuids: const [],
          rssi: 0,
        ),
        ScanResult(
          device: FakeBleDevice(id: id, name: "not MIBCS"),
          serviceData: const {},
          serviceUuids: const [],
          rssi: 0,
        )
      ]);

      List<WeightScale> scales = await futureScales;
      expect(scales.length, 1);
      expect(scales.first, const TypeMatcher<MiScale2>());
    });

    test('Should complete When timeout is reached', () {
      fakeAsync((async) async {
        when(bleManager.startScan(timeout: timeout))
            .thenAnswer((_) => Future.delayed(timeout));
        await manager.startScan(timeout: timeout);
        expect(async.elapsed > timeout, isTrue);
      });
    });

    test('Should complete When stop scan is called', () {
      fakeAsync((async) async {
        final searching = manager.startScan(timeout: timeout);
        async.elapse(timeout * 0.8);
        await manager.stopScan();
        await searching;
        expect(async.elapsed < timeout, isTrue);
      });
    });

    test(
        'Should throw a weight scale exception When the ble manager throws a ble exception',
        () {
      when(bleManager.startScan(timeout: timeout))
          .thenThrow(const BleException('test'));
      expect(
        manager.startScan(timeout: timeout),
        throwsWeightScaleException(message: equals('test')),
      );
    });

    test('Should restart scan When called during an ongoing scan', () async {
      manager.startScan(timeout: timeout);
      await flushMicroTasks();
      manager.startScan(timeout: timeout);
      await flushMicroTasks();
      verify(bleManager.startScan(timeout: timeout)).called(2);
      verify(bleManager.stopScan());
    });
  });

  group('stopScan', () {
    setUp(() async {
      await manager.initialize();
    });

    test('Should throw a weight scale exception When is not yet initialized',
        () {
      manager = WeightScaleManager(manager: bleManager);
      expect(
        manager.stopScan(),
        throwsWeightScaleException(message: isNotEmpty),
      );
      verifyNever(bleManager.stopScan());
    });

    test('Should call stop scan on the ble manager When called', () async {
      await manager.startScan();
      await manager.stopScan();
      verify(bleManager.stopScan());
    });

    test(
        'Should not call stop scan on the ble manager When not currently scanning',
        () async {
      await manager.stopScan();
      verifyNever(bleManager.stopScan());
    });

    test(
        'Should throw a weight scale exception When the ble manager throws a ble exception',
        () async {
      when(bleManager.stopScan()).thenThrow(const BleException('test'));
      manager.startScan();
      await flushMicroTasks();
      expect(
        manager.stopScan(),
        throwsWeightScaleException(message: equals('test')),
      );
    });
  });
}

Matcher throwsWeightScaleException({required Matcher message}) {
  return throwsA(
    isA<WeightScaleException>().having((e) => e.message, 'message', message),
  );
}
