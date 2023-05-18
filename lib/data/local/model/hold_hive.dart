import 'package:climb_scale/core/entity/hold.dart';
import 'package:hive/hive.dart';

part 'hold_hive.g.dart';

@HiveType(typeId: 4)
class HoldHive extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int depth;
  @HiveField(2)
  final int angle;
  @HiveField(3)
  final int radius;

  HoldHive({
    required this.name,
    required this.depth,
    this.angle = 0,
    this.radius = 0,
  });

  HoldHive.fromHold(Hold hold)
      : name = hold.name,
        depth = hold.depth,
        angle = hold.angle,
        radius = hold.radius;

  Hold toHold() {
    return Hold(name: name, depth: depth);
  }
}
