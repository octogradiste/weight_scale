import 'package:climb_scale/utils/logger.dart';
import 'package:flutter/material.dart';

abstract class ISnackBarService {
  GlobalKey<ScaffoldMessengerState> get messengerKey;

  void clearSnackBars();

  void showSnackBar(SnackBar snackBar);
}

class SnackBarService implements ISnackBarService {
  static const String _className = 'SnackBarService';
  static final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey();

  @override
  GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  @override
  void clearSnackBars() {
    Logger.d(_className, 'Clearing all snack bars.');
    _messengerKey.currentState!.clearSnackBars();
  }

  @override
  void showSnackBar(SnackBar snackBar) {
    _messengerKey.currentState!.showSnackBar(snackBar);
  }
}
