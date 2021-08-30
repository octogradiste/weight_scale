import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/weight_scale.dart';

abstract class WeightScaleRecognizer {
  /// Recognizes if it's a [WeightScale].
  ///
  /// If the [scanResult] is recognized to be a [WeightScale], the recognized
  /// weight scale is return. Otherwise null will be returned.
  WeightScale? recognize({required ScanResult scanResult});
}
