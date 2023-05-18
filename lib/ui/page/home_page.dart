import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/entity/exercise_log.dart';
import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/data/repository.dart';
import 'package:climb_scale/locator.dart';
import 'package:climb_scale/services/navigation_service.dart';
import 'package:climb_scale/core/bloc/home/home_bloc.dart';
import 'package:climb_scale/ui/screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      lazy: false,
      create: (context) => HomeBloc(
        repository: locator<Repository>(),
        navigationService: locator<INavigationService>(),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('climbScale')),
          body: Container(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is LoadingState) {
                  return const LoadingScreen();
                } else if (state is ShowExercisesState) {
                  return ShowExercisesScreen(exercises: state.exercises);
                } else if (state is ShowExerciseLogsState) {
                  return ShowExerciseLogsScreen(logs: state.logs);
                } else if (state is ShowHangBoardsState) {
                  return ShowHangBoardScreen(hangBoards: state.hangBoards);
                } else {
                  return Center(child: Text('Unknown State: $state'));
                }
              },
            ),
          ),
          floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is ShowExercisesState) {
                return FloatingActionButton(
                  onPressed: () {
                    HomeBloc bloc = context.read();
                    bloc.add(CreateExerciseEvent(Exercise.DEFAULT, false));
                  },
                  child: const Icon(Icons.add),
                );
              } else if (state is ShowExerciseLogsState) {
                return FloatingActionButton(
                  onPressed: () {
                    HomeBloc bloc = context.read();
                    bloc.add(ExportAllLogsEvent());
                  },
                  child: const Icon(Icons.file_download),
                );
              }
              else {
                return Container();
              }
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: const BottomNavBar(),
        );
      }),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        HomeBloc bloc = context.read();
        switch (index) {
          case 0:
            bloc.add(ShowExercisesEvent());
            break;
          case 1:
            bloc.add(ShowExerciseLogsEvent());
            break;
          case 2:
            bloc.add(ShowHangBoardsEvent());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Exercises',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Logs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Hangboards',
        ),
      ],
    );
  }
}

class ShowExercisesScreen extends StatelessWidget {
  final List<Exercise> exercises;

  const ShowExercisesScreen({Key? key, required this.exercises})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: exercises.map((e) => ExerciseTile(exercise: e)).toList(),
    );
  }
}

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final void Function()? onTap;
  final void Function()? onDelete;

  const ExerciseTile({
    Key? key,
    required this.exercise,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeBloc bloc = context.read<HomeBloc>();

    ThemeData theme = Theme.of(context);

    final ButtonStyle _buttonStyle = ButtonStyle(
      elevation: MaterialStateProperty.all(6.0),
      backgroundColor: MaterialStateProperty.all(theme.primaryColorDark),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 20),
          child: Card(
            elevation: 6,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              tileColor: theme.colorScheme.surface,
              // tileColor: theme.primaryColorLight.withOpacity(0.5),
              title: Text(
                exercise.name,
                style: theme.textTheme.titleLarge!.copyWith(fontSize: 18),
              ),
              subtitle: Text(
                exercise.getDescription(),
                style: theme.textTheme.bodyMedium,
              ),
              // onTap: () => bloc.add(StartActivityEvent(exercise)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // IconButton(
                  //   onPressed: () =>
                  //       bloc.add(CreateExerciseEvent(exercise, true)),
                  //   icon: const Icon(Icons.edit),
                  // ),
                  IconButton(
                    onPressed: () => bloc.add(DeleteExerciseEvent(exercise)),
                    icon: const Icon(
                      Icons.delete,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              child: ElevatedButton.icon(
                onPressed: () => bloc.add(StartActivityEvent(exercise)),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Start'),
                style: _buttonStyle,
              ),
            ),
            const SizedBox(width: 40),
            Container(
              width: 100,
              child: ElevatedButton.icon(
                onPressed: () => bloc.add(CreateExerciseEvent(exercise, true)),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: _buttonStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ShowExerciseLogsScreen extends StatelessWidget {
  final List<ExerciseLog> logs;

  const ShowExerciseLogsScreen({
    Key? key,
    required this.logs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: logs.map((log) => ExerciseLogTile(log)).toList(),
      ),
    );
  }
}

class ExerciseLogTile extends StatelessWidget {
  final ExerciseLog log;

  const ExerciseLogTile(
    this.log, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(DateFormat('EEEE, dd.MM.y HH:mm').format(log.date)),
          subtitle: Text(log.exercise.name),
          onTap: () => context.read<HomeBloc>().add(ShowExerciseLogEvent(log)),
        ),
      ),
    );
  }
}

class ShowHangBoardScreen extends StatelessWidget {
  final List<HangBoard> hangBoards;

  const ShowHangBoardScreen({
    Key? key,
    required this.hangBoards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: hangBoards.length,
        itemBuilder: (context, i) => HangBoardTile(hangBoard: hangBoards[i]),
      ),
    );
  }
}

class HangBoardTile extends StatelessWidget {
  final HangBoard hangBoard;

  const HangBoardTile({Key? key, required this.hangBoard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeBloc bloc = context.read<HomeBloc>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(hangBoard.name),
          onTap: () => bloc.add(ShowHangBoardEvent(hangBoard)),
        ),
      ),
    );
  }
}
