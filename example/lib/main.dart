import 'package:flutter/material.dart';
import 'package:weight_scale/scale.dart';

import 'page/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final manager = WeightScaleManager.defaultBackend();
  runApp(ExampleApp(manager));
}

class ExampleApp extends StatelessWidget {
  final WeightScaleManager manager;

  ExampleApp(this.manager, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeightScale Demo Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(manager),
    );
  }
}

// class MeasurementPage extends StatefulWidget {
//   MeasurementPage({Key? key, required this.scale}) : super(key: key) {
//     hasBatteryLevelFeature = scale is BatteryLevelFeature;
//     hasSetUnitFeature = scale is SetUnitFeature;
//     hasClearCacheFeature = scale is ClearCacheFeature;
//     hasCalibrateFeature = scale is CalibrateFeature;
//   }

//   final WeightScale scale;

//   late final bool hasBatteryLevelFeature;
//   late final bool hasSetUnitFeature;
//   late final bool hasClearCacheFeature;
//   late final bool hasCalibrateFeature;

//   @override
//   _MeasurementPageState createState() => _MeasurementPageState();
// }

// class _MeasurementPageState extends State<MeasurementPage> {
//   void getBatteryLevel() {
//     showDialog<String>(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text("Battery Level"),
//             content: Text((widget.scale as BatteryLevelFeature)
//                 .getBatteryLevel()
//                 .toString()),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, "OK"),
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         });
//   }

//   void setUnit() {
//     showDialog<String>(
//         context: context,
//         builder: (context) {
//           return SimpleDialog(
//             title: Text("Set Unit"),
//             children: [
//               SimpleDialogOption(
//                 onPressed: () {
//                   (widget.scale as SetUnitFeature).setUnit(WeightUnit.kg);
//                   Navigator.pop(context, "KG");
//                 },
//                 child: Text("KG"),
//               ),
//               SimpleDialogOption(
//                 onPressed: () {
//                   (widget.scale as SetUnitFeature).setUnit(WeightUnit.lbs);
//                   Navigator.pop(context, "LBS");
//                 },
//                 child: Text("LBS"),
//               ),
//             ],
//           );
//         });
//   }

//   void clearCache() {
//     (widget.scale as ClearCacheFeature).clearCache();
//   }

//   void calibrate() {
//     (widget.scale as CalibrateFeature).calibrate();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await widget.scale.disconnect();
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.scale.name),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder<double>(
//                 initialData: null,
//                 stream: widget.scale.weight,
//                 builder: (context, snapshot) {
//                   String weight = "-";
//                   String unit = describeEnum(widget.scale.unit);
//                   if (snapshot.data != null) {
//                     weight = snapshot.data!.toStringAsFixed(2);
//                   }
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(weight, style: TextStyle(fontSize: 96)),
//                         Text(unit, style: TextStyle(fontSize: 36)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 children: [
//                   Text(
//                     "FEATURES",
//                     style: TextStyle(fontSize: 24),
//                   ),
//                   Container(
//                     child: Divider(
//                       thickness: 1,
//                       color: Colors.black,
//                     ),
//                     width: 240,
//                   ),
//                   Column(
//                     children: [
//                       FeatureButton(
//                         text: "GET BATTERY %",
//                         onPressed: widget.hasBatteryLevelFeature
//                             ? getBatteryLevel
//                             : null,
//                       ),
//                       FeatureButton(
//                         text: "SET UNIT",
//                         onPressed: widget.hasSetUnitFeature ? setUnit : null,
//                       ),
//                       FeatureButton(
//                         text: "CLEAR CACHE",
//                         onPressed:
//                             widget.hasClearCacheFeature ? clearCache : null,
//                       ),
//                       FeatureButton(
//                         text: "CALIBRATE",
//                         onPressed:
//                             widget.hasCalibrateFeature ? calibrate : null,
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await widget.scale.disconnect();
//                   Navigator.pop(context);
//                 },
//                 child: Text("DISCONNECT"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FeatureButton extends StatelessWidget {
//   const FeatureButton({Key? key, required this.text, this.onPressed})
//       : super(key: key);

//   final String text;
//   final void Function()? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       child: Container(
//         width: 140,
//         child: Text(text, textAlign: TextAlign.center),
//       ),
//     );
//   }
// }
