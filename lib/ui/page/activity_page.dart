import 'dart:math';
import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/activity/ongoing_activity.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/data/repository.dart';
import 'package:climb_scale/locator.dart';
import 'package:climb_scale/services/audio_service.dart';
import 'package:climb_scale/services/hang_board_service.dart';
import 'package:climb_scale/services/navigation_service.dart';
import 'package:climb_scale/services/screen_service.dart';
import 'package:climb_scale/services/snack_bar_service.dart';
import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:climb_scale/core/bloc/activity/activity_bloc.dart';
import 'package:climb_scale/ui/screen/loading_screen.dart';
import 'package:climb_scale/ui/widget/ble_connection_status.dart';
import 'package:climb_scale/ui/widget/exercise_stats.dart';
import 'package:climb_scale/ui/widget/weight_display.dart';
import 'package:climb_scale/ui/widget/weight_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityPage extends StatelessWidget {
  final Exercise exercise;

  const ActivityPage({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityBloc>(
      create: (context) => ActivityBloc(
        audioService: locator<IAudioService>(),
        hangBoardService: locator<HangBoardService>(),
        navigationService: locator<INavigationService>(),
        screenService: locator<IScreenService>(),
        snackBarService: locator<ISnackBarService>(),
        weightScaleService: locator<IWeightScaleService>(),
        repository: locator<Repository>(),
      ),
      child: Builder(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            ActivityBloc bloc = context.read<ActivityBloc>();
            bloc.add(PagePopEvent());
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(exercise.name), const ConnectionInformation()],
              ),
            ),
            body: BlocBuilder<ActivityBloc, ActivityState>(
              builder: (context, state) {
                if (state is InitializeState) {
                  return const LoadingScreen();
                } else if (state is BleScanState) {
                  return BleScanScreen(results: state.results);
                } else if (state is ConnectingState) {
                  return const Center(child: Text('Connecting...'));
                } else if (state is ConnectionFailedState) {
                  return Center(child: Text(state.message));
                } else if (state is TakeWeightState) {
                  return TakeWeightScreen(
                    weight: state.weight,
                    exercise: exercise,
                  );
                } else if (state is DoActivityState) {
                  return HangBoardScreen(state: state);
                } else if (state is FinishedActivityState) {
                  return FinishedActivityScreen(state: state);
                } else {
                  return Center(child: Text('Unknown State: $state'));
                }
              },
            ),
            floatingActionButton: const SearchStopScanFAB(),
          ),
        ),
      ),
    );
  }
}

class FinishedActivityScreen extends StatefulWidget {
  final FinishedActivityState state;

  const FinishedActivityScreen({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<FinishedActivityScreen> createState() => _FinishedActivityScreenState();
}

class _FinishedActivityScreenState extends State<FinishedActivityScreen> {
  final TextEditingController controller = TextEditingController();
  int selected = 3;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Good job!', style: textTheme.headlineLarge),
          ExerciseStats(log: widget.state.log),
          Column(
            children: [
              Sentiment(
                onChanged: (selection) => setState(() => selected = selection),
                selected: selected,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: null,
                  decoration: const InputDecoration(
                    label: Text('Note'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              ExerciseLog log = widget.state.log.addUserFeedback(
                mark: selected,
                note: controller.text,
              );
              context.read<ActivityBloc>().add(SaveExerciseLog(log));
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }
}

class Sentiment extends StatelessWidget {
  final void Function(int)? onChanged;
  final int selected;

  const Sentiment({
    Key? key,
    this.onChanged,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'How did you feel?',
          style: textTheme.headlineSmall,
        ),
        Opacity(
          opacity: 0.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SentimentIcon(
                onPressed: () => onChanged?.call(1),
                icon: Icon(
                  Icons.sentiment_very_dissatisfied,
                  color: Colors.red.shade700,
                ),
                selected: selected == 1,
              ),
              SentimentIcon(
                onPressed: () => onChanged?.call(2),
                icon: Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.orange.shade700,
                ),
                selected: selected == 2,
              ),
              SentimentIcon(
                onPressed: () => onChanged?.call(3),
                icon: Icon(
                  Icons.sentiment_neutral,
                  color: Colors.yellow.shade700,
                ),
                selected: selected == 3,
              ),
              SentimentIcon(
                onPressed: () => onChanged?.call(4),
                icon: Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.green.shade400,
                ),
                selected: selected == 4,
              ),
              SentimentIcon(
                onPressed: () => onChanged?.call(5),
                icon: Icon(
                  Icons.sentiment_very_satisfied,
                  color: Colors.green.shade900,
                ),
                selected: selected == 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SentimentIcon extends StatelessWidget {
  final void Function()? onPressed;
  final Icon icon;
  final bool selected;

  const SentimentIcon({
    Key? key,
    required this.icon,
    required this.selected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1 : 0.3,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: 42,
      ),
    );
  }
}

class ConnectionInformation extends StatelessWidget {
  const ConnectionInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityBloc bloc = context.read<ActivityBloc>();
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (_, state) {
        if (state is ConnectedState && state is! ConnectingState) {
          return StreamBuilder<ConnectionStatus>(
            initialData: state.information.initialConnection,
            stream: state.information.connection,
            builder: (_, snapshot) {
              return GestureDetector(
                child: BleConnectionStatus(status: snapshot.requireData),
                onTap: () => bloc.add(ShowConnectionDetail()),
              );
            },
          );
        } else {
          return const Text('');
        }
      },
    );
  }
}

class SearchStopScanFAB extends StatelessWidget {
  const SearchStopScanFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityBloc bloc = context.read<ActivityBloc>();

    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is BleScanState) {
          if (state.searching) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => bloc.add(StopScanEvent()),
            );
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () => bloc.add(StartScanEvent()),
            );
          }
        }
        return Container();
      },
    );
  }
}

class BleScanScreen extends StatelessWidget {
  final Stream<List<ScanResult>> results;

  const BleScanScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
        stream: results,
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: (snapshot.data ?? [])
                .map((result) => WeighScaleTile(result: result))
                .toList(),
          );
        });
  }
}

class WeighScaleTile extends StatelessWidget {
  final ScanResult result;

  const WeighScaleTile({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityBloc bloc = context.read<ActivityBloc>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(6),
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(result.imagePath),
          ),
          onTap: () => bloc.add(ConnectEvent(result)),
          title: Text(
            result.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(result.manufacturer),
          trailing: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.arrow_forward_ios_rounded),
          ),
        ),
      ),
    );
  }
}

class TakeWeightScreen extends StatelessWidget {
  final Stream<double> weight;
  final Exercise exercise;

  const TakeWeightScreen({
    Key? key,
    required this.weight,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ActivityBloc bloc = context.read<ActivityBloc>();
    return Center(
      child: StreamBuilder<double>(
        stream: weight,
        builder: (context, snapshot) {
          double weight = snapshot.data ?? 0.0;
          weight = (100 * weight).roundToDouble() / 100;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Measure your weight"),
              ),
              WeightDisplay(weight: weight, precision: 1),
              Container(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  onPressed: () {
                    bloc.add(BeginActivityEvent(exercise, weight));
                  },
                  child: const Text('OK, let\'s start'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class HangBoardScreen extends StatelessWidget {
  final DoActivityState state;
  const HangBoardScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OngoingActivity>(
      initialData: state.initialState,
      stream: state.state,
      builder: (context, snapshot) {
        OngoingActivity state = snapshot.requireData;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RestOrPull(
                  pulling: state.info.isHanging,
                ),
                CurrentHold(
                  hand: state.info.hand.name,
                  grab: state.info.exercise.grip.getDescription(),
                  hold: state.info.exercise.hold.name,
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: WeightIndicator(
                      pull: state.info.isHanging ? max(0, state.pull) : 0,
                      exercise: state.info.exercise,
                    ),
                  ),
                  TimerDisplay(
                    time: state.info.time,
                  ),
                  state.info.exercise.isAssessment ? const Text("This is a max strength test") : const Text(""),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CurrentRepSet(
                  title: "reps",
                  current: state.info.currentRep,
                  total: state.info.exercise.reps,
                ),
                CurrentRepSet(
                  title: "sets",
                  current: state.info.currentSet,
                  total: state.info.exercise.sets,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class RestOrPull extends StatelessWidget {
  final bool pulling;
  const RestOrPull({Key? key, required this.pulling}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        pulling ? "pull!" : "rest!",
        style: TextStyle(
            fontSize: 30, color: pulling ? Colors.green : Colors.blueGrey),
      ),
    );
  }
}

class CurrentHold extends StatelessWidget {
  final String hand;
  final String grab;
  final String hold;
  const CurrentHold(
      {Key? key, required this.hand, required this.grab, required this.hold})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(
            hand,
            style: const TextStyle(fontSize: 30),
          ),
          Text(
            grab,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            hold,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final Duration time;
  const TimerDisplay({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        "${time.inSeconds.toString()} sec",
        style: const TextStyle(fontSize: 40),
      ),
    );
  }
}

class CurrentRepSet extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  const CurrentRepSet(
      {Key? key,
      required this.title,
      required this.current,
      required this.total})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 25)),
          Text(
            "$current/$total",
            style: const TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }
}
