import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

class ScalePage extends StatefulWidget {
  final WeightScale scale;

  const ScalePage(this.scale, {Key? key}) : super(key: key);

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  @override
  void initState() {
    widget.scale.connect().catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: ${(e as WeightScaleException).message}'),
        ),
      );
    }, test: (e) => e is WeightScaleException);
    super.initState();
  }

  @override
  void dispose() {
    widget.scale.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.scale.name)),
      body: StreamBuilder<BleDeviceState>(
        initialData: BleDeviceState.connecting,
        stream: widget.scale.state,
        builder: (context, snapshot) {
          final state = snapshot.requireData;
          switch (state) {
            case BleDeviceState.connecting:
              return const Center(child: Text('Connecting...'));
            case BleDeviceState.connected:
              return ConnectScreen(widget.scale);
            case BleDeviceState.disconnecting:
              return const Center(child: Text('Disconnecting...'));
            case BleDeviceState.disconnected:
              return DisconnectScreen(widget.scale);
          }
        },
      ),
    );
  }
}

class ConnectScreen extends StatelessWidget {
  final WeightScale scale;

  const ConnectScreen(this.scale, {Key? key}) : super(key: key);

  String _weightToString(Weight weight) {
    String value = weight.value.toStringAsFixed(2);
    switch (weight.unit) {
      case WeightUnit.kg:
        return '$value kg';
      case WeightUnit.lbs:
        return '$value lbs';
      case WeightUnit.unknown:
        return value;
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
                  style: Theme.of(context).textTheme.headline5,
                ),
              );
            } else {
              return Center(
                child: Text(
                  _weightToString(data),
                  style: Theme.of(context).textTheme.headline4,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class DisconnectScreen extends StatelessWidget {
  final WeightScale scale;

  const DisconnectScreen(this.scale, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text('RECONNECT'),
        onPressed: () async {
          try {
            await scale.connect();
          } on WeightScaleException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exception: ${e.message}')),
            );
          }
        },
      ),
    );
  }
}
