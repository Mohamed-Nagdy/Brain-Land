import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_provider.g.dart';

/// Global app state model
class AppState {
  final bool isAudioEnabled;
  final double musicVolume;
  final double sfxVolume;
  final bool isFirstLaunch;

  const AppState({
    this.isAudioEnabled = true,
    this.musicVolume = 0.7,
    this.sfxVolume = 0.8,
    this.isFirstLaunch = true,
  });

  AppState copyWith({
    bool? isAudioEnabled,
    double? musicVolume,
    double? sfxVolume,
    bool? isFirstLaunch,
  }) {
    return AppState(
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

/// App state notifier with code generation
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    return const AppState();
  }

  void toggleAudio() {
    state = state.copyWith(isAudioEnabled: !state.isAudioEnabled);
  }

  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume.clamp(0.0, 1.0));
  }

  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume.clamp(0.0, 1.0));
  }

  void setFirstLaunchComplete() {
    state = state.copyWith(isFirstLaunch: false);
  }
}
