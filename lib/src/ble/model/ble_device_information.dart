import 'package:equatable/equatable.dart';

/// Contains the [name] and [id] of a ble device.
class BleDeviceInformation extends Equatable {
  /// The name of the ble device.
  final String name;

  /// The identifier for the ble device.
  ///
  /// On Android it's a MAC address such as '00:11:22:33:AA:BB' and on ios
  /// it's an 128 bit UUID such as '68753A44-4D6F-1226-9C60-0050E4C00067'.
  final String id;

  const BleDeviceInformation({required this.name, required this.id});

  @override
  List<Object?> get props => [name, id];
}
