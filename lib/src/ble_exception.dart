import 'package:equatable/equatable.dart';

/// An exception thrown if any ble action fails.
class BleException extends Equatable implements Exception {
  /// This message should be human readable and can be shown to users.
  final String message;

  /// This is a more detailed version of the message and is not intended
  /// to be shown to an user.
  final String? detail;

  /// The internal exception which caused the problem.
  final Object? exception;

  const BleException(this.message, {this.detail, this.exception});

  @override
  List<Object?> get props => [message, detail, exception];
}
