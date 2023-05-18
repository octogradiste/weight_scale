import 'package:audioplayers/audioplayers.dart';
import 'package:climb_scale/utils/logger.dart' as log;

enum Sound {
  beep_hang,
  beep_rest,
  beep_endOfSet,
  beep_endOfHand,
  beep_endOfExercise,
  beep_countDown
}

abstract class IAudioService {
  /// Plays the given sound.
  ///
  /// The first time the sound is played, it will get loaded and cached for
  /// future use.
  Future<void> play(Sound sound);
}

class AudioService implements IAudioService {
  final AudioPlayer _audioCache = AudioPlayer();//AudioCache(prefix: 'assets/audio/');

  AudioService() {
    // Pre-load the count down beep sound to memory.
    _audioCache.audioCache.load(_soundToFileName(Sound.beep_countDown));
    _audioCache.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  Future<void> play(Sound sound) {
    log.Logger.d('AudioService', 'Playing ${sound.name}.');

    return _audioCache.play(
      AssetSource(_soundToFileName(sound))
    );
  }

  String _soundToFileName(Sound sound) {
    String prefix = 'assets/audio/';
    switch (sound) {
      case Sound.beep_hang:
        return '${prefix}beep-hang.mp3';
      case Sound.beep_rest:
        return '${prefix}beep-rest.mp3';
      case Sound.beep_endOfHand:
        return '${prefix}beep-endOfHand.mp3';
      case Sound.beep_endOfSet:
        return '${prefix}beep-endOfSet.mp3';
      case Sound.beep_endOfExercise:
        return '${prefix}beep-endOfExercise.mp3';
      case Sound.beep_countDown:
        return '${prefix}beep-countdown.mp3';
    }
  }
}
