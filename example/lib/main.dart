import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';
import 'page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Here we get and initialize the weight scale manager before running the app.
  // In you're app you would ideally do this in you're a loading screen.
  final manager = WeightScaleManager.defaultBackend();
  await manager.initialize();

  runApp(ExampleApp(manager));
}

class ExampleApp extends StatelessWidget {
  final WeightScaleManager manager;

  const ExampleApp(this.manager, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeightScale Demo Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(manager),
    );
  }
}
