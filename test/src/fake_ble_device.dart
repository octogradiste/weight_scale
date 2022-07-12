import 'package:mockito/mockito.dart';
import 'package:weight_scale/src/ble/ble.dart';

class FakeBleDevice extends Fake implements BleDevice {
  @override
  final BleDeviceInformation information;

  FakeBleDevice({
    required String id,
    required String name,
  }) : information = BleDeviceInformation(name: name, id: id);
}
