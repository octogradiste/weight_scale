import 'package:equatable/equatable.dart';

import 'hang_board_state.dart';

class OngoingActivity extends Equatable {
  final HangBoardState info;
  final double pull;

  OngoingActivity({
    required this.info,
    required this.pull,
  });

  @override
  List<Object> get props => [pull, info];
}
