import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/recognizers/recognizer.dart';
import 'ble/backend/fb_backend.dart';

/// A manager for weight scales.
///
/// Before starting or stopping a scan you have to [initialize] this manager.
///
/// During a scan, the ble devices recognized as weight scales using the
/// [recognizers], are emitted to the [scales] stream. The scanning process
/// can be stopped via [stopScan].
///
/// If any operation goes wrong, it will throw a [WeightScaleException].
/// Because many things might go wrong when communicating over bluetooth
/// low energy, you should check for those exception during the initialization
/// and the scanning process.
class WeightScaleManager {
  final BleManager _manager;
  final _recognizers = <WeightScaleRecognizer>[];
  final _scalesController = StreamController<List<WeightScale>>();

  var _isInitialized = false;
  var _isScanning = false;

  WeightScaleManager({required BleManager manager}) : _manager = manager;

  /// Returns a [WeightScaleManager] using as [BleManager] the default
  /// implementation, namely the
  /// [flutter_blue](https://pub.dev/packages/flutter_blue) implementation.
  factory WeightScaleManager.defaultBackend() {
    return WeightScaleManager(
      manager: FbBleManager(FlutterBlue.instance, FbConversion()),
    );
  }

  /// True once [initialize] has been called and has completed without
  /// exception.
  bool get isInitialized => _isInitialized;

  /// True if is currently scanning for weight scales.
  bool get isScanning => _isScanning;

  /// A list of all the registered [WeightScaleRecognizer].
  List<WeightScaleRecognizer> get recognizers => _recognizers;

  /// Initializes the [WeightScaleManager].
  ///
  /// This will initialize the underlying [BleManager] and register all default
  /// recognizers. Those will be in the [recognizers] list after the
  /// initialization completes.
  ///
  /// If the [WeightScaleManager] is already initialized, call to this method
  /// won't do anything.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Registering all default recognizers.
    register(MiScale2Recognizer());
    register(ClimbroRecognizer());
    register(EufySmartScaleP1Recognizer());

    try {
      await _manager.initialize();

      _manager.scanResults.forEach((scanResults) {
        _scalesController.add(scanResults
            .map((scanResult) {
              for (WeightScaleRecognizer recognizer in _recognizers) {
                WeightScale? scale =
                    recognizer.recognize(scanResult: scanResult);
                if (scale != null) return scale;
              }
            })
            .whereType<WeightScale>()
            .toList());
      });
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }

    _isInitialized = true;
  }

  /// The weight scales found during a scan.
  ///
  /// Emits lists of weight scales found during the scan.
  Stream<List<WeightScale>> get scales => _scalesController.stream;

  /// Performs a ble scan and searches for weight scales.
  ///
  /// While searching, the recognized weight scales are emitted
  /// by the [scales] stream.
  ///
  /// The [Future] completes when the scan ends (either by calling
  /// [stopScan] or when the [timeout] is reached).
  ///
  /// If is currently scanning, will first stop the ongoing scan and then
  /// start a new one.
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!_isInitialized) {
      throw const WeightScaleException('Is not yet initialized.');
    }

    if (_isScanning) stopScan();
    _isScanning = true;

    try {
      await _manager.startScan(timeout: timeout);
    } on BleException catch (e) {
      _isScanning = false;
      throw WeightScaleException(e.message);
    }
  }

  /// Stops an ongoing scan.
  ///
  /// If you don't need to scan any more, it's a good idea to stop the scan
  /// because scanning for ble devices consumes lots of resources and power.
  ///
  /// Won't do anything with you're not currently scanning.
  Future<void> stopScan() async {
    if (!_isInitialized) {
      throw const WeightScaleException('Is not yet initialized.');
    }

    if (!_isScanning) return;

    try {
      await _manager.stopScan();
      _isScanning = false;
    } on BleException catch (e) {
      throw WeightScaleException(e.message);
    }
  }

  /// Registers a [WeightScaleRecognizer].
  ///
  /// You can use this to register you're custom recognizer. Once registered,
  /// It will be used during the [startScan] to determine if a found ble device
  /// is or isn't your custom weight scale.
  void register(WeightScaleRecognizer recognizer) {
    _recognizers.add(recognizer);
  }
}
