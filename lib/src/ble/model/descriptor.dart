import 'package:equatable/equatable.dart';
import 'package:weight_scale/src/ble/ble.dart';

class Descriptor extends Equatable {
  final String deviceId;
  final Uuid serviceUuid;
  final Uuid characteristicUuid;
  final Uuid uuid;

  const Descriptor({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.uuid,
  });

  @override
  List<Object?> get props => [deviceId, serviceUuid, characteristicUuid, uuid];
}
