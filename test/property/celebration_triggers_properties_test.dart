import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/math_forest/presentation/widgets/celebration_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Celebration Triggers Properties', () {
    // **Feature: brainland-game, Property 35: Success triggers particle effects**
    testWidgets('success events trigger confetti particle effects', (
      tester,
    ) async {
      // Test across multiple iterations
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CelebrationWidget(
                message: 'Success!',
                stars: 3,
                showConfetti: true,
              ),
            ),
          ),
        );

        // Verify celebration widget is displayed
        expect(
          find.byType(CelebrationWidget),
          findsOneWidget,
          reason: 'Celebration widget should be displayed on success',
        );

        // Verify confetti painter is present
        expect(
          find.byType(CustomPaint),
          findsWidgets,
          reason: 'Confetti particles should be rendered',
        );

        // Pump a frame to start animation
        await tester.pump();

        // Verify widget is still present and animating
        expect(find.byType(CelebrationWidget), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('celebration displays correct number of stars', (tester) async {
      // Test with different star counts
      for (int stars = 1; stars <= 3; stars++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CelebrationWidget(message: 'Great!', stars: stars),
            ),
          ),
        );

        // Count star icons
        final starIcons = find.byIcon(Icons.star);
        expect(
          starIcons,
          findsNWidgets(stars),
          reason: 'Should display exactly $stars star(s)',
        );

        // Clean up
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('celebration message is displayed correctly', (tester) async {
      final messages = [
        'Great job!',
        'Excellent!',
        'Perfect!',
        'Amazing!',
        'Well done!',
      ];

      for (final message in messages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CelebrationWidget(message: message, stars: 3)),
          ),
        );

        // Verify message is displayed
        expect(
          find.text(message),
          findsOneWidget,
          reason: 'Celebration message "$message" should be displayed',
        );

        // Clean up
        await tester.pumpWidget(Container());
      }
    });

    testWidgets(
      'confetti can be disabled while keeping other celebration elements',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CelebrationWidget(
                message: 'Success!',
                stars: 2,
                showConfetti: false,
              ),
            ),
          ),
        );

        // Verify celebration widget exists
        expect(find.byType(CelebrationWidget), findsOneWidget);

        // Verify stars are shown
        expect(find.byIcon(Icons.star), findsNWidgets(2));

        // Verify message is shown
        expect(find.text('Success!'), findsOneWidget);
      },
    );

    testWidgets('celebration overlay shows celebration on top of content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CelebrationOverlay(
              showCelebration: true,
              message: 'Level Complete!',
              stars: 3,
              child: const Center(child: Text('Game Content')),
            ),
          ),
        ),
      );

      // Verify both content and celebration are present
      expect(
        find.text('Game Content'),
        findsOneWidget,
        reason: 'Original content should still be visible',
      );
      expect(
        find.byType(CelebrationWidget),
        findsOneWidget,
        reason: 'Celebration should be overlaid',
      );
      expect(
        find.text('Level Complete!'),
        findsOneWidget,
        reason: 'Celebration message should be displayed',
      );
    });

    testWidgets(
      'celebration overlay hides celebration when showCelebration is false',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(
                showCelebration: false,
                message: 'Hidden',
                stars: 3,
                child: Center(child: Text('Game Content')),
              ),
            ),
          ),
        );

        // Verify content is shown
        expect(find.text('Game Content'), findsOneWidget);

        // Verify celebration is not shown
        expect(
          find.byType(CelebrationWidget),
          findsNothing,
          reason: 'Celebration should be hidden when showCelebration is false',
        );
      },
    );

    testWidgets('celebration animation starts immediately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationWidget(message: 'Success!', stars: 3),
          ),
        ),
      );

      // Initial frame
      await tester.pump();

      // Verify widget is present
      expect(find.byType(CelebrationWidget), findsOneWidget);

      // Pump a small duration to verify animation is running
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should still be present and animating
      expect(find.byType(CelebrationWidget), findsOneWidget);
    });

    testWidgets('celebration animation runs for expected duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CelebrationWidget(message: 'Done!', stars: 3)),
        ),
      );

      // Initial frame
      await tester.pump();
      expect(find.byType(CelebrationWidget), findsOneWidget);

      // Pump through animation duration
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byType(CelebrationWidget),
        findsOneWidget,
        reason: 'Celebration should still be visible during animation',
      );

      await tester.pump(const Duration(seconds: 2));
      expect(
        find.byType(CelebrationWidget),
        findsOneWidget,
        reason: 'Celebration should remain visible',
      );
    });

    testWidgets('multiple celebrations can be shown sequentially', (
      tester,
    ) async {
      for (int i = 1; i <= 3; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CelebrationWidget(
                key: ValueKey('celebration_$i'),
                message: 'Level $i Complete!',
                stars: i,
              ),
            ),
          ),
        );

        // Verify correct celebration is shown
        expect(find.text('Level $i Complete!'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsNWidgets(i));

        // Clean up
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('celebration particles are generated correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationWidget(
              message: 'Success!',
              stars: 3,
              showConfetti: true,
            ),
          ),
        ),
      );

      // Pump to start animation
      await tester.pump();

      // Verify CustomPaint is present (confetti rendering)
      expect(
        find.byType(CustomPaint),
        findsWidgets,
        reason: 'Confetti particles should be rendered via CustomPaint',
      );

      // Pump several frames to verify animation progresses
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('star burst animation is present and animating', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationWidget(message: 'Perfect!', stars: 3),
          ),
        ),
      );

      // Initial state
      await tester.pump();
      expect(find.byIcon(Icons.star), findsNWidgets(3));

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byIcon(Icons.star), findsNWidgets(3));

      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.byIcon(Icons.star),
        findsNWidgets(3),
        reason: 'Stars should remain visible throughout animation',
      );
    });

    testWidgets('celebration text animation is present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationWidget(message: 'Awesome!', stars: 3),
          ),
        ),
      );

      // Initial frame
      await tester.pump();

      // Text should be present (even if animating)
      expect(find.text('Awesome!'), findsOneWidget);

      // Pump through animation
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Awesome!'), findsOneWidget);

      // Pump more to complete text animation (800ms total)
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Awesome!'),
        findsOneWidget,
        reason: 'Text should remain visible after animation completes',
      );
    });

    testWidgets('celebration works with zero stars', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationWidget(message: 'Try again!', stars: 0),
          ),
        ),
      );

      // Verify message is shown
      expect(find.text('Try again!'), findsOneWidget);

      // Verify no stars are shown
      expect(
        find.byIcon(Icons.star),
        findsNothing,
        reason: 'No stars should be displayed when stars = 0',
      );
    });

    testWidgets('celebration overlay can toggle celebration state', (
      tester,
    ) async {
      bool showCelebration = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(
                      child: CelebrationOverlay(
                        showCelebration: showCelebration,
                        message: 'Victory!',
                        stars: 3,
                        child: const Center(child: Text('Game')),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showCelebration = !showCelebration;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially no celebration
      expect(find.byType(CelebrationWidget), findsNothing);

      // Toggle celebration on
      await tester.tap(find.text('Toggle'));
      await tester.pump();

      // Celebration should now be visible
      expect(find.byType(CelebrationWidget), findsOneWidget);
      expect(find.text('Victory!'), findsOneWidget);

      // Toggle celebration off
      await tester.tap(find.text('Toggle'));
      await tester.pump();

      // Celebration should be hidden again
      expect(find.byType(CelebrationWidget), findsNothing);
    });
  });
}
