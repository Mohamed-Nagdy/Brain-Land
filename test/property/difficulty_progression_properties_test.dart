import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/core/utils/difficulty_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Difficulty Progression Properties', () {
    late DifficultyCalculator calculator;

    setUp(() {
      calculator = DifficultyCalculator();
    });

    // **Feature: brainland-game, Property 36: Difficulty increases monotonically**
    test('difficulty increases monotonically through levels', () {
      // Test across all levels in a zone
      for (
        int startLevel = 1;
        startLevel < AppConstants.levelsPerZone;
        startLevel++
      ) {
        final currentDifficulty = calculator.calculateDifficulty(startLevel);
        final nextDifficulty = calculator.calculateDifficulty(startLevel + 1);

        expect(
          nextDifficulty,
          greaterThanOrEqualTo(currentDifficulty),
          reason:
              'Difficulty at level ${startLevel + 1} ($nextDifficulty) '
              'should be >= difficulty at level $startLevel ($currentDifficulty)',
        );
      }
    });

    test('difficulty never decreases across sequential levels', () {
      // Run 100 iterations testing random level sequences
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulties = <int>[];

        // Calculate difficulties for all levels
        for (int level = 1; level <= AppConstants.levelsPerZone; level++) {
          difficulties.add(calculator.calculateDifficulty(level));
        }

        // Verify monotonic increase
        for (int j = 1; j < difficulties.length; j++) {
          expect(
            difficulties[j],
            greaterThanOrEqualTo(difficulties[j - 1]),
            reason:
                'Difficulty should never decrease between consecutive levels',
          );
        }
      }
    });

    // **Feature: brainland-game, Property 37: Higher difficulty reduces time limit**
    test('higher difficulty reduces or maintains time limit', () {
      // Test all difficulty levels
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty < AppConstants.maxDifficulty;
        difficulty++
      ) {
        final currentTimeLimit = calculator.calculateTimeLimit(difficulty);
        final nextTimeLimit = calculator.calculateTimeLimit(difficulty + 1);

        // Time limit should decrease or stay the same (0 = unlimited is treated specially)
        if (currentTimeLimit == AppConstants.unlimitedTime) {
          // If current is unlimited, next can be anything
          expect(nextTimeLimit, greaterThanOrEqualTo(0));
        } else if (nextTimeLimit == AppConstants.unlimitedTime) {
          // Next should not become unlimited if current is limited
          fail(
            'Time limit should not increase to unlimited at higher difficulty',
          );
        } else {
          // Both are limited, next should be <= current
          expect(
            nextTimeLimit,
            lessThanOrEqualTo(currentTimeLimit),
            reason:
                'Time limit at difficulty ${difficulty + 1} ($nextTimeLimit) '
                'should be <= time limit at difficulty $difficulty ($currentTimeLimit)',
          );
        }
      }
    });

    test('time limits follow expected progression pattern', () {
      final timeLimits = <int>[];

      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        timeLimits.add(calculator.calculateTimeLimit(difficulty));
      }

      // Verify the pattern: unlimited -> easy -> medium -> hard
      // Early difficulties should have unlimited time
      expect(timeLimits[0], equals(AppConstants.unlimitedTime));
      expect(timeLimits[1], equals(AppConstants.unlimitedTime));
      expect(timeLimits[2], equals(AppConstants.unlimitedTime));

      // Later difficulties should have progressively shorter times
      final limitedTimes = timeLimits.where((t) => t > 0).toList();
      for (int i = 1; i < limitedTimes.length; i++) {
        expect(
          limitedTimes[i],
          lessThanOrEqualTo(limitedTimes[i - 1]),
          reason:
              'Limited time should decrease or stay same as difficulty increases',
        );
      }
    });

    // **Feature: brainland-game, Property 38: Early levels have unlimited time**
    test('early levels have unlimited time', () {
      // Test first 3 levels across multiple iterations
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        for (int level = 1; level <= 3; level++) {
          final difficulty = calculator.calculateDifficulty(level);
          final timeLimit = calculator.calculateTimeLimit(difficulty);

          expect(
            timeLimit,
            equals(AppConstants.unlimitedTime),
            reason:
                'Level $level (difficulty $difficulty) should have unlimited time',
          );
        }
      }
    });

    test('hasUnlimitedTime returns true for early levels', () {
      for (int level = 1; level <= 3; level++) {
        expect(
          calculator.hasUnlimitedTime(level),
          isTrue,
          reason: 'Level $level should have unlimited time',
        );
      }
    });

    test('difficulty stays within defined bounds', () {
      for (int level = 1; level <= AppConstants.levelsPerZone; level++) {
        final difficulty = calculator.calculateDifficulty(level);

        expect(
          difficulty,
          greaterThanOrEqualTo(AppConstants.minDifficulty),
          reason: 'Difficulty should be >= minimum',
        );
        expect(
          difficulty,
          lessThanOrEqualTo(AppConstants.maxDifficulty),
          reason: 'Difficulty should be <= maximum',
        );
      }
    });

    test('number range increases with difficulty', () {
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty < AppConstants.maxDifficulty;
        difficulty++
      ) {
        final currentRange = calculator.calculateNumberRange(difficulty);
        final nextRange = calculator.calculateNumberRange(difficulty + 1);

        expect(
          nextRange.max,
          greaterThanOrEqualTo(currentRange.max),
          reason: 'Number range should increase or stay same with difficulty',
        );
      }
    });

    test('beginner difficulty uses correct number range', () {
      // Difficulty 1-2 should use beginner range (0-10)
      for (int difficulty = 1; difficulty <= 2; difficulty++) {
        final range = calculator.calculateNumberRange(difficulty);

        expect(range.min, equals(0));
        expect(range.max, equals(AppConstants.beginnerMaxNumber));
      }
    });

    test('target score increases with difficulty', () {
      int previousScore = 0;

      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final score = calculator.calculateTargetScore(difficulty);

        expect(
          score,
          greaterThanOrEqualTo(previousScore),
          reason: 'Target score should increase with difficulty',
        );

        previousScore = score;
      }
    });

    test('star thresholds are valid percentages', () {
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final thresholds = calculator.calculateStarThresholds(difficulty);

        // All thresholds should be between 0 and 1
        expect(thresholds.oneStar, inInclusiveRange(0.0, 1.0));
        expect(thresholds.twoStar, inInclusiveRange(0.0, 1.0));
        expect(thresholds.threeStar, inInclusiveRange(0.0, 1.0));

        // Thresholds should be in ascending order
        expect(thresholds.twoStar, greaterThan(thresholds.oneStar));
        expect(thresholds.threeStar, greaterThan(thresholds.twoStar));
      }
    });

    test('difficulty description is never empty', () {
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final description = calculator.getDifficultyDescription(difficulty);

        expect(description, isNotEmpty);
        expect(description.length, greaterThan(0));
      }
    });

    test('zero or negative level numbers are handled gracefully', () {
      expect(
        calculator.calculateDifficulty(0),
        equals(AppConstants.minDifficulty),
      );
      expect(
        calculator.calculateDifficulty(-1),
        equals(AppConstants.minDifficulty),
      );
      expect(
        calculator.calculateDifficulty(-100),
        equals(AppConstants.minDifficulty),
      );
    });
  });
}
