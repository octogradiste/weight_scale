import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

class ScalePage extends StatefulWidget {
  final WeightScale scale;

  ScalePage(this.scale, {Key? key}) : super(key: key);

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  @override
  void initState() {
    widget.scale.connect();
    super.initState();
  }

  @override
  void dispose() {
    widget.scale.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BleDeviceState>(
      initialData: BleDeviceState.connecting,
      stream: widget.scale.state,
      builder: (context, snapshot) {
        final state = snapshot.requireData;
        switch (state) {
          case BleDeviceState.connecting:
            return Center(child: Text('Connecting...'));
          case BleDeviceState.connected:
            return ConnectScreen(widget.scale);
          case BleDeviceState.disconnecting:
            return Center(child: Text('Disconnecting...'));
          case BleDeviceState.disconnected:
            return DisconnectScreen(widget.scale);
        }
      },
    );
  }
}

class ConnectScreen extends StatelessWidget {
  final WeightScale scale;

  const ConnectScreen(this.scale, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Weight>(
          stream: scale.weight,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return Text('No data available !');
            } else {
              String unit;
              switch (data.unit) {
                case WeightUnit.kg:
                  unit = ' kg';
                  break;
                case WeightUnit.lbs:
                  unit = ' lbs';
                  break;
                case WeightUnit.unknown:
                  unit = '';
                  break;
              }
              String weight = data.value.round().toString();
              return Text(weight + unit);
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
      child: ElevatedButton(
        child: Text('RECONNECT'),
        onPressed: () => scale.connect(),
      ),
    );
  }
}
