import 'package:weight_scale/scale.dart';

/// A connectable weight scale.
///
/// All exception during any ble operation will be thrown as an
/// [WeightScaleException].
abstract class WeightScale {
  /// The product name of this weight scale given by the manufacturer.
  abstract final String name;

  /// The name of the manufacturer of this weight scale.
  abstract final String manufacturer;

  /// Information about the underlying ble device like its name or its id.
  abstract final BleDeviceInformation information;

  /// A broadcast stream of weight measurements.
  ///
  /// You need to first [connect] to this scale, to get the measurements.
  ///
  /// This stream emits all weight values received by the scale even if
  /// the weight has not stabilized yet. To get the stabilized weight instead,
  /// use the [takeWeightMeasurement] method.
  abstract final Stream<Weight> weight;

  /// The last emitted measurement by [weight].
  Weight get currentWeight;

  /// Takes a weight measurement.
  ///
  /// The future will return the measured weight when the weight has stabilized.
  ///
  /// Depending on the implementation, this might be implemented
  /// on the weight scale or in software.
  Future<Weight> takeWeightMeasurement();

  /// True if is currently connected to this weight scale.
  bool get isConnected;

  // The current state of the underlying ble device.
  BleDeviceState get currentState;

  /// This stream emits the state of this ble device.
  ///
  /// It's possible that the [state] skips [BleDeviceState.disconnecting]
  /// and goes directly to [BleDeviceState.disconnected].
  Stream<BleDeviceState> get state;

  /// Connects to this weight scale.
  ///
  /// If you try to connect to an already connected [WeightScale] or if you're
  /// currently connecting to it, an [WeightScaleException] will be thrown.
  Future<void> connect({Duration timeout = const Duration(seconds: 15)});

  /// Disconnects from this weight scale.
  Future<void> disconnect();
}
