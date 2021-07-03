import 'package:weight_scale/src/model/descriptor.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Characteristic {
  final String deviceId;
  final Uuid serviceUuid;
  final Uuid uuid;
  final List<Descriptor> descriptors;

  Characteristic({
    required this.deviceId,
    required this.serviceUuid,
    required this.uuid,
    this.descriptors = const [],
  });
}
