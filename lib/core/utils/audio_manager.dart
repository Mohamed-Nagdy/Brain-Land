import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

/// Singleton class for managing all audio playback in the game
/// Handles background music, sound effects, and volume controls
class AudioManager {
  // Singleton instance
  static AudioManager? _instance;
  static AudioManager get instance => _instance ??= AudioManager._();

  AudioManager._();

  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();

  // Volume settings (0.0 to 1.0)
  double _musicVolume = 0.7;
  double _soundVolume = 0.8;
  bool _isMuted = false;

  // Current music track
  String? _currentMusicTrack;

  /// Initialize the audio manager
  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _soundPlayer.setReleaseMode(ReleaseMode.stop);

    // Set initial volumes
    await _musicPlayer.setVolume(_musicVolume);
    await _soundPlayer.setVolume(_soundVolume);
  }

  /// Play background music
  ///
  /// [assetPath] - Path to the music file in assets
  /// [loop] - Whether to loop the music (default: true)
  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (_isMuted) return;

    // Don't restart if already playing the same track
    if (_currentMusicTrack == assetPath &&
        _musicPlayer.state == PlayerState.playing) {
      return;
    }

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.stop,
      );
      await _musicPlayer.play(AssetSource(assetPath));
      _currentMusicTrack = assetPath;
    } catch (e) {
      // Log error but don't throw - audio failures should be silent
      log('Failed to play music: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      _currentMusicTrack = null;
    } catch (e) {
      log('Failed to stop music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      log('Failed to pause music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (_isMuted) return;

    try {
      await _musicPlayer.resume();
    } catch (e) {
      log('Failed to resume music: $e');
    }
  }

  /// Play a sound effect
  ///
  /// [assetPath] - Path to the sound file in assets
  Future<void> playSound(String assetPath) async {
    if (_isMuted) return;

    try {
      await _soundPlayer.stop();
      await _soundPlayer.play(AssetSource(assetPath));
    } catch (e) {
      log('Failed to play sound: $e');
    }
  }

  /// Set music volume
  ///
  /// [volume] - Volume level from 0.0 (silent) to 1.0 (max)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    if (!_isMuted) {
      await _musicPlayer.setVolume(_musicVolume);
    }
  }

  /// Set sound effects volume
  ///
  /// [volume] - Volume level from 0.0 (silent) to 1.0 (max)
  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    if (!_isMuted) {
      await _soundPlayer.setVolume(_soundVolume);
    }
  }

  /// Get current music volume
  double get musicVolume => _musicVolume;

  /// Get current sound volume
  double get soundVolume => _soundVolume;

  /// Check if audio is muted
  bool get isMuted => _isMuted;

  /// Mute all audio
  Future<void> mute() async {
    _isMuted = true;
    await _musicPlayer.setVolume(0.0);
    await _soundPlayer.setVolume(0.0);
  }

  /// Unmute all audio
  Future<void> unmute() async {
    _isMuted = false;
    await _musicPlayer.setVolume(_musicVolume);
    await _soundPlayer.setVolume(_soundVolume);
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    if (_isMuted) {
      await unmute();
    } else {
      await mute();
    }
  }

  /// Dispose of audio resources
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _soundPlayer.dispose();
  }
}

/// Enum for sound effects in the game
enum SoundEffect {
  buttonClick('sounds/button_click.mp3'),
  correctAnswer('sounds/correct.mp3'),
  incorrectAnswer('sounds/incorrect.mp3'),
  levelComplete('sounds/level_complete.mp3'),
  starEarned('sounds/star.mp3'),
  rewardUnlock('sounds/reward.mp3'),
  chestOpen('sounds/chest_open.mp3'),
  celebration('sounds/celebration.mp3');

  final String path;
  const SoundEffect(this.path);
}

/// Enum for background music tracks
enum MusicTrack {
  mainMenu('music/main_menu.mp3'),
  mathForest('music/math_forest.mp3'),
  logicMountain('music/logic_mountain.mp3'),
  memoryRiver('music/memory_river.mp3'),
  shapeValley('music/shape_valley.mp3');

  final String path;
  const MusicTrack(this.path);
}
