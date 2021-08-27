import 'package:weight_scale/scale.dart';
import 'package:weight_scale/src/ble_device.dart';
import 'package:weight_scale/src/util/state_stream.dart';

/// Mi Body Composition Sacle 2
class MiScale2 implements WeightScale {
  bool _isConneced = false;
  final StateStream<double> _weight = StateStream(initValue: 0.0);
  late final BleDevice _device;
  late final WeightScaleUnit _unit;

  @override
  final String name = "Mi Body Composition Sacle 2";
  @override
  late final weight = _weight.events;

  MiScale2({required BleDevice bleDevice, required WeightScaleUnit unit}) {
    _device = bleDevice;
    _unit = unit;
  }

  @override
  WeightScaleUnit get unit => unit;

  @override
  double get currentWeight => _weight.state;

  @override
  bool get isConnected => _isConneced;
  @override
  Future<void> connect(
      {Duration timeout = const Duration(seconds: 15)}) async {}

  @override
  Future<void> disconnect() async {}
}
