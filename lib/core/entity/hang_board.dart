import 'package:climb_scale/core/entity/hold.dart';
import 'package:equatable/equatable.dart';

class HangBoard extends Equatable {
  final String name;
  final List<Hold> holds;

  const HangBoard({
    required this.name,
    required this.holds,
  });

  @override
  List<Object?> get props => [name, holds];
}
