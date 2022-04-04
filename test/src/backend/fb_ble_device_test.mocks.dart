// Mocks generated by Mockito 5.1.0 from annotations
// in weight_scale/test/src/backend/fb_ble_device_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:flutter_blue/flutter_blue.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:weight_scale/ble.dart' as _i3;
import 'package:weight_scale/src/backend/fb_conversion.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeDeviceIdentifier_0 extends _i1.Fake implements _i2.DeviceIdentifier {
}

class _FakeGuid_1 extends _i1.Fake implements _i2.Guid {}

class _FakeCharacteristicProperties_2 extends _i1.Fake
    implements _i2.CharacteristicProperties {}

class _FakeBleDevice_3 extends _i1.Fake implements _i3.BleDevice {}

class _FakeBluetoothDevice_4 extends _i1.Fake implements _i2.BluetoothDevice {}

class _FakeScanResult_5 extends _i1.Fake implements _i3.ScanResult {}

class _FakeScanResult_6 extends _i1.Fake implements _i2.ScanResult {}

class _FakeService_7 extends _i1.Fake implements _i3.Service {}

class _FakeBluetoothService_8 extends _i1.Fake implements _i2.BluetoothService {
}

class _FakeCharacteristic_9 extends _i1.Fake implements _i3.Characteristic {}

class _FakeBluetoothCharacteristic_10 extends _i1.Fake
    implements _i2.BluetoothCharacteristic {}

class _FakeDescriptor_11 extends _i1.Fake implements _i3.Descriptor {}

class _FakeBluetoothDescriptor_12 extends _i1.Fake
    implements _i2.BluetoothDescriptor {}

class _FakeUuid_13 extends _i1.Fake implements _i3.Uuid {}

/// A class which mocks [BluetoothDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothDevice extends _i1.Mock implements _i2.BluetoothDevice {
  MockBluetoothDevice() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeviceIdentifier get id => (super.noSuchMethod(Invocation.getter(#id),
      returnValue: _FakeDeviceIdentifier_0()) as _i2.DeviceIdentifier);
  @override
  String get name =>
      (super.noSuchMethod(Invocation.getter(#name), returnValue: '') as String);
  @override
  _i2.BluetoothDeviceType get type => (super.noSuchMethod(
      Invocation.getter(#type),
      returnValue: _i2.BluetoothDeviceType.unknown) as _i2.BluetoothDeviceType);
  @override
  _i4.Stream<bool> get isDiscoveringServices =>
      (super.noSuchMethod(Invocation.getter(#isDiscoveringServices),
          returnValue: Stream<bool>.empty()) as _i4.Stream<bool>);
  @override
  _i4.Stream<List<_i2.BluetoothService>> get services =>
      (super.noSuchMethod(Invocation.getter(#services),
              returnValue: Stream<List<_i2.BluetoothService>>.empty())
          as _i4.Stream<List<_i2.BluetoothService>>);
  @override
  _i4.Stream<_i2.BluetoothDeviceState> get state =>
      (super.noSuchMethod(Invocation.getter(#state),
              returnValue: Stream<_i2.BluetoothDeviceState>.empty())
          as _i4.Stream<_i2.BluetoothDeviceState>);
  @override
  _i4.Stream<int> get mtu => (super.noSuchMethod(Invocation.getter(#mtu),
      returnValue: Stream<int>.empty()) as _i4.Stream<int>);
  @override
  _i4.Future<bool> get canSendWriteWithoutResponse =>
      (super.noSuchMethod(Invocation.getter(#canSendWriteWithoutResponse),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<void> connect({Duration? timeout, bool? autoConnect = true}) =>
      (super.noSuchMethod(
          Invocation.method(
              #connect, [], {#timeout: timeout, #autoConnect: autoConnect}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<dynamic> disconnect() =>
      (super.noSuchMethod(Invocation.method(#disconnect, []),
          returnValue: Future<dynamic>.value()) as _i4.Future<dynamic>);
  @override
  _i4.Future<List<_i2.BluetoothService>> discoverServices() =>
      (super.noSuchMethod(Invocation.method(#discoverServices, []),
              returnValue: Future<List<_i2.BluetoothService>>.value(
                  <_i2.BluetoothService>[]))
          as _i4.Future<List<_i2.BluetoothService>>);
  @override
  _i4.Future<void> requestMtu(int? desiredMtu) =>
      (super.noSuchMethod(Invocation.method(#requestMtu, [desiredMtu]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
}

/// A class which mocks [BluetoothCharacteristic].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothCharacteristic extends _i1.Mock
    implements _i2.BluetoothCharacteristic {
  MockBluetoothCharacteristic() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Guid get uuid =>
      (super.noSuchMethod(Invocation.getter(#uuid), returnValue: _FakeGuid_1())
          as _i2.Guid);
  @override
  _i2.DeviceIdentifier get deviceId =>
      (super.noSuchMethod(Invocation.getter(#deviceId),
          returnValue: _FakeDeviceIdentifier_0()) as _i2.DeviceIdentifier);
  @override
  _i2.Guid get serviceUuid =>
      (super.noSuchMethod(Invocation.getter(#serviceUuid),
          returnValue: _FakeGuid_1()) as _i2.Guid);
  @override
  _i2.CharacteristicProperties get properties =>
      (super.noSuchMethod(Invocation.getter(#properties),
              returnValue: _FakeCharacteristicProperties_2())
          as _i2.CharacteristicProperties);
  @override
  List<_i2.BluetoothDescriptor> get descriptors =>
      (super.noSuchMethod(Invocation.getter(#descriptors),
              returnValue: <_i2.BluetoothDescriptor>[])
          as List<_i2.BluetoothDescriptor>);
  @override
  bool get isNotifying =>
      (super.noSuchMethod(Invocation.getter(#isNotifying), returnValue: false)
          as bool);
  @override
  _i4.Stream<List<int>> get value =>
      (super.noSuchMethod(Invocation.getter(#value),
          returnValue: Stream<List<int>>.empty()) as _i4.Stream<List<int>>);
  @override
  List<int> get lastValue =>
      (super.noSuchMethod(Invocation.getter(#lastValue), returnValue: <int>[])
          as List<int>);
  @override
  _i4.Future<List<int>> read() => (super.noSuchMethod(
      Invocation.method(#read, []),
      returnValue: Future<List<int>>.value(<int>[])) as _i4.Future<List<int>>);
  @override
  _i4.Future<Null?> write(List<int>? value, {bool? withoutResponse = false}) =>
      (super.noSuchMethod(
          Invocation.method(
              #write, [value], {#withoutResponse: withoutResponse}),
          returnValue: Future<Null?>.value()) as _i4.Future<Null?>);
  @override
  _i4.Future<bool> setNotifyValue(bool? notify) =>
      (super.noSuchMethod(Invocation.method(#setNotifyValue, [notify]),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
}

/// A class which mocks [FbConversion].
///
/// See the documentation for Mockito's code generation for more information.
class MockFbConversion extends _i1.Mock implements _i5.FbConversion {
  MockFbConversion() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.BluetoothDeviceState fromBleDeviceState(_i3.BleDeviceState? state) =>
      (super.noSuchMethod(Invocation.method(#fromBleDeviceState, [state]),
              returnValue: _i2.BluetoothDeviceState.disconnected)
          as _i2.BluetoothDeviceState);
  @override
  _i3.BleDevice toBleDevice(_i2.BluetoothDevice? device) =>
      (super.noSuchMethod(Invocation.method(#toBleDevice, [device]),
          returnValue: _FakeBleDevice_3()) as _i3.BleDevice);
  @override
  _i2.BluetoothDevice fromBleDevice(_i3.BleDevice? device) =>
      (super.noSuchMethod(Invocation.method(#fromBleDevice, [device]),
          returnValue: _FakeBluetoothDevice_4()) as _i2.BluetoothDevice);
  @override
  _i3.BleDeviceState toBleDeviceState(_i2.BluetoothDeviceState? state) =>
      (super.noSuchMethod(Invocation.method(#toBleDeviceState, [state]),
          returnValue: _i3.BleDeviceState.connected) as _i3.BleDeviceState);
  @override
  _i3.ScanResult toScanResult(_i2.ScanResult? scanResult) =>
      (super.noSuchMethod(Invocation.method(#toScanResult, [scanResult]),
          returnValue: _FakeScanResult_5()) as _i3.ScanResult);
  @override
  _i2.ScanResult fromScanResult(_i3.ScanResult? scanResult) =>
      (super.noSuchMethod(Invocation.method(#fromScanResult, [scanResult]),
          returnValue: _FakeScanResult_6()) as _i2.ScanResult);
  @override
  _i3.Service toService(_i2.BluetoothService? service) =>
      (super.noSuchMethod(Invocation.method(#toService, [service]),
          returnValue: _FakeService_7()) as _i3.Service);
  @override
  _i2.BluetoothService fromService(_i3.Service? service) =>
      (super.noSuchMethod(Invocation.method(#fromService, [service]),
          returnValue: _FakeBluetoothService_8()) as _i2.BluetoothService);
  @override
  _i3.Characteristic toCharacteristic(
          _i2.BluetoothCharacteristic? characteristic) =>
      (super.noSuchMethod(
          Invocation.method(#toCharacteristic, [characteristic]),
          returnValue: _FakeCharacteristic_9()) as _i3.Characteristic);
  @override
  _i2.BluetoothCharacteristic fromCharacteristic(
          _i3.Characteristic? characteristic) =>
      (super.noSuchMethod(
              Invocation.method(#fromCharacteristic, [characteristic]),
              returnValue: _FakeBluetoothCharacteristic_10())
          as _i2.BluetoothCharacteristic);
  @override
  _i3.Descriptor toDescriptor(_i2.BluetoothDescriptor? descriptor) =>
      (super.noSuchMethod(Invocation.method(#toDescriptor, [descriptor]),
          returnValue: _FakeDescriptor_11()) as _i3.Descriptor);
  @override
  _i2.BluetoothDescriptor fromDescriptor(_i3.Descriptor? descriptor) =>
      (super.noSuchMethod(Invocation.method(#fromDescriptor, [descriptor]),
              returnValue: _FakeBluetoothDescriptor_12())
          as _i2.BluetoothDescriptor);
  @override
  _i3.Uuid toUuid(_i2.Guid? guid) =>
      (super.noSuchMethod(Invocation.method(#toUuid, [guid]),
          returnValue: _FakeUuid_13()) as _i3.Uuid);
  @override
  _i2.Guid fromUuid(_i3.Uuid? uuid) =>
      (super.noSuchMethod(Invocation.method(#fromUuid, [uuid]),
          returnValue: _FakeGuid_1()) as _i2.Guid);
}