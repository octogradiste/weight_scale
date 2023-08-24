import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/backend/flutter_blue_plus_wrapper.dart';
import 'package:weight_scale/weight_scale.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';

@GenerateNiceMocks([MockSpec<FlutterBluePlusWrapper>()])
import 'weight_scale_manager_test.mocks.dart';

void main() {
  late StreamController<List<ScanResult>> scanController;
  late MockFlutterBluePlusWrapper wrapper;
  late WeightScaleManager manager;

  setUp(() {
    scanController = StreamController.broadcast();
    wrapper = MockFlutterBluePlusWrapper();
    when(wrapper.scanResults).thenAnswer((_) => scanController.stream);
    when(wrapper.startScan()).thenAnswer((_) async {});
    when(wrapper.stopScan()).thenAnswer((_) async {});
    manager = WeightScaleManager.instance(wrapper: wrapper);
  });

  tearDown(() {
    scanController.close();
  });

  group('instance', () {
    test('Should return the same instance When called multiple times', () {
      expect(
        WeightScaleManager.instance(),
        equals(WeightScaleManager.instance()),
      );
    });
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

    test('Should be false When scan results of the ble device throws', () {
      when(wrapper.scanResults).thenThrow(Exception('test'));
      expect(
        manager.initialize(),
        throwsWeightScaleException(message: isNotEmpty),
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
      when(wrapper.startScan(timeout: anyNamed('timeout')))
          .thenThrow(Exception('test'));

      expect(
        manager.startScan(),
        throwsWeightScaleException(message: isNotEmpty),
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
    test('Should add all recognizers to the recognizers list When called',
        () async {
      await manager.initialize();
      expect(manager.recognizers.length, 3);
    });

    test(
        'Should throw a weight scale exception When scan results of the ble manager throws',
        () {
      when(wrapper.scanResults).thenThrow(Exception('test'));
      expect(
        manager.initialize(),
        throwsWeightScaleException(message: isNotEmpty),
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
      manager = WeightScaleManager.instance(wrapper: wrapper);
      expect(
        manager.startScan(timeout: timeout),
        throwsWeightScaleException(message: isNotEmpty),
      );
      verifyNever(wrapper.startScan(timeout: anyNamed('timeout')));
    });

    test('Should call start scan on ble device with the same timeout parameter',
        () {
      manager.startScan(timeout: timeout);
      verify(wrapper.startScan(timeout: timeout));
    });

    test('Should recognize MIBFS and add it to the scales stream', () async {
      const id = "00:00:00:00:00:00";

      manager.startScan(timeout: timeout);

      final futureScales = manager.scales.first;
      scanController.add([
        ScanResult(
          deviceInformation: const BleDeviceInformation(id: id, name: "MIBFS"),
          serviceData: {
            const Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13),
          },
          serviceUuids: const [],
          rssi: 0,
        ),
        const ScanResult(
          deviceInformation: BleDeviceInformation(id: id, name: "not MIBCS"),
          serviceData: {},
          serviceUuids: [],
          rssi: 0,
        )
      ]);

      List<WeightScale> scales = await futureScales;
      expect(scales.length, 1);
      expect(scales.first, const TypeMatcher<MiScale2>());
    });

    test('Should complete When timeout is reached', () {
      fakeAsync((async) async {
        when(wrapper.startScan(timeout: timeout))
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
      when(wrapper.startScan(timeout: timeout)).thenThrow(Exception('test'));
      expect(
        manager.startScan(timeout: timeout),
        throwsWeightScaleException(message: isNotEmpty),
      );
    });

    test('Should restart scan When called during an ongoing scan', () async {
      manager.startScan(timeout: timeout);
      await flushMicroTasks();
      manager.startScan(timeout: timeout);
      await flushMicroTasks();
      verify(wrapper.startScan(timeout: timeout)).called(2);
      verify(wrapper.stopScan());
    });
  });

  group('stopScan', () {
    setUp(() async {
      await manager.initialize();
    });

    test('Should throw a weight scale exception When is not yet initialized',
        () {
      manager = WeightScaleManager.instance(wrapper: wrapper);
      expect(
        manager.stopScan(),
        throwsWeightScaleException(message: isNotEmpty),
      );
      verifyNever(wrapper.stopScan());
    });

    test('Should call stop scan on the ble manager When called', () async {
      await manager.startScan();
      await manager.stopScan();
      verify(wrapper.stopScan());
    });

    test(
        'Should not call stop scan on the ble manager When not currently scanning',
        () async {
      await manager.stopScan();
      verifyNever(wrapper.stopScan());
    });

    test(
        'Should throw a weight scale exception When the ble manager throws a ble exception',
        () async {
      when(wrapper.stopScan()).thenThrow(Exception('test'));
      manager.startScan();
      await flushMicroTasks();
      expect(
        manager.stopScan(),
        throwsWeightScaleException(message: isNotEmpty),
      );
    });
  });
}

Future<void> flushMicroTasks() => Future.delayed(Duration.zero);

Matcher throwsWeightScaleException({required Matcher message}) {
  return throwsA(
    isA<WeightScaleException>().having((e) => e.message, 'message', message),
  );
}
