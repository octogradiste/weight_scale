import 'package:equatable/equatable.dart';
import 'package:weight_scale/src/model/characteristic.dart';
import 'package:weight_scale/src/model/uuid.dart';

class Service extends Equatable {
  final String deviceId;
  final Uuid uuid;
  final List<Characteristic> characteristics;
  final List<Service> includedServices;
  final bool isPrimary;

  const Service({
    required this.deviceId,
    required this.uuid,
    required this.characteristics,
    required this.includedServices,
    required this.isPrimary,
  });

  @override
  List<Object?> get props => [
        deviceId,
        uuid,
        characteristics,
        includedServices,
        isPrimary,
      ];
}
