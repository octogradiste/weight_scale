import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/src/recognizers/climbro_recognizer.dart';
import 'package:weight_scale/src/recognizers/eufy_smart_scale_p1_recognizer.dart';
import 'package:weight_scale/src/recognizers/mi_scale_2_recognizer.dart';
import 'ble/backend/fb_backend.dart';

/// A hub for searching and registering weight scales.
///
/// You must first [initialize] the hub before starting a [search].
///
/// If [initialize], [search] or [stopSearch] goes wrong it will
/// throw an [WeightScaleException].
class WeightScaleHub {
  final BleManager _manager;
  final List<WeightScaleRecognizer> _recognizers = [];
  final StreamController<List<WeightScale>> controller = StreamController();
  bool _isInitialized = false;

  WeightScaleHub({required BleManager manager}) : _manager = manager;

  factory WeightScaleHub.defaultBackend() {
    return WeightScaleHub(
      manager: FbBleManager(FlutterBlue.instance, FbConversion()),
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
      await _manager.initialize();
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }

    _manager.scanResults.forEach((scanResults) {
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
      await _manager.startScan(timeout: timeout);
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }
  }

  /// Stops an ongoing [search].
  Future<void> stopSearch() async {
    try {
      await _manager.stopScan();
    } on BleException catch (e) {
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
