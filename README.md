# Weight Scale

A flutter package to connect to bluetooth low energy weight scales.

## Setup

This package currently uses [flutter_blue](https://pub.dev/packages/flutter_blue) as its backend. 
Please follow the [setup](https://pub.dev/packages/flutter_blue#setup) for that plugin.

## Weight scale support

| Name                | Battery Level | Set Unit | Calibrate | Clear Cache |
|---------------------|---------------|----------|-----------|-------------|
| Xiaomi Mi Sacle 2   | [ ]           | [x]      | [x]       | [x]         |
| Eufy Smart Scale P1 | [ ]           | [ ]      | [ ]       | [ ]         |


## Usage
### Scanning weight scales

Create a new `WeightScaleManager`.
```Dart
WeightScaleManager manager = WeightScaleManager.defaultBackend();
```

Initialize it.
```Dart
await manager.initialize();
```

Start scanning for weight scales.
```Dart
manager.startScan();
```

All the `WeightScale` found during the scan are emitted by the `manager.scales` stream.

### Getting the weight measurements of a scale
Use `WeightScale.connect()` to establish a connection.

After connecting to a scale, the weight measurement is available via the stream `WeightScale.weight`.

## Credits
- [flutter_blue](https://pub.dev/packages/flutter_blue)
- [wiecosystem](https://github.com/wiecosystem/Bluetooth/blob/master/doc/devices/huami.health.scale2.md) for reverse engineering the mi scale.
