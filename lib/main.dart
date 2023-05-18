import 'package:climb_scale/locator.dart';
import 'package:climb_scale/services/navigation_service.dart';
import 'package:climb_scale/services/snack_bar_service.dart';
import 'package:climb_scale/ui/page/home_page.dart';
import 'package:climb_scale/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  Logger.logLevel = LogLevel.info;

  // Force to portrait mode.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  registerServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radja',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      navigatorKey: locator<INavigationService>().navigatorKey,
      scaffoldMessengerKey: locator<ISnackBarService>().messengerKey,
      home: HomePage(),
    );
  }
}
