// Mocks generated by Mockito 5.0.10 from annotations
// in weight_scale/test/src/weight_scale_hub_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:weight_scale/src/ble_operations.dart' as _i5;
import 'package:weight_scale/src/ble_service.dart' as _i2;
import 'package:weight_scale/src/model/scan_result.dart' as _i4;
import 'package:weight_scale/src/model/uuid.dart' as _i6;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

/// A class which mocks [BleService].
///
/// See the documentation for Mockito's code generation for more information.
class MockBleService extends _i1.Mock implements _i2.BleService {
  MockBleService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<_i2.BleServiceState> get state =>
      (super.noSuchMethod(Invocation.getter(#state),
              returnValue: Stream<_i2.BleServiceState>.empty())
          as _i3.Stream<_i2.BleServiceState>);
  @override
  set state(_i3.Stream<_i2.BleServiceState>? _state) =>
      super.noSuchMethod(Invocation.setter(#state, _state),
          returnValueForMissingStub: null);
  @override
  _i3.Stream<List<_i4.ScanResult>> get scanResults =>
      (super.noSuchMethod(Invocation.getter(#scanResults),
              returnValue: Stream<List<_i4.ScanResult>>.empty())
          as _i3.Stream<List<_i4.ScanResult>>);
  @override
  set scanResults(_i3.Stream<List<_i4.ScanResult>>? _scanResults) =>
      super.noSuchMethod(Invocation.setter(#scanResults, _scanResults),
          returnValueForMissingStub: null);
  @override
  bool get isScanning =>
      (super.noSuchMethod(Invocation.getter(#isScanning), returnValue: false)
          as bool);
  @override
  bool get isInitialized =>
      (super.noSuchMethod(Invocation.getter(#isInitialized), returnValue: false)
          as bool);
  @override
  bool get isAndroid =>
      (super.noSuchMethod(Invocation.getter(#isAndroid), returnValue: false)
          as bool);
  @override
  _i3.Future<void> initialize(
          {_i5.BleOperations? operations, bool? isAndroid}) =>
      (super.noSuchMethod(
          Invocation.method(#initialize, [],
              {#operations: operations, #isAndroid: isAndroid}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> startScan(
          {Duration? timeout, List<_i6.Uuid>? withServices}) =>
      (super.noSuchMethod(
          Invocation.method(
              #startScan, [], {#timeout: timeout, #withServices: withServices}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> stopScan() =>
      (super.noSuchMethod(Invocation.method(#stopScan, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
}
