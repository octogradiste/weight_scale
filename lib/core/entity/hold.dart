import 'package:equatable/equatable.dart';

class Hold extends Equatable {
  static const Hold TWENTY_MIL_EDGE =  Hold(name: '20mm Edge', depth: 20);

  final String name;

  /// The (horizontal) depth of the hold in millimeters (including the radius).
  final int depth;

  /// The angle the hold makes to a horizontal line.
  final int angle;

  /// In millimeters.
  final int radius;

  const Hold({
    required this.name,
    required this.depth,
    this.angle = 0,
    this.radius = 0,
  });

  String get description =>
      '${depth}mm deep with ${radius}mm radius at $angle°';

  String toCSV (){
    String csvOutput = "$description;";
    return csvOutput;
  }

  @override
  List<Object?> get props => [name, depth, angle, radius];
}
