import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/ble_service.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_hub.dart';

import 'ble_service_test.mocks.dart';
import 'weight_scale_hub_test.mocks.dart';

@GenerateMocks([BleService])
void main() {
  group('initialization', () {
    late WeightScaleHub hub;
    late BleOperations operations;
    late BleService bleService;

    setUp(() {
      bleService = MockBleService();
      operations = MockBleOperations();
      when((bleService as MockBleService).initialize())
          .thenAnswer((_) async {});
      when(bleService.scanResults).thenAnswer((_) => Stream.empty());
      hub = WeightScaleHub(bleService: bleService);
    });

    test('isInitialized is false before initializing', () {
      expect(hub.isInitialized, isFalse);
    });

    test('isInitialized if true after initializing', () async {
      await hub.initialize(operations: operations);
      expect(hub.isInitialized, isTrue);
    });

    test('[initialize] will call [initialize] on the [bleService].', () async {
      await hub.initialize(operations: operations);
      verify((bleService as MockBleService)
          .initialize(operations: operations, isAndroid: false));
    });

    test('[initialize] adds all known recognizer to [recognizers].', () async {
      await hub.initialize(operations: operations);
      expect(hub.recognizers.first, TypeMatcher<MiScale2Recognizer>());
    });

    test('when registering a new recognizer, it will be in the [recognizers]',
        () {
      MiScale2Recognizer recognizer = MiScale2Recognizer();
      hub.register(recognizer);
      expect(hub.recognizers.length, 1);
      expect(hub.recognizers.first, recognizer);
    });
  });

  group('search', () {
    late WeightScaleHub hub;
    late BleService bleService;
    late BleOperations operations;
    late Duration timeout;
    late StreamController<List<ScanResult>> streamController;

    setUp(() async {
      operations = MockBleOperations();
      bleService = MockBleService();
      streamController = StreamController();
      when(bleService.scanResults).thenAnswer((_) => streamController.stream);
      when((bleService as MockBleService).initialize())
          .thenAnswer((_) async {});
      when((bleService as MockBleService).startScan()).thenAnswer((_) async {});
      when(bleService.stopScan()).thenAnswer((_) async {});
      hub = WeightScaleHub(bleService: bleService);
      await hub.initialize(operations: operations);
      timeout = Duration(seconds: 1);
    });

    tearDown(() {
      streamController.close();
    });

    test('[search] calls [startScan].', () async {
      hub.search(timeout: timeout);
      verify(bleService.startScan(timeout: timeout));
    });

    test('recognized weight scales are emitted by [scales].', () async {
      String id = "00:00:00:00:00:00";
      hub.search(timeout: timeout);
      BleDevice device =
          BleDevice(id: id, name: "MIBCS", operations: operations);
      Future<List<WeightScale>> futureScales = hub.scales.take(1).first;
      streamController.add([
        ScanResult(
          device: device,
          manufacturerData: Uint8List(0),
          serviceData: {
            Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13)
          },
          serviceUuids: [],
          rssi: 0,
        ),
        ScanResult(
          device: BleDevice(id: id, name: "not MIBCS", operations: operations),
          manufacturerData: Uint8List(0),
          serviceData: {},
          serviceUuids: [],
          rssi: 0,
        )
      ]);
      List<WeightScale> scales = await futureScales;
      expect(scales.length, 1);
      expect(scales.first, TypeMatcher<MiScale2>());
    });

    test('[search] completes after [timeout].', () {
      fakeAsync((async) async {
        when(bleService.startScan(timeout: timeout))
            .thenAnswer((_) => Future.delayed(timeout));
        await hub.search(timeout: timeout);
        expect(async.elapsed > timeout, isTrue);
      });
    });

    test('[search] completes when [stopSearch] is called.', () {
      fakeAsync((async) async {
        Future<void> searching = hub.search(timeout: timeout);
        async.elapse(timeout * 0.8);
        await hub.stopSearch();
        await searching;
        expect(async.elapsed < timeout, isTrue);
      });
    });

    test('[stopSearch] calls [stopScan]', () async {
      await hub.search();
      await hub.stopSearch();
      verify(bleService.stopScan());
    });
  });
}