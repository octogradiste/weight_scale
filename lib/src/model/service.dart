import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Service {
  final String deviceId;
  final Uuid uuid;
  final List<Characteristic> characteristics;

  const Service({
    required this.deviceId,
    required this.uuid,
    required this.characteristics,
  });

  @override
  bool operator ==(Object other) {
    return other is Service &&
        other.deviceId == deviceId &&
        other.uuid == uuid &&
        listEquals(other.characteristics, characteristics);
  }

  @override
  int get hashCode => hashValues(deviceId, uuid, characteristics);
}
