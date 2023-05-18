import 'package:equatable/equatable.dart';

enum GripPosition { openHand, halfCrimp, fullCrimp }

class Grip extends Equatable {
  static const Grip FOUR_FINGER_HALF_CRIMP = Grip(
    position: GripPosition.halfCrimp,
    thumb: false,
    index: true,
    middle: true,
    ring: true,
    pinky: true,
  );

  const Grip({
    required this.position,
    required this.thumb,
    required this.index,
    required this.middle,
    required this.ring,
    required this.pinky,
  });

  final GripPosition position;
  final bool thumb;
  final bool index;
  final bool middle;
  final bool ring;
  final bool pinky;

  @override
  List<Object?> get props => [position, thumb, index, middle, ring, pinky];

  String getDescription() {
    // Counting the number of fingers.
    int fingers = [index, middle, ring, pinky]
        .map((finger) => finger ? 1 : 0)
        .reduce((value, element) => value + element);

    late String grip;
    switch (position) {
      case GripPosition.openHand:
        grip = "open hand";
        break;
      case GripPosition.halfCrimp:
        grip = "half crimp";
        break;
      case GripPosition.fullCrimp:
        grip = "full crimp";
        break;
    }
    return "$fingers fingers $grip";
  }
  String toCSV () {
    String csvOutput = "${getDescription()};";
    return csvOutput;
  }
}
