// Mocks generated by Mockito 5.4.2 from annotations
// in weight_scale/test/src/ble/backend/fb_ble_manager_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [FlutterBluePlus].
///
/// See the documentation for Mockito's code generation for more information.
class MockFlutterBluePlus extends _i1.Mock implements _i2.FlutterBluePlus {
  MockFlutterBluePlus() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.LogLevel get logLevel => (super.noSuchMethod(
        Invocation.getter(#logLevel),
        returnValue: _i2.LogLevel.emergency,
      ) as _i2.LogLevel);
  @override
  _i3.Future<bool> get isAvailable => (super.noSuchMethod(
        Invocation.getter(#isAvailable),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<String> get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: _i3.Future<String>.value(''),
      ) as _i3.Future<String>);
  @override
  _i3.Future<bool> get isOn => (super.noSuchMethod(
        Invocation.getter(#isOn),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Stream<bool> get isScanning => (super.noSuchMethod(
        Invocation.getter(#isScanning),
        returnValue: _i3.Stream<bool>.empty(),
      ) as _i3.Stream<bool>);
  @override
  bool get isScanningNow => (super.noSuchMethod(
        Invocation.getter(#isScanningNow),
        returnValue: false,
      ) as bool);
  @override
  _i3.Stream<List<_i2.ScanResult>> get scanResults => (super.noSuchMethod(
        Invocation.getter(#scanResults),
        returnValue: _i3.Stream<List<_i2.ScanResult>>.empty(),
      ) as _i3.Stream<List<_i2.ScanResult>>);
  @override
  _i3.Stream<_i2.BluetoothState> get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i3.Stream<_i2.BluetoothState>.empty(),
      ) as _i3.Stream<_i2.BluetoothState>);
  @override
  _i3.Future<List<_i2.BluetoothDevice>> get connectedDevices =>
      (super.noSuchMethod(
        Invocation.getter(#connectedDevices),
        returnValue: _i3.Future<List<_i2.BluetoothDevice>>.value(
            <_i2.BluetoothDevice>[]),
      ) as _i3.Future<List<_i2.BluetoothDevice>>);
  @override
  _i3.Future<List<_i2.BluetoothDevice>> get bondedDevices =>
      (super.noSuchMethod(
        Invocation.getter(#bondedDevices),
        returnValue: _i3.Future<List<_i2.BluetoothDevice>>.value(
            <_i2.BluetoothDevice>[]),
      ) as _i3.Future<List<_i2.BluetoothDevice>>);
  @override
  _i3.Future<bool> turnOn() => (super.noSuchMethod(
        Invocation.method(
          #turnOn,
          [],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<bool> turnOff() => (super.noSuchMethod(
        Invocation.method(
          #turnOff,
          [],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Stream<_i2.ScanResult> scan({
    _i2.ScanMode? scanMode = _i2.ScanMode.lowLatency,
    List<_i2.Guid>? withServices = const [],
    List<_i2.Guid>? withDevices = const [],
    List<String>? macAddresses = const [],
    Duration? timeout,
    bool? allowDuplicates = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #scan,
          [],
          {
            #scanMode: scanMode,
            #withServices: withServices,
            #withDevices: withDevices,
            #macAddresses: macAddresses,
            #timeout: timeout,
            #allowDuplicates: allowDuplicates,
          },
        ),
        returnValue: _i3.Stream<_i2.ScanResult>.empty(),
      ) as _i3.Stream<_i2.ScanResult>);
  @override
  _i3.Future<dynamic> startScan({
    _i2.ScanMode? scanMode = _i2.ScanMode.lowLatency,
    List<_i2.Guid>? withServices = const [],
    List<_i2.Guid>? withDevices = const [],
    List<String>? macAddresses = const [],
    Duration? timeout,
    bool? allowDuplicates = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #startScan,
          [],
          {
            #scanMode: scanMode,
            #withServices: withServices,
            #withDevices: withDevices,
            #macAddresses: macAddresses,
            #timeout: timeout,
            #allowDuplicates: allowDuplicates,
          },
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> stopScan() => (super.noSuchMethod(
        Invocation.method(
          #stopScan,
          [],
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);
  @override
  void setLogLevel(_i2.LogLevel? level) => super.noSuchMethod(
        Invocation.method(
          #setLogLevel,
          [level],
        ),
        returnValueForMissingStub: null,
      );
}
