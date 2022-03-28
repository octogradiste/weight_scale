import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Descriptor extends Equatable {
  final String deviceId;
  final Uuid serviceUuid;
  final Uuid characteristicUuid;
  final Uuid uuid;
  final Uint8List value;

  const Descriptor({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.uuid,
    required this.value,
  });

  @override
  List<Object?> get props => [
        deviceId,
        serviceUuid,
        characteristicUuid,
        uuid,
        value,
      ];
}
