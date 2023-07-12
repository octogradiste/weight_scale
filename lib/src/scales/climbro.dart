import 'dart:typed_data';

import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/scales/weight_scale_software_stabilizer.dart';

class Climbro extends WeightScaleSoftwareStabilizer {
  @override
  final serviceUuid = const Uuid("49535343-fe7d-4ae5-8fa9-9fafd205e455");

  @override
  final characteristicUuid = const Uuid("49535343-1e4d-4bd9-ba61-23c647249616");

  Climbro({required super.device});

  @override
  final String name = "Climbro Smart Hangboard";

  @override
  final String manufacturer = "Climbro";

  @override
  Weight? onData(Uint8List data) {
    return (data.length == 1)
        ? Weight(data.first.toDouble(), WeightUnit.kg)
        : null;
  }
}
