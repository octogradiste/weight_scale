import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'package:weight_scale/src/scales/mi_scale_2.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_hub.dart';

import 'fake_ble_device.dart';
import 'weight_scale_hub_test.mocks.dart';

@GenerateMocks([BleManager])
void main() {
  group('initialization', () {
    late WeightScaleHub hub;
    late MockBleManager bleManager;

    setUp(() {
      bleManager = MockBleManager();
      when(bleManager.initialize()).thenAnswer((_) async {});
      when(bleManager.scanResults).thenAnswer((_) => const Stream.empty());
      hub = WeightScaleHub(manager: bleManager);
    });

    test('isInitialized is false before initializing', () {
      expect(hub.isInitialized, isFalse);
    });

    test('isInitialized if true after initializing', () async {
      await hub.initialize();
      expect(hub.isInitialized, isTrue);
    });

    test('[initialize] will call [initialize] on the [bleService].', () async {
      await hub.initialize();
      verify(bleManager.initialize());
    });

    test('[initialize] adds all known recognizer to [recognizers].', () async {
      await hub.initialize();
      expect(hub.recognizers.first, const TypeMatcher<MiScale2Recognizer>());
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
    late MockBleManager bleManager;
    late Duration timeout;
    late StreamController<List<ScanResult>> streamController;

    setUp(() async {
      bleManager = MockBleManager();
      streamController = StreamController();
      when(bleManager.scanResults).thenAnswer((_) => streamController.stream);
      when(bleManager.initialize()).thenAnswer((_) async {});
      when(bleManager.startScan()).thenAnswer((_) async {});
      when(bleManager.stopScan()).thenAnswer((_) async {});
      hub = WeightScaleHub(manager: bleManager);
      await hub.initialize();
      timeout = const Duration(seconds: 1);
    });

    tearDown(() {
      streamController.close();
    });

    test('[search] calls [startScan].', () async {
      hub.search(timeout: timeout);
      verify(bleManager.startScan(timeout: timeout));
    });

    test('recognized weight scales are emitted by [scales].', () async {
      String id = "00:00:00:00:00:00";
      hub.search(timeout: timeout);
      BleDevice device = FakeBleDevice(id: id, name: "MIBFS");
      Future<List<WeightScale>> futureScales = hub.scales.take(1).first;
      streamController.add([
        ScanResult(
          device: device,
          serviceData: {
            const Uuid("00000000-0000-0000-0000-000000000000"): Uint8List(13)
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

    test('[search] completes after [timeout].', () {
      fakeAsync((async) async {
        when(bleManager.startScan(timeout: timeout))
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
      verify(bleManager.stopScan());
    });
  });
}
