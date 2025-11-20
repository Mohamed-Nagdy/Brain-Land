import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  Future<void> playSound(String soundName) async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      // Silently handle missing sound files in development
      // In production, you would want to include actual sound files
      if (kDebugMode) {
        print('[AudioService] Sound file not found: $soundName.mp3');
      }
    }
  }

  Future<void> playBackgroundMusic(String musicName) async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.play(
        AssetSource('sounds/$musicName.mp3'),
        mode: PlayerMode.mediaPlayer,
      );
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // Silently handle missing music files in development
      if (kDebugMode) {
        print('[AudioService] Music file not found: $musicName.mp3');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioService] Failed to stop background music: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
