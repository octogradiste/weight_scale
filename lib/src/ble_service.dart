import 'dart:async';

import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/src/util/state_stream.dart';
import 'package:weight_scale/weight_scale.dart';

enum BleServiceState {
  idle,
  scanning,
}

class BleServiceNotInitializedException implements Exception {}

class BleService {
  bool _isInitialized = false;
  late final BleOperations _operations;
  final StateStream<BleServiceState> _state =
      StateStream(initValue: BleServiceState.idle);

  late final Stream<BleServiceState> state;
  late final Stream<List<ScanResult>> scanResults;

  static BleService instance = BleService();

  bool get isScanning => _state.state == BleServiceState.scanning;
  bool get isInitialized => _isInitialized;

  /// Initializes the Bluetooth.
  ///
  /// If the [BleService] is already initialized, calls to this method
  /// will return immediately.
  Future<void> initialize({required BleOperations operations}) async {
    if (_isInitialized) return;
    _operations = operations;
    try {
      await _operations.initialize();
      _isInitialized = true;
    } finally {
      if (_isInitialized) {
        state = _state.events;
        scanResults = _operations.scanResults;
      }
    }
  }

  /// Starts a scan.
  ///
  /// The future completes when the [timeout] is over or when the scan is
  /// stopped. See [stopScan].
  /// Throws a [BleOperationException] if the [BleService] is already scanning.
  ///
  /// On Android an [BleOperationException] is thrown if more then 5 scan are
  /// started in 30 seconds.
  Future<void> startScan({
    required Duration timeout,
    List<Uuid>? withServices,
  }) async {
    if (!isInitialized) throw BleServiceNotInitializedException();
    if (isScanning) throw BleOperationException("Is already scanning.");

    _state.setState(BleServiceState.scanning);
    try {
      await _operations.startScan(timeout: timeout, withServices: withServices);
    } finally {
      _state.setState(BleServiceState.idle);
    }
  }

  /// Stops the current scan.
  ///
  /// If the [BleService] is not currently scanning, the future
  /// completes immediately.
  Future<void> stopScan() async {
    if (!isInitialized) throw BleServiceNotInitializedException();
    if (!isScanning) return;
    try {
      await _operations.stopScan();
    } finally {
      _state.setState(BleServiceState.idle);
    }
  }
}
