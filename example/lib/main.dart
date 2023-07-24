import 'package:flutter/material.dart';
import 'package:weight_scale/weight_scale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final manager = WeightScaleManager.defaultBackend();
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
          .then((success) => setState(() => isScanning == success));
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
                    showSnackBarOnException(scale.connect, context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScalePage(scale: scale),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleScan,
        child: Icon(isScanning ? Icons.square : Icons.search),
      ),
    );
  }
}

class ScalePage extends StatelessWidget {
  final WeightScale scale;
  const ScalePage({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showSnackBarOnException(scale.disconnect, context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(scale.name, overflow: TextOverflow.ellipsis),
        ),
        body: StreamBuilder(
          initialData: scale.currentState,
          stream: scale.connected,
          builder: (context, snapshot) {
            switch (snapshot.requireData) {
              case true:
                return Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        initialData: scale.currentWeight,
                        stream: scale.weight,
                        builder: (context, snapshot) {
                          final weight = snapshot.requireData;
                          return WeightDisplay(weight: weight);
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => TakeWeightDialog(scale: scale),
                      ),
                      child: const Text("Take Weight"),
                    ),
                    TextButton(
                      onPressed: () =>
                          showSnackBarOnException(scale.disconnect, context),
                      child: const Text("DISCONNECT"),
                    )
                  ],
                );
              case false:
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () =>
                        showSnackBarOnException(scale.connect, context),
                    child: const Text("CONNECT"),
                  ),
                );
              default:
                return const LoadingScreen();
            }
          },
        ),
      ),
    );
  }
}

class TakeWeightDialog extends StatelessWidget {
  const TakeWeightDialog({
    super.key,
    required this.scale,
  });

  final WeightScale scale;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: FutureBuilder(
              future: scale.takeWeightMeasurement(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return WeightDisplay(
                    weight: snapshot.requireData,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
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

Future<bool> showSnackBarOnException(
    Future<void> Function() method, BuildContext context) async {
  try {
    await method();
    return true;
  } on WeightScaleException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.message),
      duration: const Duration(milliseconds: 750),
    ));
    return false;
  }
}
