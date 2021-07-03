import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Service {
  final String deviceId;
  final Uuid uuid;
  final List<Characteristic> characteristics;

  Service({
    required this.deviceId,
    required this.uuid,
    required this.characteristics,
  });
}
