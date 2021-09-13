import 'package:weight_scale/src/ble_service.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_recognizer.dart';

/// A hub for searching and registering weight scales.
class WeightScaleHub {
  WeightScaleHub({required BleService bleService});

  bool get isInitialized => false;

  /// A list of all the registered [WeightScaleRecognizer].
  List<WeightScaleRecognizer> get recognizers => List.empty();

  /// Initialize [WeightScaleHub] before starting a search.
  ///
  /// This will initialize the underlying [BleService] and register all known
  /// weight scales. Those will be in the [recognizers] list after the
  /// initialization completes.
  Future<void> initialize() async {}

  /// The available [WeightScale].
  ///
  /// A [Stream] which emits a list of the weight scales
  /// found during the [search].
  Stream<List<WeightScale>> get scales => Stream.empty();

  /// Searches available [WeightScale].
  ///
  /// The [Future] completes when the search ends (either by calling
  /// [stopSearch] or when the timeout is reached).
  ///
  /// While searching, the recognized [WeightScale] are emitted by the [scales]
  /// stream.
  ///
  /// Note: When calling this function, it will first clear all previously found
  /// weight scales and restart from the beginning.
  Future<void> search({Duration timeout = const Duration(seconds: 15)}) async {}

  /// Stops an ongoing [search].
  Future<void> stopSearch() async {}

  /// Register a [WeightScaleRecognizer].
  ///
  /// Register your custom [WeightScaleRecognizer] here. If you do so,
  /// your custom [WeightScale] will be recognized and returned by the [search].
  void register(WeightScaleRecognizer recognizer) {}
}
