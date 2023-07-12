// Mocks generated by Mockito 5.4.2 from annotations
// in weight_scale/test/src/weight_scale_manager_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:weight_scale/src/ble/ble.dart' as _i2;

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

/// A class which mocks [BleManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockBleManager extends _i1.Mock implements _i2.BleManager {
  @override
  _i3.Future<Set<_i2.BleDevice>> get connectedDevices => (super.noSuchMethod(
        Invocation.getter(#connectedDevices),
        returnValue: _i3.Future<Set<_i2.BleDevice>>.value(<_i2.BleDevice>{}),
        returnValueForMissingStub:
            _i3.Future<Set<_i2.BleDevice>>.value(<_i2.BleDevice>{}),
      ) as _i3.Future<Set<_i2.BleDevice>>);
  @override
  _i3.Stream<List<_i2.ScanResult>> get scanResults => (super.noSuchMethod(
        Invocation.getter(#scanResults),
        returnValue: _i3.Stream<List<_i2.ScanResult>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<_i2.ScanResult>>.empty(),
      ) as _i3.Stream<List<_i2.ScanResult>>);
  @override
  bool get isInitialized => (super.noSuchMethod(
        Invocation.getter(#isInitialized),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  bool get isScanning => (super.noSuchMethod(
        Invocation.getter(#isScanning),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  _i3.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> startScan({
    List<_i2.Uuid>? withServices,
    Duration? timeout = const Duration(seconds: 20),
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #startScan,
          [],
          {
            #withServices: withServices,
            #timeout: timeout,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> stopScan() => (super.noSuchMethod(
        Invocation.method(
          #stopScan,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
