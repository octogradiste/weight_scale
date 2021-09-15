import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:weight_scale/src/model/descriptor.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Characteristic {
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
  bool operator ==(Object other) {
    return other is Characteristic &&
        other.deviceId == deviceId &&
        other.serviceUuid == serviceUuid &&
        other.uuid == uuid &&
        listEquals(other.descriptors, other.descriptors);
  }

  @override
  int get hashCode => hashValues(deviceId, serviceUuid, uuid, descriptors);
}
