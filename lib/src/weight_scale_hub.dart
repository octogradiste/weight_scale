import 'dart:async';
import 'dart:io';

import 'package:weight_scale/ble.dart';
import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/ble_service.dart';
import 'package:weight_scale/src/recognizers/climbro_recognizer.dart';
import 'package:weight_scale/src/recognizers/eufy_smart_scale_p1_recognizer.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'package:weight_scale/src/weight_scale.dart';
import 'package:weight_scale/src/weight_scale_recognizer.dart';

/// A hub for searching and registering weight scales.
///
/// You must first [initialize] the hub before starting a [search].
///
/// If [initialize], [search] or [stopSearch] goes wrong it will
/// throw an [WeightScaleException].
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
      bleService: BleService.instance(),
      bleOperations: BleOperationsFactory.primary(),
    );
  }

  bool get isInitialized => _isInitialized;

  /// A list of all the registered [WeightScaleRecognizer].
  List<WeightScaleRecognizer> get recognizers => _recognizers;

  /// Initializes the [WeightScaleHub].
  ///
  /// This will initialize the underlying [BleService] and register all known
  /// recognizers. Those will be in the [recognizers] list after the
  /// initialization completes.
  ///
  /// If the [WeightScaleHub] is already initialized, call to this method won't
  /// do anything.
  Future<void> initialize() async {
    if (_isInitialized) return;

    register(MiScale2Recognizer());
    register(ClimbroRecognizer());
    register(EufySmartScaleP1Recognizer());

    try {
      await _bleService.initialize(
        operations: _bleOperations,
        isAndroid: Platform.isAndroid,
      );
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    }

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
  Future<void> search({Duration timeout = const Duration(seconds: 15)}) async {
    try {
      await _bleService.startScan(timeout: timeout);
    } on BleServiceNotInitializedException {
      throw WeightScaleException("Not initialized.");
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    }
  }

  /// Stops an ongoing [search].
  Future<void> stopSearch() async {
    try {
      await _bleService.stopScan();
    } on BleServiceNotInitializedException {
      throw WeightScaleException("Not initialized.");
    } on BleOperationException catch (e) {
      throw WeightScaleException(e.message);
    }
  }

  /// Register a [WeightScaleRecognizer].
  ///
  /// Register your custom [WeightScaleRecognizer] here. If you do so,
  /// your custom [WeightScale] will be recognized and returned by the [search].
  void register(WeightScaleRecognizer recognizer) {
    _recognizers.add(recognizer);
  }
}
