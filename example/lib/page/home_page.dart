import 'package:example/page/scale_page.dart';
import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

class HomePage extends StatefulWidget {
  final WeightScaleManager manager;

  HomePage(this.manager, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _scanning = false;

  Future<void> _toggleScanning() async {
    if (_scanning) {
      await widget.manager.stopScan();
      setState(() => _scanning = false);
    } else {
      setState(() => _scanning = true);
      await widget.manager.startScan();
      setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WeightScale Example App"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScanning,
        tooltip: 'Scan',
        child: _scanning ? Icon(Icons.stop) : Icon(Icons.search),
      ),
      body: StreamBuilder<List<WeightScale>>(
        initialData: [],
        stream: widget.manager.scales,
        builder: (context, snapshot) {
          final scales = snapshot.requireData;
          return ListView.builder(
            itemCount: scales.length,
            itemBuilder: (context, index) {
              final scale = scales[index];
              return ListTile(
                title: Text(scale.name),
                subtitle: Text(scale.manufacturer),
                trailing: TextButton(
                  child: Text('CONNECT'),
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (context) => ScalePage(scale),
                    );
                    Navigator.push(context, route);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
