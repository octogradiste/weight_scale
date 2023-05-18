import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/data/local/model/hang_board_hive.dart';
import 'package:hive/hive.dart';

class HangBoardDao {
  final Box<HangBoardHive> box;

  HangBoardDao(this.box);

  Future<void> deleteHangBoard(HangBoard hangBoard) async {
    await box.delete(HangBoardHive.fromHangBoard(hangBoard).name);
  }

  Future<List<HangBoard>> getHangBoards() async {
    return box.values.map((e) => e.toHangBoard()).toList();
  }

  Future<void> saveHangBoard(HangBoard hangBoard) async {
    await box.put(hangBoard.name, HangBoardHive.fromHangBoard(hangBoard));
  }
}
