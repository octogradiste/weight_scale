import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

class ScalePage extends StatefulWidget {
  final WeightScale scale;

  const ScalePage(this.scale, {Key? key}) : super(key: key);

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  var _connecting = true;
  var _disconnecting = false;

  Future<void> _connect() async {
    try {
      setState(() => _connecting = true);
      await widget.scale.connect();
    } on WeightScaleException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Exception: ${e.message}')));
    } finally {
      setState(() => _connecting = false);
    }
  }

  @override
  void initState() {
    _connect();

    // Setting up automatic reconnection.
    widget.scale.state.skip(1).listen((state) async {
      if (state == BleDeviceState.disconnected && !_disconnecting) {
        do {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unexpected disconnect. Trying to reconnect...'),
          ));
          await _connect();
        } while (!(await widget.scale.isConnected));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _disconnecting = true;
    widget.scale.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.scale.name)),
      body: (!_connecting)
          ? StreamBuilder<BleDeviceState>(
              initialData: BleDeviceState.connecting,
              stream: widget.scale.state,
              builder: (context, snapshot) {
                final state = snapshot.requireData;
                switch (state) {
                  case BleDeviceState.connecting:
                    return const Center(child: Text('Connecting...'));
                  case BleDeviceState.connected:
                    return WeightScreen(widget.scale);
                  case BleDeviceState.disconnecting:
                    return const Center(child: Text('Disconnecting...'));
                  case BleDeviceState.disconnected:
                    return const Center(child: Text('Disconnected.'));
                }
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class WeightScreen extends StatelessWidget {
  final WeightScale scale;

  const WeightScreen(this.scale, {Key? key}) : super(key: key);

  String _weightToString(Weight weight) {
    String value = weight.value.toStringAsFixed(2);
    switch (weight.unit) {
      case WeightUnit.kg:
        return '$value kg';
      case WeightUnit.lbs:
        return '$value lbs';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<Weight>(
          stream: scale.weight,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return Center(
                child: Text(
                  'No data available yet.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              );
            } else {
              return Center(
                child: Text(
                  _weightToString(data),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
