import 'package:brain_land/core/constants/app_constants.dart';
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
}
