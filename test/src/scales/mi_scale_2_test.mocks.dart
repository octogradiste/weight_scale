// Mocks generated by Mockito 5.4.2 from annotations
// in weight_scale/test/src/scales/mi_scale_2_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:typed_data' as _i4;

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

class _FakeBleDeviceInformation_0 extends _i1.SmartFake
    implements _i2.BleDeviceInformation {
  _FakeBleDeviceInformation_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [BleDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBleDevice extends _i1.Mock implements _i2.BleDevice {
  MockBleDevice() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.BleDeviceInformation get information => (super.noSuchMethod(
        Invocation.getter(#information),
        returnValue: _FakeBleDeviceInformation_0(
          this,
          Invocation.getter(#information),
        ),
      ) as _i2.BleDeviceInformation);
  @override
  _i3.Future<List<_i2.Service>> get services => (super.noSuchMethod(
        Invocation.getter(#services),
        returnValue: _i3.Future<List<_i2.Service>>.value(<_i2.Service>[]),
      ) as _i3.Future<List<_i2.Service>>);
  @override
  _i3.Stream<_i2.BleDeviceState> get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i3.Stream<_i2.BleDeviceState>.empty(),
      ) as _i3.Stream<_i2.BleDeviceState>);
  @override
  _i3.Future<_i2.BleDeviceState> get currentState => (super.noSuchMethod(
        Invocation.getter(#currentState),
        returnValue:
            _i3.Future<_i2.BleDeviceState>.value(_i2.BleDeviceState.connected),
      ) as _i3.Future<_i2.BleDeviceState>);
  @override
  _i3.Future<void> connect({Duration? timeout = const Duration(seconds: 20)}) =>
      (super.noSuchMethod(
        Invocation.method(
          #connect,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> disconnect() => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<List<_i2.Service>> discoverServices() => (super.noSuchMethod(
        Invocation.method(
          #discoverServices,
          [],
        ),
        returnValue: _i3.Future<List<_i2.Service>>.value(<_i2.Service>[]),
      ) as _i3.Future<List<_i2.Service>>);
  @override
  _i3.Future<_i4.Uint8List> readCharacteristic(
          _i2.Characteristic? characteristic) =>
      (super.noSuchMethod(
        Invocation.method(
          #readCharacteristic,
          [characteristic],
        ),
        returnValue: _i3.Future<_i4.Uint8List>.value(_i4.Uint8List(0)),
      ) as _i3.Future<_i4.Uint8List>);
  @override
  _i3.Future<void> writeCharacteristic(
    _i2.Characteristic? characteristic, {
    required _i4.Uint8List? value,
    bool? response = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #writeCharacteristic,
          [characteristic],
          {
            #value: value,
            #response: response,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<_i3.Stream<_i4.Uint8List>> subscribeCharacteristic(
          _i2.Characteristic? characteristic) =>
      (super.noSuchMethod(
        Invocation.method(
          #subscribeCharacteristic,
          [characteristic],
        ),
        returnValue: _i3.Future<_i3.Stream<_i4.Uint8List>>.value(
            _i3.Stream<_i4.Uint8List>.empty()),
      ) as _i3.Future<_i3.Stream<_i4.Uint8List>>);
}
