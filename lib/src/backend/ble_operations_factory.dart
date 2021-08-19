import 'package:flutter_blue/flutter_blue.dart';
import 'package:weight_scale/src/backend/flutter_blue_convert.dart';
import 'package:weight_scale/src/backend/flutter_blue_operations.dart';
import 'package:weight_scale/src/ble_operations.dart';

/// Factory to create the [BleOperations].
///
/// Use the [primary] factory, unless you need a specific backend.
class BleOperationsFactory {
  static BleOperations primary() => flutterBlue();

  static BleOperations flutterBlue() =>
      FlutterBlueOperations(FlutterBlue.instance, FlutterBlueConvert());
}
