import 'package:weight_scale/scale.dart';

abstract class BatteryLevelFeature {
  /// The battery level from 0 to 100.
  Future<int> getBatteryLevel();
}

abstract class SetUnitFeature {
  Future<void> setUnit(WeightUnit unit);
}

abstract class CalibrateFeature {
  Future<void> calibrate();
}

abstract class ClearCacheFeature {
  Future<void> clearCache();
}
