import 'package:flutter/material.dart';
import 'package:weight_scale/weight_scale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final manager = WeightScaleManager.instance();
  await manager.initialize();

  runApp(ExampleApp(manager: manager));
}

class ExampleApp extends StatelessWidget {
  final WeightScaleManager manager;
  const ExampleApp({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Scale Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(manager: manager),
    );
  }
}

class HomePage extends StatefulWidget {
  final WeightScaleManager manager;
  const HomePage({super.key, required this.manager});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isScanning = true;

  @override
  void initState() {
    super.initState();
    widget.manager.startScan();
  }

  void toggleScan() {
    if (isScanning) {
      setState(() => isScanning = false);
      widget.manager.stopScan();
    } else {
      setState(() => isScanning = true);
      showSnackBarOnException(widget.manager.startScan, context)
          .then((_) => setState(() => isScanning == false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weight Scale Demo")),
      body: StreamBuilder<List<WeightScale>>(
        initialData: const [],
        stream: widget.manager.scales,
        builder: (context, snapshot) {
          final scales = snapshot.requireData;
          return ListView.builder(
            itemCount: scales.length,
            itemBuilder: (context, index) {
              final scale = scales[index];
              return ListTile(
                title: Text(scale.name, overflow: TextOverflow.ellipsis),
                subtitle: Text(scale.manufacturer),
                trailing: TextButton(
                  child: const Text("CONNECT"),
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (_) => ScalePage(scale: scale),
                    );
                    Navigator.push(context, route);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: toggleScan,
        label: Text(isScanning ? "Stop Scan" : "Start Scan"),
        icon: Icon(isScanning ? Icons.square : Icons.search),
      ),
    );
  }
}

class ScalePage extends StatefulWidget {
  final WeightScale scale;
  const ScalePage({super.key, required this.scale});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  var isLoading = true;
  var isTakingWeight = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    setState(() => isLoading = true);
    await showSnackBarOnException(widget.scale.connect, context);
    setState(() => isLoading = false);
  }

  Future<void> disconnect() async {
    setState(() => isLoading = true);
    await showSnackBarOnException(widget.scale.disconnect, context);
    setState(() => isLoading = false);
  }

  Future<void> takeWeight() async {
    setState(() => isTakingWeight = true);
    final weight = await showSnackBarOnException(
        widget.scale.takeWeightMeasurement, context);
    if (weight != null) showWeightDialog(weight);
    setState(() => isTakingWeight = false);
  }

  Future<void> showWeightDialog(Weight weight) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Measured Weight'),
          content: SizedBox(
            height: 160,
            child: WeightDisplay(weight: weight),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return WillPopScope(
      onWillPop: () async {
        showSnackBarOnException(scale.disconnect, context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(scale.name, overflow: TextOverflow.ellipsis),
        ),
        body: isLoading
            ? const LoadingScreen()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: StreamBuilder(
                  initialData: false,
                  stream: scale.state,
                  builder: (context, snapshot) {
                    if (snapshot.requireData == BleDeviceState.connected) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: StreamBuilder(
                              initialData: scale.currentWeight,
                              stream: scale.weight,
                              builder: (context, snapshot) {
                                if (isTakingWeight) {
                                  return const LoadingScreen();
                                } else {
                                  final weight = snapshot.requireData;
                                  return WeightDisplay(weight: weight);
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isTakingWeight ? null : takeWeight,
                            child: const Text("Take weight"),
                          ),
                          TextButton(
                            onPressed: disconnect,
                            child: const Text("DISCONNECT"),
                          )
                        ],
                      );
                    } else {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                          onPressed: connect,
                          child: const Text("CONNECT"),
                        ),
                      );
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class WeightDisplay extends StatelessWidget {
  const WeightDisplay({
    super.key,
    required this.weight,
  });

  final Weight weight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weight.value.toStringAsPrecision(2),
            style: textTheme.displayLarge,
          ),
          Text(
            weight.unit == WeightUnit.kg ? "kg" : "lbs",
            style: textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Shows a [SnackBar] with the [WeightScaleException.message] if the [method]
/// throws a [WeightScaleException]. Returns the result of the [method] if it
/// succeeds, otherwise returns `null`.
Future<T?> showSnackBarOnException<T>(
  Future<T> Function() method,
  BuildContext context,
) async {
  try {
    return await method();
  } on WeightScaleException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.message),
      duration: const Duration(milliseconds: 750),
    ));
    return null;
  }
}
