import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:flutter/material.dart';

class BleConnectionStatus extends StatefulWidget {
  final ConnectionStatus status;
  final double? size;
  final Color? color;
  const BleConnectionStatus({
    Key? key,
    required this.status,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  State<BleConnectionStatus> createState() => _BleConnectionStatusState();
}

class _BleConnectionStatusState extends State<BleConnectionStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.status) {
      case ConnectionStatus.connecting:
        return FadeTransition(
          opacity: _animationController,
          child: Icon(
            Icons.bluetooth,
            size: widget.size,
            color: widget.color,
          ),
        );
      case ConnectionStatus.connected:
        return Icon(
          Icons.bluetooth_connected,
          size: widget.size,
          color: widget.color,
        );
      case ConnectionStatus.disconnected:
        return Icon(
          Icons.bluetooth_disabled,
          color: Colors.red,
          size: widget.size,
        );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
