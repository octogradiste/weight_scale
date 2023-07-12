import 'dart:typed_data';

import 'package:weight_scale/src/scales/abstract_weight_scale.dart';
import 'package:weight_scale/src/weight.dart';

/// Implements a software stabilization for a weight scale.
///
/// This class extends [AbstractWeightScale] with the [hasStabilized] method.
/// To determine if the weight has stabilized, we check that the weight
/// hasn't changed for [stabilizationTime].
abstract class WeightScaleSoftwareStabilizer extends AbstractWeightScale {
  /// The time the weight has to be stable to be counted as a valid measurement.
  final Duration stabilizationTime;

  Weight _lastWeight = const Weight(0, WeightUnit.kg);
  DateTime _lastWeightTime = DateTime.now();

  WeightScaleSoftwareStabilizer({
    required super.device,
    this.stabilizationTime = const Duration(seconds: 2),
  }) {
    weight.distinct().listen((weight) {
      _lastWeight = weight;
      _lastWeightTime = DateTime.now();
    });
  }

  @override
  bool hasStabilized(Uint8List data) {
    final weight = onData(data);

    if (weight != null && weight == _lastWeight) {
      final now = DateTime.now();
      return now.difference(_lastWeightTime) > stabilizationTime;
    }

    return false;
  }
}
