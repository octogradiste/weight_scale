import 'dart:async';

import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:climb_scale/utils/logger.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/ble.dart' as ble;
import 'package:weight_scale/scale.dart' hide ScanResult;

import 'weight_scale_service_test.mocks.dart';

Future<void> flushMicroTasks() async {
  await Future.delayed(const Duration(milliseconds: 2));
}

@GenerateMocks([WeightScaleManager, WeightScale])
void main() {
  Logger.logLevel = LogLevel.none;
  group('WeightScaleService', () {
    late StreamController<List<WeightScale>> scaleController;

    late MockWeightScaleHub hub;
    late IWeightScaleService service;

    setUp(() {
      scaleController = StreamController();
      hub = MockWeightScaleHub();

      when(hub.initialize()).thenAnswer((_) async {});
      when(hub.scales).thenAnswer((_) => scaleController.stream);

      service = WeightScaleService(hub);
    });

    tearDown(() {
      scaleController.close();
    });

    group('Initialization', () {
      group('isInitialized', () {
        test('Should return false When has not been initialized yet', () {
          expect(service.isInitialized, isFalse);
        });

        test('Should return true When has been initialized', () async {
          await service.initialize();
          expect(service.isInitialized, isTrue);
        });
      });

      group('initialize', () {
        test('Should call initialize method of hub When is called', () async {
          await service.initialize();
          verify(hub.initialize());
        });

        test('Should not call the hub When called a second time', () async {
          await service.initialize();
          await service.initialize();
          verify(hub.initialize()).called(1);
        });
      });
    });

    group('Scanning', () {
      late Duration timeout;

      setUp(() async {
        await service.initialize();
        Completer completer = Completer();
        timeout = const Duration(seconds: 100);
        when(hub.startScan(timeout: anyNamed('timeout'))).thenAnswer((_) {
          completer = Completer();
          Future.delayed(timeout).then((_) {
            if (!completer.isCompleted) completer.complete();
          });
          return completer.future;
        });
        when(hub.stopScan()).thenAnswer((_) async {
          if (!completer.isCompleted) completer.complete();
        });
      });

      tearDown(() async {
        service.stopScan();
      });

      group('isScanning', () {
        test('Should be false When has not started a scan yet', () {
          expect(service.isScanning, isFalse);
        });

        test('Should be true When is currently scanning', () {
          service.startScan();
          expect(service.isScanning, isTrue);
        });

        test('Should be false again When the scan is stopped', () async {
          service.startScan();
          await service.stopScan();
          expect(service.isScanning, isFalse);
        });

        test('Should be false When error is thrown during scan', () {
          Exception exception = Exception('something bad happen :(');
          when(hub.startScan(timeout: anyNamed('timeout'))).thenThrow(exception);
          expect(service.startScan(), throwsException);
          expect(service.isScanning, isFalse);
        });
      });

      group('startScan', () {
        test('Should call start scan on hub When is called', () {
          fakeAsync((async) {
            service.startScan(timeout: timeout);
            async.elapse(const Duration(seconds: 1));
            verify(hub.startScan(timeout: timeout));
          });
        });

        test('Should return from future When scan is completed', () async {
          fakeAsync((async) {
            Completer completer = Completer();
            service.startScan().then((_) => completer.complete());
            async.elapse(const Duration(seconds: 90));
            expect(completer.isCompleted, isFalse);
            async.elapse(const Duration(seconds: 15));
            expect(completer.isCompleted, isTrue);
          });
        });

        test('Should return from future When scan is stopped', () async {
          Completer completer = Completer();
          service.startScan().then((_) => completer.complete());
          expect(completer.isCompleted, isFalse);
          await service.stopScan();
          await flushMicroTasks();
          expect(completer.isCompleted, isTrue);
        });

        test('Should fist stop scan on hub When called a second time',
            () async {
          service.startScan();
          service.startScan();
          await flushMicroTasks();
          verify(hub.stopScan());
        });
      });

      group('stopScan', () {
        test('Should stop the search on the hub When called', () async {
          await service.stopScan();
          verify(hub.stopScan());
        });
      });

      group('results', () {
        test('Should be a broadcast stream', () {
          expect(service.results.isBroadcast, isTrue);
        });

        test('Should stream the same scales as the hub', () async {
          MockWeightScale scale1 = MockWeightScale();
          MockWeightScale scale2 = MockWeightScale();
          when(scale1.name).thenReturn('scale1');
          when(scale2.name).thenReturn('scale2');
          List<List<WeightScale>> scales = [
            [scale1, scale2],
            [scale1]
          ];

          var results = service.results.take(2).toList();
          for (var list in scales) {
            scaleController.add(list);
          }

          expect(
            await results,
            containsAllInOrder(
              scales.map(
                (list) => list.map(
                  (scale) => ScanResult.fromWeightScale(
                    scale,
                    'Unknown',
                    'assets/image/scale/UnknownScale.png',
                  ),
                ),
              ),
            ),
          );
        });
      });
    });

    group('Connection', () {
      late StreamController<Weight> weightController;
      late StreamController<ble.BleDeviceState> stateController;
      late MockWeightScale scale;
      late ScanResult result;
      late Duration timeout;

      setUp(() {
        service.initialize();

        weightController = StreamController.broadcast();
        stateController = StreamController.broadcast();

        scale = MockWeightScale();
        when(scale.name).thenReturn('scale');
        when(scale.connect(timeout: anyNamed('timeout')))
            .thenAnswer((_) async {});
        when(scale.disconnect()).thenAnswer((_) async {});

        when(scale.weight).thenAnswer((_) => weightController.stream);
        when(scale.state).thenAnswer((_) => stateController.stream);

        result = ScanResult.fromWeightScale(scale, 'test', 'test.png');
        timeout = const Duration(seconds: 10);
      });

      tearDown(() {
        weightController.close();
        stateController.close();
      });

      group('connect', () {
        test('Should call the connect method When called', () async {
          await service.connect(result, timeout: timeout);
          verify(scale.connect(timeout: timeout));
        });

        test('Should rethrow error When connection fails', () async {
          when(scale.connect(timeout: anyNamed('timeout')))
              .thenThrow(Exception('everything under control'));
          expect(service.connect(result), throwsException);
        });

        test('Should disconnect first When connecting to another scale',
            () async {
          await service.connect(result);
          await service.connect(result);
          verify(scale.disconnect());
        });
      });

      group('disconnect', () {
        test('Should call disconnect on ble device When disconnecting',
            () async {
          await service.connect(result);
          await service.disconnect();
          verify(scale.disconnect());
        });
      });

      group('reconnect', () {
        test('Should call disconnect and connect on the scale', () async {
          await service.connect(result);
          await service.reconnect();
          verify(scale.disconnect());
          verify(scale.connect(timeout: anyNamed('timeout')));
        });

        test('Should still emit weight', () async {
          await service.connect(result);
          await service.reconnect();
          var weight = service.weight.first;
          weightController.add(const Weight(1.2, WeightUnit.kg));
          expect(await weight, 1.2);
        });

        test('Should still detect unexpected disconnects', () async {
          int counter = 0;
          service.setUnexpectedDisconnectCallback((_) => counter++);

          await service.connect(result);
          await service.reconnect();

          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(counter, 1);
        });
      });

      group('connection', () {
        test('Should be a broadcast stream', () {
          expect(service.connection.isBroadcast, isTrue);
        });

        test('Should emit connecting and connected When connecting to a scale',
            () async {
          var connection = service.connection.take(2).toList();
          await service.connect(result);
          expect(
            await connection,
            containsAllInOrder([
              ConnectionStatus.connecting,
              ConnectionStatus.connected,
            ]),
          );
        });

        test('Should emit connecting and disconnected When connection fails',
            () async {
          var connection = service.connection.take(2).toList();
          when(scale.connect(timeout: anyNamed('timeout')))
              .thenThrow(Exception('everything under control'));
          expect(service.connect(result), throwsException);
          expect(
            await connection,
            containsAllInOrder([
              ConnectionStatus.connecting,
              ConnectionStatus.disconnected,
            ]),
          );
        });

        test(
            'Should emit disconnected, connecting and connected When connecting to a scale while already being connected',
            () async {
          await service.connect(result);
          var connection = service.connection.take(3).toList();
          await service.connect(result);
          expect(
            await connection,
            containsAllInOrder([
              ConnectionStatus.disconnected,
              ConnectionStatus.connecting,
              ConnectionStatus.connected,
            ]),
          );
        });

        test('Should emit disconnected When disconnecting', () async {
          await service.connect(result);
          var connection = service.connection.first;
          await service.disconnect();
          expect(await connection, ConnectionStatus.disconnected);
        });

        test('Should emit disconnected When disconnects unexpectedly',
            () async {
          await service.connect(result);
          var connection = service.connection.first;
          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(await connection, ConnectionStatus.disconnected);
        });

        test(
            'Should emit disconnected, connecting and connected When reconnecting',
            () async {
          await service.connect(result);
          var connection = service.connection.take(3).toList();
          await service.reconnect();
          expect(
            await connection,
            containsAllInOrder([
              ConnectionStatus.disconnected,
              ConnectionStatus.connecting,
              ConnectionStatus.connected,
            ]),
          );
        });
      });

      group('weight', () {
        setUp(() async {
          await service.connect(result);
        });

        test('Should be a broadcast stream', () {
          expect(service.weight.isBroadcast, isTrue);
        });

        test('Should stream same weight values as the scale', () async {
          var values = service.weight.take(3).toList();
          weightController.add(const Weight(3, WeightUnit.kg));
          weightController.add(const Weight(5.5, WeightUnit.kg));
          weightController.add(const Weight(60, WeightUnit.kg));
          expect(await values, containsAllInOrder(
              [
                const Weight(3, WeightUnit.kg),
                const Weight(5.5, WeightUnit.kg),
                const Weight(60, WeightUnit.kg)
              ]
          ));
        });

        test(
            'Should not stream weight from old scale When connecting to a new one',
            () async {
          await service.connect(result);

          var values = service.weight.take(3).toList();
          weightController.add(const Weight(3, WeightUnit.kg));
          weightController.add(const Weight(5.5, WeightUnit.kg));
          weightController.add(const Weight(60, WeightUnit.kg));
          expect(await values, containsAllInOrder(
              [
                const Weight(3, WeightUnit.kg),
                const Weight(5.5, WeightUnit.kg),
                const Weight(60, WeightUnit.kg)
              ]
          ));
        });
      });

      group('setUnexpectedDisconnectCallback', () {
        late int counter;

        setUp(() async {
          counter = 0;
          service.setUnexpectedDisconnectCallback((_) => counter++);
          await service.connect(result);
        });

        test('Should be called When experiences unexpected disconnect',
            () async {
          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(counter, 1);
        });

        test('Should not be called When disconnect is called', () async {
          await service.disconnect();
          expect(counter, 0);
        });

        test('Should not be called When disconnected from the scale', () async {
          await service.disconnect();
          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(counter, 0);
        });

        test('Should overwrite old callback When a new is set', () async {
          service.setUnexpectedDisconnectCallback(null);
          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(counter, 0);
        });

        test('Should call the call back with the correct scan result',
            () async {
          service.setUnexpectedDisconnectCallback((res) {
            expect(res, result);
            counter++;
          });
          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(counter, 1); // To make sure the callback was indeed called.
        });

        test('Should already be disconnected When the callback gets called',
            () async {
          service.setUnexpectedDisconnectCallback((_) {
            expect(service.status, ConnectionStatus.disconnected);
            counter++;
          });
          stateController.add(ble.BleDeviceState.disconnected);
          await flushMicroTasks();
          expect(counter, 1); // To make sure the callback was indeed called.
        });
      });
    });
  });
}
