import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../content/worlds.dart';

/// The single Hive box that holds settings and progress. Opened in `main`
/// (or in tests) and injected with a provider override.
final storeProvider = Provider<Box<dynamic>>(
  (ref) => throw UnimplementedError('storeProvider must be overridden'),
);

const kStoreBox = 'brainland_v2';

@immutable
class Settings {
  const Settings({
    this.sound = true,
    this.voice = true,
    this.reduceMotion = false,
    this.languageCode,
    this.easternDigits = false,
    this.welcomed = false,
  });

  final bool sound;
  final bool voice;
  final bool reduceMotion;

  /// `ar`, `en`, or null to follow the device (Arabic unless the device is English).
  final String? languageCode;
  final bool easternDigits;

  /// The first-launch welcome has been shown.
  final bool welcomed;

  Settings copyWith({
    bool? sound,
    bool? voice,
    bool? reduceMotion,
    String? languageCode,
    bool? easternDigits,
    bool? welcomed,
  }) => Settings(
    sound: sound ?? this.sound,
    voice: voice ?? this.voice,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    languageCode: languageCode ?? this.languageCode,
    easternDigits: easternDigits ?? this.easternDigits,
    welcomed: welcomed ?? this.welcomed,
  );

  Map<String, Object?> toMap() => {
    'sound': sound,
    'voice': voice,
    'reduceMotion': reduceMotion,
    'languageCode': languageCode,
    'easternDigits': easternDigits,
    'welcomed': welcomed,
  };

  factory Settings.fromMap(Map<dynamic, dynamic> m) => Settings(
    sound: m['sound'] as bool? ?? true,
    voice: m['voice'] as bool? ?? true,
    reduceMotion: m['reduceMotion'] as bool? ?? false,
    languageCode: m['languageCode'] as String?,
    easternDigits: m['easternDigits'] as bool? ?? false,
    welcomed: m['welcomed'] as bool? ?? false,
  );
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    final raw = ref.read(storeProvider).get('settings');
    return raw is Map ? Settings.fromMap(raw) : const Settings();
  }

  void update(Settings Function(Settings) change) {
    state = change(state);
    ref.read(storeProvider).put('settings', state.toMap());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

/// Stars (0–3) per mission, [kMissionsPerWorld] per world; 0 = not finished.
@immutable
class Progress {
  const Progress(this.stars);

  final Map<World, List<int>> stars;

  List<int> of(World w) => stars[w] ?? List.filled(kMissionsPerWorld, 0);
  int starsIn(World w) => of(w).fold(0, (a, b) => a + b);
  int completedIn(World w) => of(w).where((s) => s > 0).length;
  bool isUnlocked(World w, int mission) =>
      mission == 0 || of(w)[mission - 1] > 0;

  /// The first unfinished mission (where "continue" should go).
  int nextIn(World w) {
    final i = of(w).indexOf(0);
    return i < 0 ? kMissionsPerWorld - 1 : i;
  }

  bool chapterDone(World w, int chapter) => of(w)
      .skip(chapter * kMissionsPerChapter)
      .take(kMissionsPerChapter)
      .every((s) => s > 0);
  int medalsIn(World w) {
    final list = of(w);
    var medals = 0;
    for (var start = 0; start < list.length; start += kMissionsPerChapter) {
      if (list
          .getRange(start, start + kMissionsPerChapter)
          .every((s) => s > 0)) {
        medals++;
      }
    }
    return medals;
  }

  int get totalStars => World.values.fold(0, (a, w) => a + starsIn(w));
}

class ProgressNotifier extends Notifier<Progress> {
  @override
  Progress build() {
    final box = ref.read(storeProvider);
    return Progress({
      for (final w in World.values)
        w: [
          for (var i = 0; i < kMissionsPerWorld; i++)
            ((box.get('stars.${w.slug}') as List?)?.elementAtOrNull(i)
                    as int?) ??
                0,
        ],
    });
  }

  /// Saves a finished mission, keeping the best star count.
  /// Returns true when this finish completed the mission's chapter (a medal).
  bool record(World world, int mission, int stars) {
    final chapter = mission ~/ kMissionsPerChapter;
    final hadMedal = state.chapterDone(world, chapter);
    final list = [...state.of(world)];
    if (stars > list[mission]) list[mission] = stars;
    state = Progress({...state.stars, world: list});
    ref.read(storeProvider).put('stars.${world.slug}', list);
    return !hadMedal && state.chapterDone(world, chapter);
  }

  void reset() {
    final box = ref.read(storeProvider);
    for (final w in World.values) {
      box.delete('stars.${w.slug}');
    }
    state = build();
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, Progress>(
  ProgressNotifier.new,
);

/// Missions finished since the app started (for the break reminder).
class SessionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void missionFinished() => state++;
}

final sessionProvider = NotifierProvider<SessionNotifier, int>(
  SessionNotifier.new,
);
