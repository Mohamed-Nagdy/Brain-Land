import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store.dart';

enum Sfx { tap, correct, oops, flip, place, complete, star }

/// Short sound effects and the recorded voice guide. Both respect the
/// parents' settings; the voice guide only plays lines that were recorded.
class GameAudio {
  GameAudio(this._ref);

  final Ref _ref;
  // No position tracking: the default updater requests a frame every frame
  // while a clip plays, which the game never needs.
  final _sfx = AudioPlayer()
    ..setPlayerMode(PlayerMode.lowLatency)
    ..positionUpdater = null;
  final _voice = AudioPlayer()..positionUpdater = null;
  Set<String> _available = const {};

  Future<void> load() async {
    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _available = manifest
        .listAssets()
        .where((a) => a.startsWith('assets/audio/'))
        .toSet();
  }

  Settings get _settings => _ref.read(settingsProvider);

  void play(Sfx effect) {
    final path = 'audio/sfx/${effect.name}.wav';
    if (!_settings.sound || !_available.contains('assets/$path')) return;
    _sfx.stop().then((_) => _sfx.play(AssetSource(path)));
  }

  /// Says a localized line, e.g. `say('instrCount', 'ar')`.
  void say(String line, String languageCode) {
    final path = 'audio/voice/$languageCode/$line.m4a';
    if (!_settings.voice || !_available.contains('assets/$path')) return;
    _voice.stop().then((_) => _voice.play(AssetSource(path)));
  }

  bool hasVoice(String line, String languageCode) =>
      _available.contains('assets/audio/voice/$languageCode/$line.m4a');

  void stopVoice() => _voice.stop();
}

final audioProvider = Provider<GameAudio>((ref) => GameAudio(ref));
