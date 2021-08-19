enum WeightUnit { KG }

abstract class WeightScale {
  abstract final String name;
  abstract final Stream<double> weight;
  double get currentWeight;
  bool get isConnected;
  WeightUnit get unit;

  Future<void> connect({Duration timeout = const Duration(seconds: 15)});
  Future<void> disconnect();
}
