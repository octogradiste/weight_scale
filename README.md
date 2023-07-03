# Weight Scale

A flutter package to connect to bluetooth low energy weight scales.

## Setup

This package currently uses [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) as its backend. 
Please follow the [setup](https://pub.dev/packages/flutter_blue_plus#getting-started) for that plugin.

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

## Weight scale support

| Name | Battery Level | Set Unit | Calibrate | Clear Cache |
|---|---|---|---|---|
| Xiaomi Mi Sacle 2 | :x: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Eufy Smart Scale P1 | :x: | :x: | :x: | :x: |

### Adding your own weight scale
To add your own weight scale, you have to implement a `WeightScaleRecognizer`
and the `WeightScale` itself. The job of the recognizer is to recognize your
custom weight scale given a `ScanResult`. Don't forget to register your
recognizer at the `WeightScaleManager` before stating a scan. Otherwise, your 
weight sacle won't be recongized !

To simplifiy the implementation of the `WeightSacle` you can extend the
`AbstractWeightSacle` which already implements most of the inteface.

## Credits
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)
- [wiecosystem](https://github.com/wiecosystem/Bluetooth/blob/master/doc/devices/huami.health.scale2.md) for reverse engineering the mi scale.