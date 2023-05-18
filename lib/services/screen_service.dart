import 'package:climb_scale/utils/logger.dart';
import 'package:wakelock/wakelock.dart';

abstract class IScreenService {
  /// Prevents the screen from turning off.
  void wakeLockOn();

  /// Allows the screen to turn off.
  void wakeLockOff();
}

class ScreenService implements IScreenService {
  static const String _className = 'ScreenService';
  @override
  void wakeLockOn() {
    Logger.d(_className, 'Enabling wake-lock.');
    Wakelock.enable();
  }

  @override
  void wakeLockOff() {
    Logger.d(_className, 'Disabling wake-lock.');
    Wakelock.disable();
  }
}
