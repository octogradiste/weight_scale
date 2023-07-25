import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:weight_scale/src/ble/model.dart';

import 'flutter_blue_plus_converter.dart';

class FlutterBluePlusWrapper {
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await blue.FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await blue.FlutterBluePlus.stopScan();
  }

  Stream<List<ScanResult>> get scanResults {
    return blue.FlutterBluePlus.scanResults.map(
      (results) => results.map(FlutterBluePlusConverter.toScanResult).toList(),
    );
  }
}
