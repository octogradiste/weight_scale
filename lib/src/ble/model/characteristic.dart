import 'package:equatable/equatable.dart';
import 'package:weight_scale/src/ble/ble.dart';

class Characteristic extends Equatable {
  final String deviceId;
  final Uuid serviceUuid;
  final Uuid uuid;
  final List<Descriptor> descriptors;

  const Characteristic({
    required this.deviceId,
    required this.serviceUuid,
    required this.uuid,
    this.descriptors = const [],
  });

  @override
  List<Object?> get props => [deviceId, serviceUuid, uuid, descriptors];
}
