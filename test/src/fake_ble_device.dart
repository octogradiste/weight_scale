import 'package:mockito/mockito.dart';
import 'package:weight_scale/ble.dart';

class FakeBleDevice extends Fake implements BleDevice {
  @override
  final String name;
  @override
  final String id;

  FakeBleDevice({
    required this.id,
    required this.name,
  });
}
