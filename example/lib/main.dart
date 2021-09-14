import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weight_scale/ble.dart';
import 'package:weight_scale/scale.dart';

late final WeightScaleHub hub;

void main() {
  runApp(ExampleApp());
  hub = WeightScaleHub(bleService: BleService.instance);
  hub.initialize(operations: BleOperationsFactory.primary());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeightScale Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class WeightScaleList extends StatelessWidget {
  const WeightScaleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: StreamBuilder<List<WeightScale>>(
            initialData: [],
            stream: hub.scales,
            builder: (context, snapshot) {
              List<WeightScale> scales = snapshot.data ?? [];
              return Column(
                children: scales
                    .map((scale) => WeightScaleListItem(scale: scale))
                    .toList(),
              );
            }),
      ),
    );
  }
}

class WeightScaleListItem extends StatelessWidget {
  const WeightScaleListItem({Key? key, required this.scale}) : super(key: key);

  final WeightScale scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(scale.name),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                hub.stopSearch().then((_) => scale.connect());
                return MeasurementPage(scale: scale);
              }));
            },
            child: Text("CONNECT"),
          )
        ],
      ),
    );
  }
}

class MeasurementPage extends StatefulWidget {
  const MeasurementPage({Key? key, required this.scale}) : super(key: key);

  final WeightScale scale;

  @override
  _MeasurementPageState createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await widget.scale.disconnect();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.scale.name),
        ),
        body: Center(
          child: StreamBuilder<double>(
            initialData: null,
            stream: widget.scale.weight,
            builder: (context, snapshot) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.data?.toString() ?? "-",
                      style: TextStyle(fontSize: 96),
                    ),
                    Text(
                      describeEnum(widget.scale.unit),
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _searching = false;

  void setSearching(bool searching) {
    setState(() {
      _searching = searching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WeightScale Example App"),
      ),
      body: Center(
        child: WeightScaleList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_searching) {
            await hub.stopSearch();
            setSearching(false);
          } else {
            setSearching(true);
            await hub.search();
            setSearching(false);
          }
        },
        tooltip: 'Search',
        child: _searching ? Icon(Icons.stop) : Icon(Icons.search),
      ),
    );
  }
}
