import 'package:weight_scale/ble.dart';

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
  /// start a scan. Once initialized any call to this method won't have any
  /// effect and will return immediately.
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
