import 'package:equatable/equatable.dart';

/// An exception throw when an operation on a weight scale fails.
class WeightScaleException extends Equatable implements Exception {
  const WeightScaleException(this.message);

  /// The exception message.
  ///
  /// This [message] is guaranteed to be user readable.
  final String message;

  @override
  List<Object?> get props => [message];
}
