/// Unit in which the weight is measured.
enum WeightScaleUnit { KG, LBS, UNKOWN }

/// A connectable weight scale.
abstract class WeightScale {
  /// The name of the weight scale given by the manufacturer.
  abstract final String name;

  /// [connect] to the scale to get the measurements.
  abstract final Stream<double> weight;
  WeightScaleUnit get unit;
  double get currentWeight;
  bool get isConnected;

  Future<void> connect({Duration timeout = const Duration(seconds: 15)});
  Future<void> disconnect();
}
