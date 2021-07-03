import 'package:weight_scale/src/model/uuid.dart';

class Descriptor {
  final String deviceId;
  final Uuid serviceUuid;
  final Uuid characteristicUuid;
  final Uuid uuid;

  Descriptor({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.uuid,
  });
}
