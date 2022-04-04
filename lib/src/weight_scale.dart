import 'package:weight_scale/src/ble/ble.dart';

/// Unit in which the weight is measured.
enum WeightScaleUnit { KG, LBS, UNKNOWN }

/// A connectable weight scale.
abstract class WeightScale {
  /// The name of the weight scale given by the manufacturer.
  abstract final String name;

  /// A stream of the weight measurements.
  ///
  /// You need to [connect] to the scale, to get the measurements.
  abstract final Stream<double> weight;

  /// The unit in which the [weight] is given.
  WeightScaleUnit get unit;

  /// The last emitted measurement by [weight].
  double get currentWeight;

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
