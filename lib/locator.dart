import 'package:climb_scale/data/local/database.dart';
import 'package:climb_scale/data/repository.dart';
import 'package:climb_scale/services/audio_service.dart';
import 'package:climb_scale/services/hang_board_service.dart';
import 'package:climb_scale/services/navigation_service.dart';
import 'package:climb_scale/services/screen_service.dart';
import 'package:climb_scale/services/snack_bar_service.dart';
import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:get_it/get_it.dart';
import 'package:weight_scale/scale.dart';

final locator = GetIt.instance;

void registerServices() {
  // Services
  locator.registerLazySingleton<IAudioService>(() => AudioService());
  locator.registerLazySingleton<HangBoardService>(
      () => HangBoardService(Stopwatch()));
  locator.registerLazySingleton<INavigationService>(() => NavigationService());
  locator.registerLazySingleton<IScreenService>(() => ScreenService());
  locator.registerLazySingleton<ISnackBarService>(() => SnackBarService());
  locator.registerLazySingleton<IWeightScaleService>(
    () => WeightScaleService(WeightScaleManager.defaultBackend()),
  );

  // Data
  locator.registerLazySingleton<Repository>(
    () => Repository(database: Database()),
  );
}
