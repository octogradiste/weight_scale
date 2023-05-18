import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/grip.dart';
import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/core/entity/hold.dart';

// Sample default exercises to be loaded when starting first the app.
// Exercises are added in the database.dart initialize() function.

// Source: https://www.reddit.com/r/climbharder/comments/cek236/beastmaker_1000_and_2000_edgehold_sizes/
const HangBoard beastmaker1000 = HangBoard(
  name: 'Beastmaker 1000 Series',
  holds: [
    Hold(name: 'Jug', depth: 58),
    Hold(name: '35 Degree Sloper', depth: 58, angle: 35),
    Hold(name: '20 Degree Sloper', depth: 58, angle: 20),
    Hold(name: 'Small Edge', depth: 15, radius: 2),
    Hold(name: '3 Fingers First Row', depth: 30, radius: 2),
    Hold(name: 'Large Edge', depth: 45, radius: 2),
    Hold(name: 'Deep 2 Finger Pocket', depth: 50, radius: 2),
    Hold(name: 'Deep 3 Finger Pocket', depth: 45, radius: 2),
    Hold(name: 'Big Center Edge', depth: 52, radius: 2),
    Hold(name: 'Medium Edge', depth: 20, radius: 2),
    Hold(name: 'Shallow 2 Finger Pocket', depth: 25, radius: 2),
    Hold(name: 'Shallow 3 Finger Pocket', depth: 20, radius: 2),
  ],
);

const List sample_exercises = [
  warmup,
  low_intensity,
  medium_intensity,
  high_intensity,
  strength,
  hypertrophy,
  strength_test,
];

const Duration _countdown = Duration(seconds: 10);
const Duration _restBetweenHands = Duration(seconds: 15);
const double _deviation = 4; // kg

const Exercise warmup = Exercise(
  name: "Warm up 18-21kg",
  countdown: _countdown,
  reps: 10,
  hangTime: Duration(seconds: 7),
  restBetweenReps: Duration(seconds: 5),
  sets: 2,
  restBetweenSets: Duration(minutes: 1),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 20,
  deviation: _deviation,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: false,
);

const Exercise low_intensity = Exercise(
  name: "Low intensity 18-21kg",
  countdown: _countdown,
  reps: 15,
  hangTime: Duration(seconds: 7),
  restBetweenReps: Duration(seconds: 3),
  sets: 2,
  restBetweenSets: Duration(minutes: 1),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 18,
  deviation: _deviation,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: false,
);

const Exercise medium_intensity = Exercise(
  name: "Medium intensity 28-33kg",
  countdown: _countdown,
  reps: 10,
  hangTime: Duration(seconds: 6),
  restBetweenReps: Duration(seconds: 3),
  sets: 3,
  restBetweenSets: Duration(minutes: 1),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 28,
  deviation: _deviation,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: false,
);

const Exercise high_intensity = Exercise(
  name: "High intensity 30-36kg",
  countdown: _countdown,
  reps: 10,
  hangTime: Duration(seconds: 5),
  restBetweenReps: Duration(seconds: 5),
  sets: 3,
  restBetweenSets: Duration(seconds: 110),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 30,
  deviation: _deviation,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: false,
);

const Exercise hypertrophy = Exercise(
  name: "Hypertrophy 33-39kg",
  countdown: _countdown,
  reps: 6,
  hangTime: Duration(seconds: 8),
  restBetweenReps: Duration(seconds: 3),
  sets: 3,
  restBetweenSets: Duration(minutes: 1),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 33,
  deviation: _deviation,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: false,
);

const Exercise strength = Exercise(
  name: "Strength 40-48kg",
  countdown: _countdown,
  reps: 1,
  hangTime: Duration(seconds: 7),
  restBetweenReps: Duration(seconds: 0),
  sets: 6,
  restBetweenSets: Duration(seconds: 90),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 40,
  deviation: _deviation,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: false,
);

const Exercise strength_test = Exercise(
  name: "Strength test",
  countdown: _countdown,
  reps: 1,
  hangTime: Duration(seconds: 5),
  restBetweenReps: Duration(seconds: 0),
  sets: 1,
  restBetweenSets: Duration(seconds: 120),
  hands: Hands.block_wise,
  restBetweenHands: _restBetweenHands,
  target: 60,
  deviation: 55,
  grip: Grip.FOUR_FINGER_HALF_CRIMP,
  hold: Hold.TWENTY_MIL_EDGE,
  isAssessment: true,
);

