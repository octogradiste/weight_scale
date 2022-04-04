import 'package:equatable/equatable.dart';

/// A weight scale exception.
///
/// This exception is thrown by classes implementing [WeightScale] when an ble
/// operation fails.
class WeightScaleException extends Equatable implements Exception {
  const WeightScaleException(this.message);

  /// The exception message.
  ///
  /// This [message] is guaranteed to be user readable.
  final String message;

  @override
  List<Object?> get props => [message];
}
