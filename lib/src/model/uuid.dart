import 'package:equatable/equatable.dart';

class Uuid extends Equatable {
  final String uuid;

  const Uuid(this.uuid);

  @override
  List<Object?> get props => [uuid];
}
