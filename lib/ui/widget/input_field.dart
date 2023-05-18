import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String? label;
  final String? initialValue;
  final void Function(String?)? onSaved;
  final TextInputType type;
  final String? Function(String?)? validator;

  const InputField({
    Key? key,
    this.label,
    this.initialValue,
    this.onSaved,
    this.type = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: type,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

class NumberInputField extends InputField {
  NumberInputField({
    String? label,
    int? initialValue,
    void Function(int)? onSaved,
  }) : super(
          label: label,
          initialValue: initialValue.toString(),
          type: TextInputType.number,
          onSaved: (value) => onSaved?.call(int.parse(value ?? '0')),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number.';
            } else if (RegExp('\\D').hasMatch(value)) {
              return 'Not a valid number.';
            }
            return null;
          },
        );
}

class StringInputField extends InputField {
  StringInputField({
    String? label,
    String? initialValue,
    void Function(String)? onSaved,
  }) : super(
          label: label,
          initialValue: initialValue,
          onSaved: (value) => onSaved?.call(value ?? ''),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text.';
            }
            return null;
          },
        );
}

class DropdownInputField<T> extends StatefulWidget {
  final T initialItem;
  final List<T> items;
  final Map<T, String> names;
  final String? label;
  final void Function(T)? onSaved;

  DropdownInputField({
    Key? key,
    required this.initialItem,
    required this.items,
    required this.names,
    this.label,
    this.onSaved,
  })  : assert(items.contains(initialItem)),
        super(key: key);

  @override
  State<DropdownInputField> createState() =>
      _DropdownInputFieldState<T>(items: items, names: names, onSave: onSaved);
}

class _DropdownInputFieldState<T> extends State<DropdownInputField> {
  late T currentItem;

  final List<T> items;
  final Map<T, String> names;
  final void Function(T)? onSave;

  _DropdownInputFieldState(
      {required this.items, required this.names, this.onSave});

  @override
  void initState() {
    currentItem = widget.initialItem as T;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      value: currentItem,
      elevation: 16,
      onChanged: (T? newValue) {
        setState(() => currentItem = newValue as T);
      },
      onSaved: (value) => onSave?.call(value as T),
      items: items.map((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(widget.names[value] ?? ''),
        );
      }).toList(),
    );
  }
}

class MultiToggleInputField extends FormField<List<bool>> {
  MultiToggleInputField({
    Key? key,
    required List<Widget> children,
    required List<bool> selected,
    void Function(List<bool>)? onSave,
    String? Function(List<bool>)? validator,
    AutovalidateMode? autovalidateMode,
  })  : assert(selected.length == children.length),
        assert(children.isNotEmpty),
        super(
          key: key,
          initialValue: selected,
          onSaved: (selection) => onSave?.call(selection!),
          validator: (selection) => validator?.call(selection!),
          autovalidateMode: autovalidateMode,
          builder: (state) {
            ThemeData theme = Theme.of(state.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ToggleButtons(
                  children: children,
                  isSelected: state.value!,
                  selectedBorderColor: theme.primaryColorDark,
                  borderColor: (state.hasError) ? theme.colorScheme.error : null,
                  borderRadius: BorderRadius.circular(8),
                  borderWidth: 1,
                  onPressed: (i) {
                    var selection = state.value!;
                    selection[i] = !selection[i];
                    state.didChange(selection);
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 12, 0),
                    child: Text(
                      state.errorText!,
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
