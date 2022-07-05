import 'package:weight_scale/scale.dart';

/// A [WeightScale] recognizer.
///
/// Every weight scale must have implement its own [WeightScaleRecognizer].
/// The recognizer is then used by the [WeightScaleManager] to distinguish the
/// weight scales from other ble devices.
///
/// Registering a weight scale recognizer:
/// ```dart
/// // Get the default weight scale hub.
/// WeightScaleHub hub = WeighScaleHub.defaultBackend();
///
/// // Don't forget to initialize the hub before using it!
/// await hub.initialize();
///
/// // Register your custom recognizer
/// hub.register(customRecognizer);
/// ```
abstract class WeightScaleRecognizer {
  /// Recognizes if it's a [WeightScale].
  ///
  /// If the [scanResult] is recognized to be a [WeightScale], the recognized
  /// weight scale is return. Otherwise null will be returned.
  WeightScale? recognize({required ScanResult scanResult});
}
