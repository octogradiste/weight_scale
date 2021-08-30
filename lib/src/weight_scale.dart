/// An exception thrown when a the connection to a weight scale fails.
class WeightScaleConnectionException implements Exception {
  /// This [message] is guaranteed to be user readable.
  final String message;
  const WeightScaleConnectionException(this.message);
}

/// Unit in which the weight is measured.
enum WeightScaleUnit { KG, LBS, UNKNOWN }

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
