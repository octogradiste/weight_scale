import 'dart:async';
import 'dart:io';

import 'package:weight_scale/ble.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/ble_service.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_recognizer.dart';

/// A hub for searching and registering weight scales.
class WeightScaleHub {
  late final BleService _bleService;
  late final BleOperations _bleOperations;
  final List<WeightScaleRecognizer> _recognizers = [];
  final StreamController<List<WeightScale>> controller = StreamController();
  bool _isInitialized = false;

  WeightScaleHub({
    required BleService bleService,
    required BleOperations bleOperations,
  }) {
    _bleService = bleService;
    _bleOperations = bleOperations;
  }

  factory WeightScaleHub.defaultBackend() {
    return WeightScaleHub(
      bleService: BleService.instance,
      bleOperations: BleOperationsFactory.primary(),
    );
  }

  bool get isInitialized => _isInitialized;

  /// A list of all the registered [WeightScaleRecognizer].
  List<WeightScaleRecognizer> get recognizers => _recognizers;

  /// Initialize [WeightScaleHub] before starting a search.
  ///
  /// This will initialize the underlying [BleService] and register all known
  /// weight scales. Those will be in the [recognizers] list after the
  /// initialization completes.
  Future<void> initialize() async {
    register(MiScale2Recognizer());

    await _bleService.initialize(
      operations: _bleOperations,
      isAndroid: Platform.isAndroid,
    );

    _bleService.scanResults.forEach((scanResults) {
      controller.add(scanResults
          .map((scanResult) {
            for (WeightScaleRecognizer recognizer in _recognizers) {
              WeightScale? scale = recognizer.recognize(scanResult: scanResult);
              if (scale != null) return scale;
            }
          })
          .whereType<WeightScale>()
          .toList());
    });

    _isInitialized = true;
  }

  /// The available [WeightScale].
  ///
  /// A [Stream] which emits a list of the weight scales
  /// found during the [search].
  Stream<List<WeightScale>> get scales => controller.stream;

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
  Future<void> search({Duration timeout = const Duration(seconds: 15)}) async {
    await _bleService.startScan(timeout: timeout);
  }

  /// Stops an ongoing [search].
  Future<void> stopSearch() async {
    await _bleService.stopScan();
  }

  /// Register a [WeightScaleRecognizer].
  ///
  /// Register your custom [WeightScaleRecognizer] here. If you do so,
  /// your custom [WeightScale] will be recognized and returned by the [search].
  void register(WeightScaleRecognizer recognizer) {
    _recognizers.add(recognizer);
  }
}
