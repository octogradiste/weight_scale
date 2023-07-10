import 'package:weight_scale/scale.dart';

/// A [WeightScale] recognizer.
///
/// Every weight scale must implement its own [WeightScaleRecognizer].
/// The recognizer is used by the [WeightScaleManager] to distinguish
/// weight scales from other ble devices.
///
/// Registering a custom recognizer:
/// ```dart
/// // Get the default weight scale manager.
/// WeightScaleManager manager = WeighScaleManager.defaultBackend();
///
/// // Don't forget to initialize the manager before using it!
/// await manager.initialize();
///
/// // Register your custom recognizer.
/// manager.register(customRecognizer);
/// ```
abstract class WeightScaleRecognizer {
  /// Recognizes if it's a [WeightScale].
  ///
  /// If the [scanResult] is recognized to be a [WeightScale], the recognized
  /// weight scale is return. Otherwise, null is returned.
  WeightScale? recognize({required ScanResult scanResult});
}
