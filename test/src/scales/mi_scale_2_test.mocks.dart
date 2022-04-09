// Mocks generated by Mockito 5.1.0 from annotations
// in weight_scale/test/src/scales/mi_scale_2_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:weight_scale/src/ble/ble.dart' as _i3;
import 'package:weight_scale/src/ble/model/ble_device_information.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeBleDeviceInformation_0 extends _i1.Fake
    implements _i2.BleDeviceInformation {}

/// A class which mocks [BleDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBleDevice extends _i1.Mock implements _i3.BleDevice {
  MockBleDevice() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.BleDeviceInformation get information => (super.noSuchMethod(
      Invocation.getter(#information),
      returnValue: _FakeBleDeviceInformation_0()) as _i2.BleDeviceInformation);
  @override
  _i4.Future<List<_i3.Service>> get services =>
      (super.noSuchMethod(Invocation.getter(#services),
              returnValue: Future<List<_i3.Service>>.value(<_i3.Service>[]))
          as _i4.Future<List<_i3.Service>>);
  @override
  _i4.Stream<_i3.BleDeviceState> get state =>
      (super.noSuchMethod(Invocation.getter(#state),
              returnValue: Stream<_i3.BleDeviceState>.empty())
          as _i4.Stream<_i3.BleDeviceState>);
  @override
  _i3.BleDeviceState get currentState =>
      (super.noSuchMethod(Invocation.getter(#currentState),
          returnValue: _i3.BleDeviceState.connected) as _i3.BleDeviceState);
  @override
  _i4.Future<void> connect({Duration? timeout = const Duration(seconds: 20)}) =>
      (super.noSuchMethod(Invocation.method(#connect, [], {#timeout: timeout}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<void> disconnect() =>
      (super.noSuchMethod(Invocation.method(#disconnect, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<List<_i3.Service>> discoverServices() =>
      (super.noSuchMethod(Invocation.method(#discoverServices, []),
              returnValue: Future<List<_i3.Service>>.value(<_i3.Service>[]))
          as _i4.Future<List<_i3.Service>>);
  @override
  _i4.Future<_i5.Uint8List> readCharacteristic(
          _i3.Characteristic? characteristic) =>
      (super.noSuchMethod(
              Invocation.method(#readCharacteristic, [characteristic]),
              returnValue: Future<_i5.Uint8List>.value(_i5.Uint8List(0)))
          as _i4.Future<_i5.Uint8List>);
  @override
  _i4.Future<void> writeCharacteristic(_i3.Characteristic? characteristic,
          {_i5.Uint8List? value, bool? response = true}) =>
      (super.noSuchMethod(
          Invocation.method(#writeCharacteristic, [characteristic],
              {#value: value, #response: response}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<_i4.Stream<_i5.Uint8List>> subscribeCharacteristic(
          _i3.Characteristic? characteristic) =>
      (super.noSuchMethod(
              Invocation.method(#subscribeCharacteristic, [characteristic]),
              returnValue: Future<_i4.Stream<_i5.Uint8List>>.value(
                  Stream<_i5.Uint8List>.empty()))
          as _i4.Future<_i4.Stream<_i5.Uint8List>>);
}
