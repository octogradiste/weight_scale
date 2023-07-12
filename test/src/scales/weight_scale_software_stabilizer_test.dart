import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/src/ble/model/uuid.dart';
import 'package:weight_scale/src/scales/weight_scale_software_stabilizer.dart';
import 'package:weight_scale/src/weight.dart';

import 'abstract_weight_scale_test.mocks.dart';

class TestWeightScaleSoftwareStabilizer extends WeightScaleSoftwareStabilizer {
  final StreamController<Weight> weightController;
  Weight? onDataValue;

  @override
  final serviceUuid = const Uuid('5cc63afd-37f2-46d6-8467-f9c27eced9ca');

  @override
  final characteristicUuid = const Uuid('7801bcaf-aa7a-45af-b4c3-baf205d89478');

  TestWeightScaleSoftwareStabilizer({
    required super.device,
    required super.stabilizationTime,
    required this.weightController,
  });

  @override
  String get name => "name";

  @override
  String get manufacturer => "manufacturer";

  @override
  Weight? onData(Uint8List data) => onDataValue;

  @override
  Stream<Weight> get weight => weightController.stream;
}

void main() {
  const stabilizationTime = Duration(milliseconds: 20);
  late TestWeightScaleSoftwareStabilizer scale;
  late StreamController<Weight> weightController;

  setUp(() {
    weightController = StreamController<Weight>();
    scale = TestWeightScaleSoftwareStabilizer(
      device: MockBleDevice(),
      stabilizationTime: stabilizationTime,
      weightController: weightController,
    );
  });

  group('hasStabilized', () {
    test('Should return false When weight has changed', () async {
      const weight = Weight(1, WeightUnit.kg);

      weightController.add(weight);
      await Future.delayed(stabilizationTime * 2);

      scale.onDataValue = const Weight(2, WeightUnit.kg);
      expect(scale.hasStabilized(Uint8List(1)), false);
    });

    test('Should return false When not enough time has elapsed', () async {
      const weight = Weight(1, WeightUnit.kg);

      weightController.add(weight);
      await Future.delayed(stabilizationTime * 0.1);

      scale.onDataValue = weight;
      expect(scale.hasStabilized(Uint8List(1)), false);
    });

    test('Should return false When weight has changed in between', () async {
      const weight = Weight(1, WeightUnit.kg);

      weightController.add(weight);
      await Future.delayed(stabilizationTime * 0.5);

      weightController.add(const Weight(2, WeightUnit.kg));
      await Future.delayed(stabilizationTime);

      weightController.add(weight);
      await Future.delayed(stabilizationTime * 0.1);

      scale.onDataValue = weight;
      expect(scale.hasStabilized(Uint8List(1)), false);
    });

    test('Should return true When weight has not changed', () async {
      const weight = Weight(1, WeightUnit.kg);

      weightController.add(weight);
      await Future.delayed(stabilizationTime * 2);

      scale.onDataValue = weight;
      expect(scale.hasStabilized(Uint8List(1)), true);
    });
  });
}
