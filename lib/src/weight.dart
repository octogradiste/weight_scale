import 'package:equatable/equatable.dart';

/// Unit in which the weight is measured.
enum WeightUnit { kg, lbs, unknown }

/// Holds a [weight] value and its corresponding [unit].
class Weight extends Equatable {
  final double weight;
  final WeightUnit unit;

  const Weight(this.weight, this.unit);

  @override
  List<Object?> get props => [weight, unit];
}
