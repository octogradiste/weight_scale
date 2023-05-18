import 'package:climb_scale/core/entity/grip.dart';
import 'package:hive/hive.dart';

part 'grip_hive.g.dart';

@HiveType(typeId: 2)
enum GripPositionHive {
  @HiveField(0)
  openHand,
  @HiveField(1)
  halfCrimp,
  @HiveField(2)
  fullCrimp,
}

@HiveType(typeId: 3)
class GripHive extends HiveObject {
  GripHive({
    required this.position,
    required this.thumb,
    required this.index,
    required this.middle,
    required this.ring,
    required this.pinky,
  });

  @HiveField(0)
  final GripPositionHive position;
  @HiveField(1)
  final bool thumb;
  @HiveField(2)
  final bool index;
  @HiveField(3)
  final bool middle;
  @HiveField(4)
  final bool ring;
  @HiveField(5)
  final bool pinky;

  GripHive.fromGrip(Grip grip)
      : position = GripPositionHive.values[grip.position.index],
        thumb = grip.thumb,
        index = grip.index,
        middle = grip.middle,
        ring = grip.ring,
        pinky = grip.pinky;

  Grip toGrip() {
    return Grip(
      position: GripPosition.values[position.index],
      thumb: thumb,
      index: index,
      middle: middle,
      ring: ring,
      pinky: pinky,
    );
  }
}
