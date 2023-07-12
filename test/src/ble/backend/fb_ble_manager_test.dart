import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:flutter_blue_plus/gen/flutterblueplus.pbserver.dart' as protos;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/backend/fb_backend.dart';
import 'package:weight_scale/src/ble/ble.dart';

import 'fb_ble_device_test.dart';

@GenerateNiceMocks([MockSpec<fb.FlutterBluePlus>()])
import 'fb_ble_manager_test.mocks.dart';

void main() {
  late MockFlutterBluePlus flutterBlue;
  late FbConversion conversion;
  late StreamController<List<fb.ScanResult>> resultsController;
  late BleManager manager;

  setUp(() {
    flutterBlue = MockFlutterBluePlus();
    conversion = FbConversion();
    resultsController = StreamController.broadcast();
    when(flutterBlue.scanResults).thenAnswer((_) => resultsController.stream);
    manager = FbBleManager(flutterBlue, conversion);
  });

  group('connectedDevices', () {
    test('Should return same devices as flutter blue When called', () async {
      final devices = [
        fb.BluetoothDevice.fromProto(
          protos.BluetoothDevice(name: 'name1', remoteId: 'id1'),
        ),
        fb.BluetoothDevice.fromProto(
          protos.BluetoothDevice(name: 'name2', remoteId: 'id2'),
        ),
      ];
      when(flutterBlue.connectedDevices).thenAnswer((_) async => devices);
      expect(
        await manager.connectedDevices,
        devices.map((device) => conversion.toBleDevice(device)).toSet(),
      );
    });

    test('Should throw ble exception When flutter blue fails', () async {
      final exception = Exception('exception');
      when(flutterBlue.connectedDevices).thenThrow(exception);
      expect(
        manager.connectedDevices,
        throwsBleException(exception: exception),
      );
    });
  });

  group('scanResults', () {
    test('Should be a broadcast stream', () {
      expect(manager.scanResults.isBroadcast, isTrue);
    });

    test('Should emit same results as flutter blue', () async {
      await manager.initialize();
      final result1 = fb.ScanResult.fromProto(protos.ScanResult(
        device: protos.BluetoothDevice(name: 'name1', remoteId: 'id1'),
      ));
      final result2 = fb.ScanResult.fromProto(protos.ScanResult(
        device: protos.BluetoothDevice(name: 'name2', remoteId: 'id2'),
      ));
      final results = manager.scanResults.take(2).toList();
      resultsController.add([result1]);
      resultsController.add([result1, result2]);
      expect(await results, [
        [conversion.toScanResult(result1)],
        [conversion.toScanResult(result1), conversion.toScanResult(result2)],
      ]);
    });
  });

  group('isInitialized', () {
    test('Should be false When not yet initialized', () {
      expect(manager.isInitialized, isFalse);
    });

    test('Should be true When done initializing', () async {
      await manager.initialize();
      expect(manager.isInitialized, isTrue);
    });

    test('Should not do anything When called a second time', () async {
      await manager.initialize();
      manager.initialize();
      await flushMicroTasks();
      expect(manager.isInitialized, isTrue);
    });

    test('Should be false When scan results on flutter throws', () {
      final exception = Exception('exception');
      when(flutterBlue.scanResults).thenThrow(exception);
      expect(manager.initialize(), throwsBleException(exception: exception));
      expect(manager.isInitialized, isFalse);
    });
  });

  group('initialize', () {
    test(
        'Should not call scan results on flutter blue When is not yet initialized',
        () {
      verifyNever(flutterBlue.scanResults);
    });

    test('Should call once scan results on flutter blue When initializing',
        () async {
      await manager.initialize();
      verify(flutterBlue.scanResults);
    });

    test(
        'Should call only once scan results on flutter blue When initialized multiple times',
        () async {
      await manager.initialize();
      await manager.initialize();
      verify(flutterBlue.scanResults).called(1);
    });

    test('Should throw a ble exception When scan results on flutter throws',
        () {
      final exception = Exception('exception');
      when(flutterBlue.scanResults).thenThrow(exception);
      expect(manager.initialize(), throwsBleException(exception: exception));
    });
  });

  group('scanning', () {
    const timeout = Duration(seconds: 10);
    late Completer scanCompleter;

    setUp((() async {
      scanCompleter = Completer();
      when(flutterBlue.startScan(
        timeout: timeout,
        withServices: anyNamed('withServices'),
      )).thenAnswer((_) => scanCompleter.future);
      when(flutterBlue.stopScan()).thenAnswer((_) async {
        if (!scanCompleter.isCompleted) {
          return scanCompleter.complete();
        }
      });
      await manager.initialize();
    }));

    tearDown(() => manager.stopScan());

    group('isScanning', () {
      test('Should be set to false initially', () async {
        manager = FbBleManager(flutterBlue, conversion);
        expect(manager.isScanning, isFalse);
        await manager.initialize(); // Must be initialized for tear down.
      });

      test('Should still be false When done initializing', () async {
        expect(manager.isScanning, isFalse);
      });

      test('Should be true When scan has started', () async {
        manager.startScan(timeout: timeout);
        await flushMicroTasks();
        expect(manager.isScanning, isTrue);
      });

      test('Should be false When scan gets stopped', () async {
        manager.startScan(timeout: timeout);
        await manager.stopScan();
        expect(manager.isScanning, isFalse);
      });

      test('Should be false When scan times out', () {
        fakeAsync((async) {
          when(flutterBlue.startScan(timeout: timeout, withServices: []))
              .thenAnswer((_) async => await Future.delayed(timeout));
          manager.startScan(timeout: timeout);
          async.elapse(timeout);
          async.flushMicrotasks();
          expect(manager.isScanning, isFalse);
        });
      });

      test('Should be false When starting the scan fails', () async {
        const timeout = Duration(seconds: 10);
        final exception = Exception('exception');
        when(flutterBlue.startScan(timeout: timeout)).thenThrow(exception);
        expect(
          manager.startScan(timeout: timeout),
          throwsBleException(exception: exception),
        );
        expect(manager.isScanning, isFalse);
      });

      test('Should be false When stopping the scan fails', () async {
        const timeout = Duration(seconds: 10);
        final exception = Exception('exception');
        when(flutterBlue.stopScan()).thenThrow(exception);
        manager.startScan(timeout: timeout);
        await flushMicroTasks(duration: const Duration(milliseconds: 1));
        expect(manager.stopScan(), throwsBleException(exception: exception));
        expect(manager.isScanning, isFalse);
      });
    });

    group('startScan', () {
      test('Should complete When the timeout is over', () {
        fakeAsync((async) {
          var completed = false;
          when(flutterBlue.startScan(timeout: timeout, withServices: []))
              .thenAnswer((_) async => await Future.delayed(timeout));
          manager.startScan(timeout: timeout).then((_) => completed = true);
          async.elapse(timeout);
          async.flushMicrotasks();
          expect(completed, isTrue);
        });
      });

      test('Should make correct call to flutter blue When called', () async {
        const services = [
          Uuid('bccc9476-0de5-462d-8ef7-9b12a6391360'),
          Uuid('f77ce746-0be2-4b4f-a924-6c24ca915c3a'),
        ];
        manager.startScan(timeout: timeout, withServices: services);
        await flushMicroTasks();
        verify(flutterBlue.startScan(
          timeout: timeout,
          withServices: services.map((u) => conversion.fromUuid(u)).toList(),
        ));
      });

      test('Should throw a ble exception When is already scanning', () {
        final exception = Exception('exception');
        when(flutterBlue.startScan(timeout: timeout)).thenThrow(exception);
        expect(
          manager.startScan(timeout: timeout),
          throwsBleException(exception: exception),
        );
      });
    });

    group('stopScan', () {
      test('Should call stop scan on flutter blue instance When called',
          () async {
        manager.startScan(timeout: timeout);
        await flushMicroTasks();
        await manager.stopScan();
        verify(flutterBlue.stopScan());
      });

      test(
          'Should not call stop scan on flutter blue instance When not currently scanning',
          () async {
        await manager.stopScan();
        verifyNever(flutterBlue.stopScan());
      });

      test('Should throw a ble exception When stopping the scan fails',
          () async {
        final exception = Exception('exception');
        when(flutterBlue.stopScan()).thenThrow(exception);
        manager.startScan(timeout: timeout);
        await flushMicroTasks();
        expect(manager.stopScan(), throwsBleException(exception: exception));
      });
    });
  });
}
