import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_hub.dart';

/// A [WeightScale] recognizer.
///
/// Every weight scale must have implement its own [WeightScaleRecognizer].
/// The recognizer is then used by the [WeightScaleHub] to distinguish the
/// weight scales from other ble devices.
abstract class WeightScaleRecognizer {
  /// Recognizes if it's a [WeightScale].
  ///
  /// If the [scanResult] is recognized to be a [WeightScale], the recognized
  /// weight scale is return. Otherwise null will be returned.
  WeightScale? recognize({required ScanResult scanResult});
}
