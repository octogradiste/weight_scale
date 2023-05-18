import 'package:climb_scale/core/entity/activity/connection_information.dart';
import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:climb_scale/ui/widget/ble_connection_status.dart';
import 'package:flutter/material.dart';

class ConnectionDetailDialog extends StatelessWidget {
  final ConnectionInformation information;
  final void Function() onReconnect;

  const ConnectionDetailDialog({
    Key? key,
    required this.information,
    required this.onReconnect,
  }) : super(key: key);

  String _connectionToString(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        Center(
          child: TextButton(
            onPressed: onReconnect,
            child: const Text('Reconnect'),
          ),
        )
      ],
      content: StreamBuilder<ConnectionStatus>(
        initialData: information.initialConnection,
        stream: information.connection,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: BleConnectionStatus(
                  status: snapshot.requireData,
                  size: 54,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                information.result.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                _connectionToString(snapshot.requireData),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }
}
