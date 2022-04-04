import 'package:weight_scale/ble.dart';

/// A class for managing ble operations.
///
/// To start using this [BleManager] you have to [initialize] it.
/// After successful initialization you're ready to start scanning for
/// ble devices. To do so you call [startScan] and listen to the [scanResults]
/// steam to get notified when new devices are found. The [scanResults] stream
/// emits lists of [ScanResult] objects. Each list represent a group of
/// available device.
/// The scan results will stop after the given timeout passed to [startScan] or
/// when calling [stopScan].
abstract class BleManager {
  /// Returns a set of the currently connected devices.
  Future<Set<BleDevice>> get connectedDevices;

  /// A broadcast stream emitting the latest scan results of an ongoing scan.
  Stream<List<ScanResult>> get scanResults;

  /// Returns true if has already been successfully initialized
  /// via a call to [initialize].
  bool get isInitialized;

  /// Returns true if is currently scanning.
  bool get isScanning;

  /// Initializes this [BleManager].
  ///
  /// Note: This method must be called and complete successfully before you
  /// start or stop a scan. Once initialized any call to this method won't have
  /// any effect and will return immediately.
  Future<void> initialize();

  /// Starts a ble scan and completes when the scan ends.
  /// All the results from the scan are emitted in the [scanResults] stream.
  ///
  /// If [withServices] isn't null, it's used to filter the scanned devices.
  ///
  /// Will throw a [BleException] if is already scanning.
  Future<void> startScan({
    List<Uuid>? withServices,
    Duration timeout = const Duration(seconds: 20),
  });

  /// If is currently scanning, will stop the ongoing scan.
  Future<void> stopScan();
}
