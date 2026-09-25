import 'package:brain_land/content/worlds.dart';
import 'package:brain_land/data/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers.dart';

void main() {
  tearDown(() => Hive.close());

  test(
    'a fresh install starts with no stars (v1.0 showed 187★ and 425 coins)',
    () async {
      final c = containerWith(await openTestStore());
      final p = c.read(progressProvider);
      expect(p.totalStars, 0);
      for (final w in World.values) {
        expect(p.completedIn(w), 0);
        expect(p.isUnlocked(w, 0), isTrue);
        expect(p.isUnlocked(w, 1), isFalse);
      }
    },
  );

  test('missions unlock one after another and keep the best stars', () async {
    final store = await openTestStore();
    final c = containerWith(store);
    final progress = c.read(progressProvider.notifier);
    progress.record(World.math, 0, 2);
    expect(c.read(progressProvider).isUnlocked(World.math, 1), isTrue);
    expect(c.read(progressProvider).isUnlocked(World.logic, 1), isFalse);
    progress.record(World.math, 0, 1);
    expect(c.read(progressProvider).of(World.math)[0], 2);
    progress.record(World.math, 0, 3);
    expect(c.read(progressProvider).of(World.math)[0], 3);
    expect(c.read(progressProvider).nextIn(World.math), 1);
  });

  test('progress survives an app restart', () async {
    final store = await openTestStore();
    containerWith(
      store,
    ).read(progressProvider.notifier).record(World.shape, 0, 3);
    await store.close();
    final reopened = await Hive.openBox<dynamic>(kStoreBox);
    final p = containerWith(reopened).read(progressProvider);
    expect(p.of(World.shape)[0], 3);
    expect(p.totalStars, 3);
  });

  test('finishing a chapter earns its medal exactly once', () async {
    final c = containerWith(await openTestStore());
    final progress = c.read(progressProvider.notifier);
    for (var i = 0; i < kMissionsPerChapter - 1; i++) {
      expect(progress.record(World.memory, i, 1), isFalse);
    }
    expect(progress.record(World.memory, kMissionsPerChapter - 1, 1), isTrue);
    expect(progress.record(World.memory, kMissionsPerChapter - 1, 3), isFalse);
    expect(c.read(progressProvider).medalsIn(World.memory), 1);
  });

  test('reset clears progress', () async {
    final c = containerWith(await openTestStore());
    c.read(progressProvider.notifier).record(World.logic, 0, 3);
    c.read(progressProvider.notifier).reset();
    expect(c.read(progressProvider).totalStars, 0);
  });

  test('settings persist', () async {
    final store = await openTestStore();
    containerWith(store)
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            sound: false,
            reduceMotion: true,
            languageCode: 'en',
            easternDigits: true,
          ),
        );
    final s = containerWith(store).read(settingsProvider);
    expect(
      [s.sound, s.voice, s.reduceMotion, s.languageCode, s.easternDigits],
      [false, true, true, 'en', true],
    );
  });
}
