import 'dart:async';

import 'package:climb_scale/fake/weight_scale_fake.dart';
import 'package:climb_scale/utils/logger.dart';
import 'package:equatable/equatable.dart';
///import 'package:weight_scale/src/ble/ble.dart';
import 'package:weight_scale/scale.dart';

class ScanResult extends Equatable {
  final String name;
  final String manufacturer;
  final String imagePath;
  final WeightScale _weightScale;

  ScanResult.fromWeightScale(
    WeightScale scale,
    this.manufacturer,
    this.imagePath,
  )   : _weightScale = scale,
        name = scale.name;

  @override
  List<Object?> get props => [name, _weightScale, manufacturer, imagePath];
}

enum ConnectionStatus { connecting, connected, disconnected }

abstract class IWeightScaleService {
  /// True if the service has already been initialized.
  bool get isInitialized;

  /// True if currently in the [ConnectionStatus.connected] status.
  bool get isConnected;

  /// True if is currently scanning.
  bool get isScanning;

  /// The current connection status.
  ConnectionStatus get status;

  /// A broadcast stream streaming the new status at each status change.
  Stream<ConnectionStatus> get connection;

  /// A broadcast stream of the found scales during the scan.
  Stream<List<ScanResult>> get results;

  /// A broadcast stream streaming the emitted weight values
  /// of the connected scale.
  Stream<double> get weight;

  /// Initialize this service once before usage.
  ///
  /// Subsequent calls to this method won't have any effect.
  Future<void> initialize();

  /// Set a new [callback] which gets called if the connection to a connected
  /// scale is unexpectedly lost.
  ///
  /// This [callback] won't be called if the scale is normally [disconnect]ed.
  void setUnexpectedDisconnectCallback(void Function(ScanResult)? callback);

  /// Starts a scan.
  ///
  /// The returned future completes when [timeout] is over
  /// or if [stopScan] is called.
  ///
  /// If is currently scanning, will first stop the old scan
  /// and start a new one.
  Future<void> startScan({Duration timeout = const Duration(seconds: 20)});

  /// If currently scanning, stops the scan.
  Future<void> stopScan();

  /// Tries to connect to the [result].
  ///
  /// If it fails to establish a connection (in time),
  /// it will throw a [WeightScaleException].
  ///
  /// If is already connected to another scale, will first disconnect from
  /// the other before connecting to the [result].
  Future<void> connect(
    ScanResult result, {
    Duration timeout = const Duration(seconds: 20),
  });

  /// If currently connected to a scale, disconnects from it.
  Future<void> disconnect();

  /// If currently connected to a scale, tries to reconnect to it.
  Future<void> reconnect();
}

class WeightScaleService implements IWeightScaleService {
  static const String _className = 'WeightScaleService';

  static const String _imageBasePath = 'assets/image/scale/';

  late final WeightScaleManager _hub;
  late final Stream<List<ScanResult>> _results;
  late final StreamController<double> _weightController;
  late final StreamController<ConnectionStatus> _connectionController;

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  bool _initialized = false;
  bool _scanning = false;

  void Function(ScanResult)? _unexpectedDisconnectCallback;

  /// Should be set to false when [connect] and to true [disconnect].
  ///
  /// So, if the currently connected scale emits a [BleDeviceState.disconnected]
  /// but [_safeDisconnect] is false, it must be an unexpected disconnect.
  bool _safeDisconnect = false;

  /// Is null when not connected.
  ScanResult? _result;
  StreamSubscription<Weight>? _weightSubscription;
  StreamSubscription<BleDeviceState>? _stateSubscription;

  WeightScaleService(WeightScaleManager hub) {
    _hub = hub;
    _results = _hub.scales.map((list) {
      list.add(WeightScaleFake());
      return list.map((scale) {
        if (scale.name == "Mi Body Composition Scale 2") {
          return ScanResult.fromWeightScale(
            scale,
            'Xiaomi',
            '${_imageBasePath}MIBCS2.png',
          );
        } else {
          return ScanResult.fromWeightScale(
            scale,
            'Unknown',
            '${_imageBasePath}UnknownScale.png',
          );
        }
      }).toList();
    }).asBroadcastStream();

    _weightController = StreamController.broadcast();
    _connectionController = StreamController.broadcast();
  }

  /// A helper function to set a [newStatus].
  ///
  /// Will update [_connectionStatus] and add it to the [connection]
  /// controlled by [_connectionController].
  void _changeConnectionStatus(ConnectionStatus newStatus) {
    Logger.d(_className, 'New connection status: ${newStatus.name}.');
    _connectionStatus = newStatus;
    _connectionController.add(newStatus);
  }

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isScanning => _scanning;

  @override
  bool get isConnected => status == ConnectionStatus.connected;

  @override
  Stream<List<ScanResult>> get results => _results;

  @override
  ConnectionStatus get status => _connectionStatus;

  @override
  Stream<ConnectionStatus> get connection => _connectionController.stream;

  @override
  Stream<double> get weight => _weightController.stream;

  @override
  Future<void> initialize() async {
    if (!_initialized) {
      await _hub.initialize();
      _initialized = true;
      Logger.d(_className, 'Initialized Service.');
    }
  }

  @override
  void setUnexpectedDisconnectCallback(void Function(ScanResult)? callback) {
    _unexpectedDisconnectCallback = callback;
  }

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (_scanning) {
      _hub.stopScan();
    }

    _scanning = true;
    Logger.d(_className, 'Starting to scan for weight scales.');
    try {
      await _hub.startScan(timeout: timeout);
    } finally {
      _scanning = false;
    }
  }

  @override
  Future<void> stopScan() async {
    await _hub.stopScan();
    _scanning = false;
    Logger.d(_className, 'Stopped scanning.');
  }

  @override
  Future<void> connect(
    ScanResult result, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (status != ConnectionStatus.disconnected) await disconnect();
    _result = result;

    _safeDisconnect = false;
    _changeConnectionStatus(ConnectionStatus.connecting);
    Logger.d(_className, 'Connecting to ${result.name}.');

    _weightSubscription = result._weightScale.weight.listen(null);
    _stateSubscription = result._weightScale.state.listen(null);

    try {
      await result._weightScale.connect(timeout: timeout);
    } catch (e, stackTrace) {
      Logger.e(_className, 'Failed to connect.', e, stackTrace);
      await disconnect();
      rethrow;
    }
    _changeConnectionStatus(ConnectionStatus.connected);

    _weightSubscription!.onData((weight) {
      _weightController.add(weight.value);
      Logger.d(_className, 'Got new data.');
    });

    _stateSubscription!.onData((state) async {
      Logger.d(_className, 'Ble weight scale state changed: ${state.name}.');
      if (state == BleDeviceState.disconnected && !_safeDisconnect) {
        Logger.w(_className, 'Registered an unexpected disconnect.');
        disconnect().then((_) => _unexpectedDisconnectCallback?.call(result));
      }
    });
  }

  @override
  Future<void> disconnect() async {
    if (_result != null) {
      _safeDisconnect = true;

      await _result!._weightScale.disconnect();

      await _weightSubscription?.cancel();
      await _stateSubscription?.cancel();

      _changeConnectionStatus(ConnectionStatus.disconnected);
      Logger.d(_className, 'Disconnected from ${_result!.name}.');

      _result = null;
    } else {
      Logger.w(_className, 'Did not disconnect because has no scan result.');
    }
  }

  @override
  Future<void> reconnect({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (_result != null) {
      Logger.d(_className, 'Reconnecting to ${_result!.name}');
      await connect(_result!, timeout: timeout);
    } else {
      Logger.w(_className, 'Has no scan result to reconnect to!');
    }
  }
}
