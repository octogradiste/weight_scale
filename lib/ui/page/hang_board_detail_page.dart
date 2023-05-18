import 'package:climb_scale/core/entity/hang_board.dart';
import 'package:climb_scale/core/entity/hold.dart';
import 'package:flutter/material.dart';

class HangBoardDetailPage extends StatelessWidget {
  final HangBoard hangBoard;

  const HangBoardDetailPage({
    Key? key,
    required this.hangBoard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hangBoard.name)),
      body: Container(
        child: ListView.builder(
            itemCount: hangBoard.holds.length,
            itemBuilder: (context, index) {
              Hold hold = hangBoard.holds[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text(hold.name),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(hold.name),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${hold.depth}mm depth'),
                              Text('${hold.radius}mm radius'),
                              Text('${hold.angle} degree angle'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('Measure Max Strength'),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }
}
