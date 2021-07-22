import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Descriptor {
  final String deviceId;
  final Uuid serviceUuid;
  final Uuid characteristicUuid;
  final Uuid uuid;
  final Uint8List value;

  Descriptor({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.uuid,
    required this.value,
  });

  @override
  bool operator ==(Object other) {
    return other is Descriptor &&
        other.deviceId == deviceId &&
        other.serviceUuid == serviceUuid &&
        other.characteristicUuid == characteristicUuid &&
        other.uuid == uuid &&
        other.value == value;
  }

  @override
  int get hashCode => hashValues(
        deviceId,
        serviceUuid,
        characteristicUuid,
        uuid,
        value,
      );
}
