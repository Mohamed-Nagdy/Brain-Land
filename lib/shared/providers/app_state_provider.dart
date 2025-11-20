import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/audio_manager.dart';
import '../services/storage_service.dart';

part 'app_state_provider.g.dart';

/// Global app state model
class AppState {
  final bool isAudioEnabled;
  final double musicVolume;
  final double sfxVolume;
  final bool isFirstLaunch;
  final bool isLoading;
  final String? currentPlayerId;
  final bool hasSeenTutorial;
  final bool isReducedMotion;

  const AppState({
    this.isAudioEnabled = true,
    this.musicVolume = 0.7,
    this.sfxVolume = 0.8,
    this.isFirstLaunch = true,
    this.isLoading = false,
    this.currentPlayerId,
    this.hasSeenTutorial = false,
    this.isReducedMotion = false,
  });

  AppState copyWith({
    bool? isAudioEnabled,
    double? musicVolume,
    double? sfxVolume,
    bool? isFirstLaunch,
    bool? isLoading,
    String? currentPlayerId,
    bool? hasSeenTutorial,
    bool? isReducedMotion,
  }) {
    return AppState(
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoading: isLoading ?? this.isLoading,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      isReducedMotion: isReducedMotion ?? this.isReducedMotion,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'isAudioEnabled': isAudioEnabled,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'isFirstLaunch': isFirstLaunch,
      'currentPlayerId': currentPlayerId,
      'hasSeenTutorial': hasSeenTutorial,
      'isReducedMotion': isReducedMotion,
    };
  }

  /// Create from JSON
  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      isAudioEnabled: json['isAudioEnabled'] as bool? ?? true,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.7,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.8,
      isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
      currentPlayerId: json['currentPlayerId'] as String?,
      hasSeenTutorial: json['hasSeenTutorial'] as bool? ?? false,
      isReducedMotion: json['isReducedMotion'] as bool? ?? false,
    );
  }
}

/// App state notifier with code generation
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  static const String _stateKey = 'app_state';

  // Flag to disable audio integration (useful for testing)
  static bool disableAudioIntegration = false;

  @override
  AppState build() {
    _loadState();
    return const AppState();
  }

  /// Load state from storage
  Future<void> _loadState() async {
    try {
      final storage = StorageService.instance;
      final json = storage.load<Map<dynamic, dynamic>>(
        boxName: AppConstants.settingsBoxName,
        key: _stateKey,
      );

      if (json != null) {
        final jsonMap = Map<String, dynamic>.from(json);
        state = AppState.fromJson(jsonMap);

        // Apply audio settings to AudioManager
        _applyAudioSettings();
      }
    } catch (e) {
      // If loading fails, keep default state
      log('Failed to load app state: $e');
    }
  }

  /// Save state to storage
  Future<void> _saveState() async {
    try {
      final storage = StorageService.instance;
      await storage.save(
        boxName: AppConstants.settingsBoxName,
        key: _stateKey,
        value: state.toJson(),
      );
    } catch (e) {
      log('Failed to save app state: $e');
    }
  }

  /// Apply audio settings to AudioManager
  void _applyAudioSettings() {
    if (disableAudioIntegration) return;

    try {
      final audioManager = AudioManager.instance;
      audioManager.setMusicVolume(state.musicVolume);
      audioManager.setSoundVolume(state.sfxVolume);
      if (!state.isAudioEnabled) {
        audioManager.mute();
      } else {
        audioManager.unmute();
      }
    } catch (e) {
      // AudioManager may not be available in tests or if bindings aren't initialized
      // This is acceptable - audio settings will be applied when AudioManager is available
    }
  }

  /// Toggle audio on/off
  void toggleAudio() {
    state = state.copyWith(isAudioEnabled: !state.isAudioEnabled);
    try {
      _applyAudioSettings();
    } catch (e) {
      // Ignore audio errors in tests
    }
    _saveState();
  }

  /// Set music volume (0.0 to 1.0)
  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume.clamp(0.0, 1.0));
    try {
      _applyAudioSettings();
    } catch (e) {
      // Ignore audio errors in tests
    }
    _saveState();
  }

  /// Set sound effects volume (0.0 to 1.0)
  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume.clamp(0.0, 1.0));
    try {
      _applyAudioSettings();
    } catch (e) {
      // Ignore audio errors in tests
    }
    _saveState();
  }

  /// Mark first launch as complete
  void setFirstLaunchComplete() {
    state = state.copyWith(isFirstLaunch: false);
    _saveState();
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set current player ID
  void setCurrentPlayer(String playerId) {
    state = state.copyWith(currentPlayerId: playerId);
    _saveState();
  }

  /// Mark tutorial as seen
  void setTutorialSeen() {
    state = state.copyWith(hasSeenTutorial: true);
    _saveState();
  }

  /// Toggle reduced motion mode
  void toggleReducedMotion() {
    state = state.copyWith(isReducedMotion: !state.isReducedMotion);
    _saveState();
  }

  /// Reset app state to defaults
  Future<void> reset() async {
    state = const AppState();
    await _saveState();
  }
}
