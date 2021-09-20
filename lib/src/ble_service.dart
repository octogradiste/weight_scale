import 'dart:async';
import 'dart:collection';

import 'package:weight_scale/src/ble_operations.dart';
import 'package:weight_scale/src/model/scan_result.dart';
import 'package:weight_scale/src/model/uuid.dart';
import 'package:weight_scale/src/util/state_stream.dart';

/// The different states of the [BleService].
enum BleServiceState {
  idle,
  scanning,
}

/// Exception thrown when the [BleService] is not yet initialized.
class BleServiceNotInitializedException implements Exception {}

/// A service for scanning ble devices.
///
/// It's heavily recommended to use the factory constructor
/// [BleService.instance] to always get the same instance. This avoids starting
/// multiple scans from different instances.
///
/// Before starting a scan you must [initialize] this service. Otherwise you
/// will get an [BleServiceNotInitializedException].
class BleService {
  bool _isAndroid = false;
  bool _isInitialized = false;
  late final BleOperations _operations;
  final Queue<DateTime> _scanQueue = Queue();
  final StateStream<BleServiceState> _state =
      StateStream(initValue: BleServiceState.idle);

  static BleService? _instance;

  BleService();

  factory BleService.instance() {
    if (_instance == null) _instance = BleService();
    return _instance!;
  }

  /// A stream of the current state.
  ///
  /// The state is either in [BleServiceState.idle] or in
  /// [BleServiceState.scanning] during an ongoing scan.
  late final Stream<BleServiceState> state;

  /// A stream with the results of a scan.
  ///
  /// During a scan this stream emits lists of scan results.
  late final Stream<List<ScanResult>> scanResults;

  bool get isScanning => _state.state == BleServiceState.scanning;
  bool get isInitialized => _isInitialized;
  bool get isAndroid => _isAndroid;

  /// Initializes the Bluetooth.
  ///
  /// If the [BleService] is already initialized, calls to this method
  /// will return immediately.
  /// This means it's not possible to change the [operations] as well as
  /// the [isAndroid] after the first initialization.
  Future<void> initialize({
    required BleOperations operations,
    required bool isAndroid,
  }) async {
    if (_isInitialized) return;
    _operations = operations;
    try {
      await _operations.initialize();
      _isAndroid = isAndroid;
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

    if (_isAndroid) {
      DateTime now = DateTime.now();
      if (_scanQueue.length == 0)
        _scanQueue.add(DateTime.fromMillisecondsSinceEpoch(0));
      if (_scanQueue.length == 5 &&
          now.difference(_scanQueue.first) < Duration(seconds: 30)) {
        throw BleOperationException("Too many scans.");
      } else {
        _scanQueue.addLast(now);
        if (_scanQueue.length > 5) _scanQueue.removeFirst();
      }
    }

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
