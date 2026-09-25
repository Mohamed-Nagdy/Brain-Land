import 'dart:io';

import 'package:brain_land/app.dart';
import 'package:brain_land/content/missions.dart';
import 'package:brain_land/content/worlds.dart';
import 'package:brain_land/core/audio.dart';
import 'package:brain_land/data/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

/// Plays the first mission of every world on a real device or simulator:
/// a wrong answer, a hint, pause and resume, backgrounding, completion,
/// then an app restart that must restore progress. Saves screenshots.
///
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/app_test.dart --dart-define=LANG=ar -d DEVICE_ID
const lang = String.fromEnvironment('LANG', defaultValue: 'ar');
const device = String.fromEnvironment('DEVICE', defaultValue: 'device');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Box<dynamic> store;
  var surfaceReady = false;

  Future<void> shot(WidgetTester tester, String name) async {
    if (Platform.isAndroid && !surfaceReady) {
      await binding.convertFlutterSurfaceToImage();
      surfaceReady = true;
    }
    await tester.pumpAndSettle();
    await binding.takeScreenshot('${device}_${lang}_$name');
  }

  Future<void> launch(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [storeProvider.overrideWithValue(store)],
    );
    await container.read(audioProvider).load();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BrainLandApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(
    WidgetTester tester,
    String key, {
    int settleMs = 400,
  }) async {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump(Duration(milliseconds: settleMs));
    await tester.pumpAndSettle();
  }

  /// Waits for the "well done" pause between items.
  Future<void> next(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  }

  Future<void> openMission(WidgetTester tester, World w) async {
    await tapKey(tester, 'world-${w.slug}');
    await tapKey(tester, 'mission-0');
  }

  setUpAll(() async {
    await Hive.initFlutter('brainland_it_$lang');
    await Hive.deleteBoxFromDisk(kStoreBox);
    store = await Hive.openBox<dynamic>(kStoreBox);
    await store.put('settings', {'languageCode': lang, 'welcomed': false});
    await store.put('legacyImported', true);
  });

  testWidgets(
    'a mission in every world, with mistakes, hints, pause and restart',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await launch(tester);
      await shot(tester, '01_map');

      // ── Math Forest: count; wrong answer, hint, then right answers ──
      await openMission(tester, World.math);
      await shot(tester, '02_math_question');
      final math = mathMission(0);
      final firstWrong = math.first.options.keys.firstWhere(
        (v) => v != math.first.answer,
      );
      await tapKey(tester, 'choice-$firstWrong');
      await shot(tester, '03_math_mistake');
      await tester.tap(find.bySemanticsLabel(RegExp('Hint|تلميح')));
      await tester.pumpAndSettle();
      await shot(tester, '04_math_hint');
      for (var i = 0; i < math.length; i++) {
        await tapKey(tester, 'choice-${math[i].answer}');
        await next(tester);
      }
      await shot(tester, '05_math_done');
      expect(store.get('stars.math'), isA<List>());
      expect((store.get('stars.math') as List).first, greaterThan(0));

      // Break reminder is not due yet; go to the next mission from the result.
      await tester.tap(find.byKey(const ValueKey('done-map')));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(RegExp('Back|رجوع')).first);
      await tester.pumpAndSettle();

      // ── Logic Mountain, with pause/resume and backgrounding ──
      await openMission(tester, World.logic);
      final logic = logicMission(0);
      await shot(tester, '06_logic_question');
      await tester.tap(find.bySemanticsLabel(RegExp('Pause|إيقاف مؤقت')));
      await tester.pumpAndSettle();
      await shot(tester, '07_pause');
      await tester.tap(find.bySemanticsLabel(RegExp('Continue|تابِع')));
      await tester.pumpAndSettle();
      final wrong = logic.first.choices.indexWhere(
        (c) => c != logic.first.answer,
      );
      await tapKey(tester, 'choice-$wrong');
      await tester.tap(find.bySemanticsLabel(RegExp('Hint|تلميح')));
      await tester.pumpAndSettle();
      await shot(tester, '08_logic_hint');
      // Background and return (no frames are drawn while paused, so don't pump in between).
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      for (final t in logic) {
        await tapKey(tester, 'choice-${t.choices.indexOf(t.answer)}');
        await next(tester);
      }
      await shot(tester, '09_logic_done');
      await tester.tap(find.byKey(const ValueKey('done-map')));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(RegExp('Back|رجوع')).first);
      await tester.pumpAndSettle();

      // ── Memory River: one mismatch, then all pairs ──
      await openMission(tester, World.memory);
      await shot(tester, '10_memory_peek');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final cards = find.byWidgetPredicate(
        (wd) =>
            wd.key is ValueKey<String> &&
            (wd.key! as ValueKey<String>).value.startsWith('card-'),
      );
      final keys = [
        for (final e in cards.evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ];
      final byFace = <String, List<String>>{};
      for (final k in keys) {
        byFace.putIfAbsent(k.split('-').last, () => []).add(k);
      }
      final faces = byFace.keys.toList();
      await tapKey(tester, byFace[faces[0]]![0], settleMs: 100);
      await tapKey(tester, byFace[faces[1]]![0], settleMs: 100);
      await shot(tester, '11_memory_mismatch');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      for (final pair in byFace.values) {
        await tapKey(tester, pair[0], settleMs: 100);
        await tapKey(tester, pair[1], settleMs: 100);
        if (pair == byFace.values.elementAt(byFace.length - 2)) {
          await shot(tester, '12_memory_progress');
        }
      }
      await next(tester);
      await shot(tester, '13_memory_done');
      await tester.tap(find.byKey(const ValueKey('done-map')));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(RegExp('Back|رجوع')).first);
      await tester.pumpAndSettle();

      // ── Shape Valley: a wrong home, then tap-to-place every piece ──
      await openMission(tester, World.shape);
      await shot(tester, '14_shape_board');
      final boards = shapeMission(0);
      for (var b = 0; b < boards.length; b++) {
        final board = boards[b];
        if (b == 0) {
          final wrongSlot = List.generate(
            board.slots.length,
            (i) => i,
          ).firstWhere((s) => !board.pieces[0].fits(board.slots[s]));
          await tapKey(tester, 'piece-0');
          await tapKey(tester, 'slot-$wrongSlot');
        }
        for (var p = 0; p < board.pieces.length; p++) {
          final s = List.generate(
            board.slots.length,
            (i) => i,
          ).firstWhere((s) => board.pieces[p].fits(board.slots[s]));
          await tapKey(tester, 'piece-$p');
          await tapKey(tester, 'slot-$s');
          if (b == 0 && p == 1) await shot(tester, '15_shape_progress');
        }
        await next(tester);
      }
      await shot(tester, '16_shape_done');
      await tester.tap(find.byKey(const ValueKey('done-map')));
      await tester.pumpAndSettle();

      // ── World screen with progress, then back to the map ──
      await shot(tester, '17_world_path');
      await tester.tap(find.bySemanticsLabel(RegExp('Back|رجوع')).first);
      await tester.pumpAndSettle();
      await shot(tester, '18_map_progress');

      // ── Restart: progress comes back from disk ──
      final before = {
        for (final w in World.values)
          w: (store.get('stars.${w.slug}') as List).first,
      };
      await store.close();
      store = await Hive.openBox<dynamic>(kStoreBox);
      await tester.pumpWidget(const SizedBox());
      await launch(tester);
      for (final w in World.values) {
        expect((store.get('stars.${w.slug}') as List).first, before[w]);
        expect(before[w], greaterThan(0));
      }

      // ── Parents gate opens from the map ──
      await tester.tap(find.bySemanticsLabel(RegExp('For parents|للأهل')));
      await tester.pumpAndSettle();
      await shot(tester, '19_parent_gate');
      semantics.dispose();
    },
  );
}
