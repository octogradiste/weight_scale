import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/data/local/model/hold_hive.dart';
import 'package:hive/hive.dart';

part 'hang_board_hive.g.dart';

@HiveType(typeId: 5)
class HangBoardHive extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<HoldHive> holds;

  HangBoardHive({
    required this.name,
    required this.holds,
  });

  HangBoardHive.fromHangBoard(HangBoard hangBoard)
      : name = hangBoard.name,
        holds = hangBoard.holds.map((hold) => HoldHive.fromHold(hold)).toList();

  HangBoard toHangBoard() {
    return HangBoard(
      name: name,
      holds: holds.map((hold) => hold.toHold()).toList(),
    );
  }
}
