import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/core/entity/hold.dart';
import 'package:flutter/material.dart';

class HoldPickerDialog extends StatefulWidget {
  final List<HangBoard> hangBoards;
  final void Function(Hold) onChosen;

  const HoldPickerDialog({
    Key? key,
    required this.hangBoards,
    required this.onChosen,
  }) : super(key: key);

  @override
  State<HoldPickerDialog> createState() => _HoldPickerDialogState();
}

class _HoldPickerDialogState extends State<HoldPickerDialog> {
  int selected = -1; // The index of the selected hang board.

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
            child: Text(
              selected != -1 ? 'Holds' : 'Hangboards',
              textAlign: TextAlign.center,
              style: theme.primaryTextTheme.titleLarge,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              reverseDuration: Duration.zero,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _buildListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (selected == -1) {
      return ListView.separated(
        key: const ValueKey(1),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: false,
        itemBuilder: (_, index) => HangBoardTile(
          hangBoard: widget.hangBoards[index],
          onTap: () => setState(() => selected = index),
        ),
        separatorBuilder: (_, __) => const Divider(thickness: 2),
        itemCount: widget.hangBoards.length,
      );
    } else {
      return ListView.separated(
        key: const ValueKey(2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, i) => HoldTile(
          hold: widget.hangBoards[selected].holds[i],
          onTap: () {
            Navigator.pop(context);
            widget.onChosen(widget.hangBoards[selected].holds[i]);
          },
        ),
        separatorBuilder: (_, __) => const Divider(thickness: 2),
        itemCount: widget.hangBoards[selected].holds.length,
      );
    }
  }
}

class HangBoardTile extends StatelessWidget {
  final HangBoard hangBoard;
  final void Function()? onTap;

  const HangBoardTile({
    Key? key,
    required this.hangBoard,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(hangBoard.name),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
      onTap: onTap,
    );
  }
}

class HoldTile extends StatelessWidget {
  final Hold hold;
  final void Function()? onTap;

  const HoldTile({Key? key, required this.hold, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(hold.name),
      subtitle: Text(hold.description),
      onTap: onTap,
    );
  }
}
