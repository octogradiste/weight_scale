import 'package:climb_scale/core/entity/exercise.dart';
import 'package:climb_scale/core/bloc/home/home_bloc.dart';
import 'package:climb_scale/core/entity/grip.dart';
import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/core/entity/hold.dart';
import 'package:climb_scale/data/local/sample_exercises.dart';
import 'package:climb_scale/ui/dialog/hold_picker_dialog.dart';
import 'package:climb_scale/ui/snack_bar/info_snack_bar.dart';
import 'package:climb_scale/ui/widget/input_field.dart';
import 'package:climb_scale/utils/exercise_builder.dart';
import 'package:flutter/material.dart';

class CreateExercisePage extends StatelessWidget {
  final HomeBloc bloc;
  final Exercise template;
  final bool edit;

  final ExerciseBuilder _exerciseBuilder;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// The exercise form will be filled with the [template] values.
  /// If [edit] is true, will send an [EditExerciseEvent] instead of a
  /// [SaveExerciseEvent] when the user saves the changes.
  CreateExercisePage({
    Key? key,
    required this.bloc,
    required this.template,
    required this.edit,
  })  : _exerciseBuilder = ExerciseBuilder.fromExercise(template),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bloc.add(ShowExercisesEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(edit ? 'Edit exercise' : 'Create exercise'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: StringInputField(
                  label: 'Name',
                  initialValue: template.name,
                  onSaved: (n) => _exerciseBuilder.name = n,
                ),
              ),
              Section(
                title: 'Sets',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: NumberInputField(
                            label: 'Number of sets',
                            initialValue: template.sets,
                            onSaved: (s) => _exerciseBuilder.sets = s,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: NumberInputField(
                            label: 'Rest bet. sets [s]',
                            initialValue: template.restBetweenSets.inSeconds,
                            onSaved: (s) => _exerciseBuilder.restBetweenSets =
                                Duration(seconds: s),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Section(
                title: 'Reps',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: NumberInputField(
                            label: 'Rep time [s]',
                            initialValue: template.hangTime.inSeconds,
                            onSaved: (h) => _exerciseBuilder.hangTime =
                                Duration(seconds: h),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: NumberInputField(
                            label: 'Rest bet. reps [s]',
                            initialValue: template.restBetweenReps.inSeconds,
                            onSaved: (r) => _exerciseBuilder.restBetweenReps =
                                Duration(seconds: r),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: NumberInputField(
                            label: 'Number of reps',
                            initialValue: template.reps,
                            onSaved: (r) => _exerciseBuilder.reps = r,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: NumberInputField(
                            label: 'Intensity [kg]',
                            initialValue: template.target.round(),
                            onSaved: (t) =>
                                _exerciseBuilder.target = t.toDouble(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Section(
                title: 'Advanced',
                initiallyOpen: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: NumberInputField(
                            label: 'Countdown [s]',
                            initialValue: template.countdown.inSeconds,
                            onSaved: (c) => _exerciseBuilder.countdown =
                                Duration(seconds: c),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: NumberInputField(
                            label: 'Deviation [kg]',
                            initialValue: template.deviation.round(),
                            onSaved: (d) =>
                                _exerciseBuilder.deviation = d.toDouble(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: NumberInputField(
                            label: 'Rest bet. hands [s]',
                            initialValue: template.restBetweenHands.inSeconds,
                            onSaved: (r) => _exerciseBuilder.restBetweenHands =
                                Duration(seconds: r),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: DropdownInputField<Hands>(
                            initialItem: template.hands,
                            items: const [Hands.block_wise, Hands.both],
                            names: const {
                              Hands.block_wise: 'Alternating',
                              Hands.both: 'Both hands',
                            },
                            label: 'Hands',
                            onSaved: (h) => _exerciseBuilder.hands = h,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: SwitchInputField(
                            title: const Text("Strength assessment"),
                            subtitle: const Text("Is this exercise a strength test?"),
                            initialValue: template.isAssessment,
                            onSaved: (a) => _exerciseBuilder.isAssessment = a,
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Section(
                title: 'Hold / Grip',
                initiallyOpen: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: HoldInputField(
                      initialHold: template.hold,
                      hangBoards: const [beastmaker1000],
                      onSaved: (h) => _exerciseBuilder.hold = h,
                    ),
                  ),
                  GripInputField(
                    initialGrip: template.grip,
                    onSaved: (g) => _exerciseBuilder.grip = g,
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        if (edit) {
                          bloc.add(EditExerciseEvent(
                            template,
                            _exerciseBuilder.build(),
                          ));
                        } else {
                          bloc.add(SaveExerciseEvent(_exerciseBuilder.build()));
                        }
                      } else {
                        var messenger = ScaffoldMessenger.of(context);
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          InfoSnackBar('Some fields are not valid!'),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchInputField extends FormField<bool>{
  SwitchInputField({
    void Function(bool)? onSaved,
    required bool initialValue,
    required Text title,
    required Text subtitle,
  })
      : super(
          onSaved: (value) => onSaved?.call(value!),
          initialValue: initialValue,
          builder: (state) {
            return SwitchListTile(
                title: title,
                subtitle: subtitle,
                value: state.value!,
                onChanged: (bool value) => state.didChange(value),
            );
          },
  );
}
class GripInputField extends FormField<Grip> {
  GripInputField({required Grip initialGrip, void Function(Grip)? onSaved})
      : super(
          initialValue: initialGrip,
          onSaved: (grip) => onSaved?.call(grip!),
          builder: (state) {
            TextTheme textTheme = Theme.of(state.context).textTheme;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownInputField<GripPosition>(
                          initialItem: initialGrip.position,
                          items: GripPosition.values,
                          names: const {
                            GripPosition.openHand: 'Open Hand',
                            GripPosition.halfCrimp: 'Half Crimp',
                            GripPosition.fullCrimp: 'Full Crimp'
                          },
                          label: 'Grip',
                          onSaved: (position) {
                            Grip grip = state.value!;
                            state.didChange(
                              Grip(
                                thumb: grip.thumb,
                                index: grip.index,
                                middle: grip.middle,
                                ring: grip.ring,
                                pinky: grip.pinky,
                                position: position,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Select active fingers',
                          overflow: TextOverflow.fade,
                          style: textTheme.labelMedium,
                        ),
                      ),
                      MultiToggleInputField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        children: const [
                          Text('Thumb'),
                          Text('Index'),
                          Text('Middle'),
                          Text('Ring'),
                          Text('Pinky')
                        ],
                        selected: [
                          initialGrip.thumb,
                          initialGrip.index,
                          initialGrip.middle,
                          initialGrip.ring,
                          initialGrip.pinky,
                        ],
                        validator: (selection) {
                          if (!selection.firstWhere((s) => s,
                              orElse: () => false)) {
                            return 'Please select at least one element.';
                          }
                          return null;
                        },
                        onSave: (selection) {
                          state.didChange(
                            Grip(
                              thumb: selection[0],
                              index: selection[1],
                              middle: selection[2],
                              ring: selection[3],
                              pinky: selection[4],
                              position: state.value!.position,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
}

class HoldInputField extends FormField<Hold> {
  HoldInputField({
    required Hold initialHold,
    required List<HangBoard> hangBoards,
    void Function(Hold)? onSaved,
  }) : super(
          initialValue: initialHold,
          onSaved: (hold) => onSaved?.call(hold!),
          builder: (state) => HoldChooser(
            initialHold: initialHold,
            hangBoards: hangBoards,
            onChange: (hold) => state.didChange(hold),
          ),
        );
}

class HoldChooser extends StatefulWidget {
  final Hold initialHold;
  final List<HangBoard> hangBoards;
  final void Function(Hold)? onChange;

  const HoldChooser({
    Key? key,
    required this.initialHold,
    required this.hangBoards,
    this.onChange,
  }) : super(key: key);

  @override
  State<HoldChooser> createState() => _HoldChooserState();
}

class _HoldChooserState extends State<HoldChooser> {
  late Hold _hold;

  @override
  void initState() {
    super.initState();
    _hold = widget.initialHold;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hold.name,
                  style: textTheme.titleLarge,
                ),
                Text(
                  _hold.description,
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => HoldPickerDialog(
                hangBoards: widget.hangBoards,
                onChosen: (hold) => setState((() {
                  _hold = hold;
                  widget.onChange?.call(hold);
                })),
              ),
            );
          },
          child: const Text('Select Hold'),
        ),
      ],
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyOpen;

  const Section({
    Key? key,
    required this.title,
    required this.children,
    this.initiallyOpen = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionTile(
        title: Text(title),
        children: children,
        initiallyExpanded: initiallyOpen,
      ),
    );
  }
}
