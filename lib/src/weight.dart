import 'package:equatable/equatable.dart';

/// Unit in which the weight is measured.
enum WeightUnit { kg, lbs, unknown }

/// Holds a [value] and its corresponding [unit].
class Weight extends Equatable {
  final double value;
  final WeightUnit unit;

  const Weight(this.value, this.unit);

  @override
  List<Object?> get props => [value, unit];
}
