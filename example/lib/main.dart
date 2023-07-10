import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

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
  const HomePage({required this.manager, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isScanning = false;

  @override
  void initState() {
    super.initState();
    isScanning = widget.manager.isScanning;
  }

  void toggleScan() {
    if (isScanning) {
      setState(() => isScanning = false);
      widget.manager.stopScan();
    } else {
      setState(() => isScanning = true);
      widget.manager
          .startScan()
          .then((_) => setState(() => isScanning = false));
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
                  onPressed: () {},
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

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
