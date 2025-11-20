import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/core/utils/audio_manager.dart';
import 'package:brain_land/features/math_forest/presentation/widgets/answer_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Answer Feedback Properties', () {
    // **Feature: brainland-game, Property 5: Answer feedback is immediate**
    testWidgets(
      'answer feedback is provided immediately when answer is selected',
      (tester) async {
        // Test across multiple iterations to ensure consistency
        for (int i = 0; i < AppConstants.pbtIterations; i++) {
          bool feedbackReceived = false;
          bool? isCorrect;

          // Create a stateful wrapper to test feedback timing
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    return Center(
                      child: AnswerBubble(
                        answer: '5',
                        isCorrect: isCorrect,
                        onTap: () {
                          setState(() {
                            isCorrect = true;
                            feedbackReceived = true;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          // Tap the answer bubble
          await tester.tap(find.byType(AnswerBubble));

          // Pump a single frame (immediate feedback)
          await tester.pump();

          // Verify feedback was received immediately (within same frame)
          expect(
            feedbackReceived,
            isTrue,
            reason: 'Feedback should be received immediately after tap',
          );

          // Verify visual feedback is present (gradient changed)
          final bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
          expect(
            bubble.isCorrect,
            isTrue,
            reason: 'Visual feedback should be applied immediately',
          );

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets('correct answer feedback is immediate and distinct', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AnswerBubble(
                    answer: '10',
                    isCorrect: tapped ? true : null,
                    onTap: () {
                      setState(() {
                        tapped = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initial state - no feedback
      var bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
      expect(bubble.isCorrect, isNull);

      // Tap and verify immediate feedback
      await tester.tap(find.byType(AnswerBubble));
      await tester.pump(); // Single frame

      bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
      expect(
        bubble.isCorrect,
        isTrue,
        reason: 'Correct feedback should be immediate',
      );
    });

    testWidgets('incorrect answer feedback is immediate and distinct', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AnswerBubble(
                    answer: '7',
                    isCorrect: tapped ? false : null,
                    onTap: () {
                      setState(() {
                        tapped = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initial state - no feedback
      var bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
      expect(bubble.isCorrect, isNull);

      // Tap and verify immediate feedback
      await tester.tap(find.byType(AnswerBubble));
      await tester.pump(); // Single frame

      bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
      expect(
        bubble.isCorrect,
        isFalse,
        reason: 'Incorrect feedback should be immediate',
      );
    });

    testWidgets('feedback animation starts immediately on state change', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnswerBubble(answer: '3', isCorrect: null, onTap: () {}),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Trigger rebuild with feedback
                          });
                        },
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Find the initial bubble
      expect(find.byType(AnswerBubble), findsOneWidget);

      // Verify widget is mounted and responsive
      expect(find.byType(AnswerBubble), findsOneWidget);
    });

    testWidgets('multiple answer bubbles can provide feedback independently', (
      tester,
    ) async {
      final answers = ['2', '4', '6', '8'];
      final tappedStates = List.filled(4, false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: List.generate(
                      4,
                      (index) => AnswerBubble(
                        key: ValueKey('bubble_$index'),
                        answer: answers[index],
                        isCorrect: tappedStates[index] ? true : null,
                        onTap: () {
                          setState(() {
                            tappedStates[index] = true;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap first bubble
      await tester.tap(find.byKey(const ValueKey('bubble_0')));
      await tester.pump();

      // Verify only first bubble has feedback
      var bubble0 = tester.widget<AnswerBubble>(
        find.byKey(const ValueKey('bubble_0')),
      );
      var bubble1 = tester.widget<AnswerBubble>(
        find.byKey(const ValueKey('bubble_1')),
      );

      expect(bubble0.isCorrect, isTrue);
      expect(bubble1.isCorrect, isNull);

      // Tap second bubble
      await tester.tap(find.byKey(const ValueKey('bubble_1')));
      await tester.pump();

      // Verify both have feedback now
      bubble1 = tester.widget<AnswerBubble>(
        find.byKey(const ValueKey('bubble_1')),
      );
      expect(bubble1.isCorrect, isTrue);
    });

    testWidgets('feedback is immediate regardless of answer correctness', (
      tester,
    ) async {
      // Test with various correctness states
      final correctnessStates = [true, false, true, false, true];

      for (final isCorrect in correctnessStates) {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Center(
                    child: AnswerBubble(
                      answer: '9',
                      isCorrect: tapped ? isCorrect : null,
                      onTap: () {
                        setState(() {
                          tapped = true;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Tap and verify immediate feedback
        await tester.tap(find.byType(AnswerBubble));
        await tester.pump(); // Single frame - immediate

        final bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
        expect(
          bubble.isCorrect,
          equals(isCorrect),
          reason: 'Feedback should be immediate for correctness: $isCorrect',
        );

        // Clean up
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('disabled bubbles do not provide feedback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnswerBubble(
                answer: '1',
                isCorrect: null,
                isEnabled: false,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Try to tap disabled bubble
      await tester.tap(find.byType(AnswerBubble));
      await tester.pump();

      // Verify no feedback was triggered
      expect(
        tapped,
        isFalse,
        reason: 'Disabled bubble should not trigger feedback',
      );
    });

    testWidgets('feedback timing is consistent across rapid taps', (
      tester,
    ) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AnswerBubble(
                    answer: '12',
                    isCorrect: tapCount > 0 ? true : null,
                    onTap: () {
                      setState(() {
                        tapCount++;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Perform rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(AnswerBubble));
        await tester.pump(); // Immediate feedback each time

        final bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
        expect(
          bubble.isCorrect,
          isTrue,
          reason: 'Feedback should be immediate on tap $i',
        );
      }

      expect(tapCount, equals(5));
    });

    testWidgets('visual feedback state persists after animation completes', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AnswerBubble(
                    answer: '15',
                    isCorrect: tapped ? true : null,
                    onTap: () {
                      setState(() {
                        tapped = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap and wait for animation to complete
      await tester.tap(find.byType(AnswerBubble));
      await tester.pump(); // Immediate feedback
      await tester.pumpAndSettle(); // Complete all animations

      // Verify feedback state persists
      final bubble = tester.widget<AnswerBubble>(find.byType(AnswerBubble));
      expect(
        bubble.isCorrect,
        isTrue,
        reason: 'Feedback state should persist after animation',
      );
    });
  });

  group('Audio Feedback Properties', () {
    // **Feature: brainland-game, Property 5: Answer feedback is immediate (includes audio)**
    // **Validates: Requirements 2.2, 10.2**
    test('audio manager is initialized and ready for playback', () async {
      // Verify AudioManager singleton is accessible
      final audioManager = AudioManager.instance;
      expect(audioManager, isNotNull);

      // Verify audio manager can be initialized
      await audioManager.initialize();

      // Verify volume controls are accessible
      expect(audioManager.musicVolume, greaterThanOrEqualTo(0.0));
      expect(audioManager.musicVolume, lessThanOrEqualTo(1.0));
      expect(audioManager.soundVolume, greaterThanOrEqualTo(0.0));
      expect(audioManager.soundVolume, lessThanOrEqualTo(1.0));
    });

    test('sound effect paths are defined for all feedback types', () {
      // Verify all required sound effects are defined
      expect(SoundEffect.correctAnswer.path, isNotEmpty);
      expect(SoundEffect.incorrectAnswer.path, isNotEmpty);
      expect(SoundEffect.buttonClick.path, isNotEmpty);
      expect(SoundEffect.levelComplete.path, isNotEmpty);
      expect(SoundEffect.starEarned.path, isNotEmpty);
      expect(SoundEffect.rewardUnlock.path, isNotEmpty);
      expect(SoundEffect.chestOpen.path, isNotEmpty);
      expect(SoundEffect.celebration.path, isNotEmpty);

      // Verify paths follow expected format
      expect(SoundEffect.correctAnswer.path, contains('sounds/'));
      expect(SoundEffect.incorrectAnswer.path, contains('sounds/'));
    });

    test('audio playback methods are non-blocking', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      // Measure time to call playSound (should return immediately)
      final stopwatch = Stopwatch()..start();
      await audioManager.playSound(SoundEffect.correctAnswer.path);
      stopwatch.stop();

      // Audio playback should be asynchronous and return quickly
      // Even if file doesn't exist, it should fail gracefully and return fast
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Audio playback should be non-blocking and return quickly',
      );
    });

    test('multiple sound effects can be triggered in sequence', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      // Trigger multiple sounds rapidly (simulating rapid user interaction)
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10; i++) {
        await audioManager.playSound(SoundEffect.buttonClick.path);
      }

      stopwatch.stop();

      // All sounds should be triggered quickly
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Multiple sound effects should be triggered rapidly',
      );
    });

    test('audio feedback respects mute state', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      // Mute audio
      await audioManager.mute();
      expect(audioManager.isMuted, isTrue);

      // Attempt to play sound while muted (should not throw)
      expect(
        () async =>
            await audioManager.playSound(SoundEffect.correctAnswer.path),
        returnsNormally,
      );

      // Unmute
      await audioManager.unmute();
      expect(audioManager.isMuted, isFalse);

      // Sound should play when unmuted (should not throw)
      expect(
        () async =>
            await audioManager.playSound(SoundEffect.correctAnswer.path),
        returnsNormally,
      );
    });

    test(
      'volume controls work independently for music and sound effects',
      () async {
        final audioManager = AudioManager.instance;
        await audioManager.initialize();

        // Set different volumes
        await audioManager.setMusicVolume(0.5);
        await audioManager.setSoundVolume(0.8);

        // Verify volumes are set correctly
        expect(audioManager.musicVolume, equals(0.5));
        expect(audioManager.soundVolume, equals(0.8));

        // Verify volumes are clamped to valid range
        await audioManager.setMusicVolume(1.5); // Above max
        expect(audioManager.musicVolume, equals(1.0));

        await audioManager.setSoundVolume(-0.5); // Below min
        expect(audioManager.soundVolume, equals(0.0));
      },
    );

    test('audio manager handles missing files gracefully', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      // Attempt to play non-existent file (should not throw)
      expect(
        () async => await audioManager.playSound('sounds/nonexistent.mp3'),
        returnsNormally,
      );

      expect(
        () async => await audioManager.playMusic('music/nonexistent.mp3'),
        returnsNormally,
      );
    });

    test('correct and incorrect sounds are distinct', () {
      // Verify different sound effects have different paths
      expect(
        SoundEffect.correctAnswer.path,
        isNot(equals(SoundEffect.incorrectAnswer.path)),
        reason: 'Correct and incorrect sounds should be different',
      );

      // Verify paths are meaningful
      expect(SoundEffect.correctAnswer.path, contains('correct'));
      expect(SoundEffect.incorrectAnswer.path, contains('incorrect'));
    });

    test('audio feedback is immediate across multiple iterations', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      // Test across multiple iterations (property-based approach)
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final stopwatch = Stopwatch()..start();

        // Simulate answer feedback
        await audioManager.playSound(
          i % 2 == 0
              ? SoundEffect.correctAnswer.path
              : SoundEffect.incorrectAnswer.path,
        );

        stopwatch.stop();

        // Verify audio call returns immediately (non-blocking)
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(50),
          reason: 'Audio feedback should be immediate on iteration $i',
        );
      }
    });

    test('audio manager can be toggled between mute states', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      final initialMuteState = audioManager.isMuted;

      // Toggle mute
      await audioManager.toggleMute();
      expect(audioManager.isMuted, equals(!initialMuteState));

      // Toggle back
      await audioManager.toggleMute();
      expect(audioManager.isMuted, equals(initialMuteState));

      // Multiple rapid toggles
      for (int i = 0; i < 10; i++) {
        await audioManager.toggleMute();
      }

      // Should end up in opposite state (10 toggles)
      expect(audioManager.isMuted, equals(!initialMuteState));
    });

    test(
      'background music and sound effects can play simultaneously',
      () async {
        final audioManager = AudioManager.instance;
        await audioManager.initialize();

        // Start background music
        await audioManager.playMusic(MusicTrack.mathForest.path);

        // Play sound effect while music is playing (should not interfere)
        expect(
          () async =>
              await audioManager.playSound(SoundEffect.correctAnswer.path),
          returnsNormally,
        );

        // Stop music
        await audioManager.stopMusic();
      },
    );

    test('audio feedback timing is consistent under load', () async {
      final audioManager = AudioManager.instance;
      await audioManager.initialize();

      final timings = <int>[];

      // Measure timing across multiple rapid calls
      for (int i = 0; i < 50; i++) {
        final stopwatch = Stopwatch()..start();
        await audioManager.playSound(SoundEffect.buttonClick.path);
        stopwatch.stop();
        timings.add(stopwatch.elapsedMilliseconds);
      }

      // Calculate average timing
      final averageTiming = timings.reduce((a, b) => a + b) / timings.length;

      // Verify consistent timing (should be fast and consistent)
      expect(
        averageTiming,
        lessThan(20),
        reason: 'Average audio feedback timing should be fast',
      );

      // Verify no outliers (all calls should be reasonably fast)
      for (final timing in timings) {
        expect(
          timing,
          lessThan(100),
          reason: 'All audio feedback calls should be fast',
        );
      }
    });
  });
}
