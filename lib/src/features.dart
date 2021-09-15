import 'package:weight_scale/src/weight_scale.dart';

abstract class BatteryLevelFeature {
  /// The battery level from 0 to 100.
  Future<int> getBatteryLevel();
}

abstract class SetUnitFeature {
  Future<void> setUnit(WeightScaleUnit unit);
}

abstract class CalibrateFeature {
  Future<void> calibrate();
}

abstract class ClearCacheFeature {
  Future<void> clearCache();
}
