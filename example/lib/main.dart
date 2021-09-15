import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({Key? key}) : super(key: key) {
    hub = WeightScaleHub.defaultBackend();
    hub.initialize();
  }

  late final WeightScaleHub hub;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeightScale Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(hub: hub),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.hub}) : super(key: key);

  final WeightScaleHub hub;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _searching = false;

  void setSearching(bool searching) {
    setState(() => _searching = searching);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WeightScale Example App"),
      ),
      body: Center(
        child: WeightScaleList(hub: widget.hub),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_searching) {
            await widget.hub.stopSearch();
            setSearching(false);
          } else {
            setSearching(true);
            await widget.hub.search();
            setSearching(false);
          }
        },
        tooltip: 'Search',
        child: _searching ? Icon(Icons.stop) : Icon(Icons.search),
      ),
    );
  }
}

class WeightScaleList extends StatelessWidget {
  const WeightScaleList({Key? key, required this.hub}) : super(key: key);

  final WeightScaleHub hub;

  void open(BuildContext context, WeightScale scale) {
    hub.stopSearch();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MeasurementPage(scale: scale);
    }));
  }

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
                    .map((scale) => ListTile(
                          title: Text(scale.name),
                          onTap: () => open(context, scale),
                        ))
                    .toList(),
              );
            }),
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
  bool _disable = false;
  bool _connected = false;

  void onActionButtonPressed() {
    if (_connected) {
      setState(() => _disable = true);
      widget.scale.disconnect().then((_) {
        setState(() {
          _connected = false;
          _disable = false;
        });
      });
    } else {
      setState(() => _disable = true);
      widget.scale.connect().then((_) {
        setState(() {
          _connected = true;
          _disable = false;
        });
      });
    }
  }

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
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<double>(
                initialData: null,
                stream: widget.scale.weight,
                builder: (context, snapshot) {
                  String weight = "-";
                  String unit = describeEnum(widget.scale.unit);
                  if (!_disable && _connected && snapshot.data != null) {
                    weight = snapshot.data.toString();
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(weight, style: TextStyle(fontSize: 96)),
                        Text(unit, style: TextStyle(fontSize: 36)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _disable ? null : onActionButtonPressed,
                child: Text(_connected ? "DISCONNECT" : "CONNECT"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
