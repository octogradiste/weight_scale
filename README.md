# weight scale

Flutter package to connect to BLE weight scales.

## Setup

This package currently uses [flutter_blue](https://pub.dev/packages/flutter_blue) as its backend. 
Please follow the [setup](https://pub.dev/packages/flutter_blue#setup) for that plugin.

## Usage

### Searching weight scales

Create a new `WeightScaleHub`.
```Dart
WeightScaleHub hub = WeightScaleHub.defaultBackend();
```

Initialize it.
```Dart
await hub.initialize();
```

Start searching for new weight scales.
```Dart
hub.search();
```

All the scales found during the search are emitted by `hub.scales`.

### Getting the weight measurements of a scale
Use `WeightScale.connect()` to establish a connection.

After connecting to a scale, the weight measurement is available via the stream `WeightScale.weight`.

## Credits
- [flutter_blue](https://pub.dev/packages/flutter_blue)
- [wiecosystem](https://github.com/wiecosystem/Bluetooth/blob/master/doc/devices/huami.health.scale2.md) for reverse engineering the mi scale.
