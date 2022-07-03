import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble/ble.dart';

/// A connectable weight scale.
abstract class WeightScale {
  /// The product name of this weight scale given by the manufacturer.
  abstract final String name;

  /// The name of the manufacturer of this weight scale.
  abstract final String manufacturer;

  /// Information about the underlying ble device like its name or its id.
  abstract final BleDeviceInformation information;

  /// A stream of weight measurements.
  ///
  /// You need to [connect] to this scale, to get the measurements.
  abstract final Stream<Weight> weight;

  /// The last emitted measurement by [weight].
  Weight get currentWeight;

  /// Takes a weight measurement.
  ///
  /// The future will return the measured weight when the weight has stabilized.
  /// Note: Depending on the implementation, this might be implemented
  /// in hardware or software.
  Future<Weight> takeWeightMeasurement();

  /// True if is currently connected to this weight scale.
  bool get isConnected;

  /// This stream emits the state of this device.
  ///
  /// Note: It's possible that the [state] skips [BleDeviceState.disconnecting]
  /// and goes directly to [BleDeviceState.disconnected].
  Stream<BleDeviceState> get state;

  /// Connects to this weight scale.
  ///
  /// Note: if you try to connect to an already connected [WeightScale],
  /// an [WeightScaleException] will be thrown.
  Future<void> connect({Duration timeout = const Duration(seconds: 15)});

  /// Disconnects from this weight scale.
  Future<void> disconnect();
}
