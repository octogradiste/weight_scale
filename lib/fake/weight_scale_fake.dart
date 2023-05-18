import 'dart:async';
import 'dart:math';
import 'package:weight_scale/scale.dart';

class WeightScaleFake implements WeightScale {
  StreamController<BleDeviceState> _stateController =
      StreamController.broadcast();
  StreamController<Weight> _weightController = StreamController.broadcast();
  Future<bool> _isConnected = Future<bool>.value(false);
  Weight _currentWeight = const Weight(0.0,WeightUnit.kg);
  Random _random = Random();

  WeightScaleFake() {
    Stream.periodic(
      const Duration(milliseconds: 750),
      (_) => _currentWeight = Weight(_random.nextDouble() * 15 + 50,WeightUnit.kg),
    ).listen((weight) async {
      if (await _isConnected) _weightController.add(weight);
    });
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    _stateController.add(BleDeviceState.connecting);
    await Future.delayed(const Duration(seconds: 1));
    _isConnected = Future<bool>.value(true);
    _stateController.add(BleDeviceState.connected);
  }

  @override
  Weight get currentWeight => _currentWeight;

  @override
  Future<void> disconnect() async {
    _stateController.add(BleDeviceState.disconnecting);
    _isConnected = Future<bool>.value(false);
    _stateController.add(BleDeviceState.disconnected);
  }

  @override
  Future<bool> get isConnected => _isConnected;

  @override
  String get name => "The Fake Scale";

  @override
  Stream<BleDeviceState> get state => _stateController.stream;

  WeightUnit get unit => WeightUnit.kg;

  @override
  Stream<Weight> get weight => _weightController.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
