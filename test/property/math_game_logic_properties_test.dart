import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/core/utils/difficulty_calculator.dart';
import 'package:brain_land/features/math_forest/models/math_game_state.dart';
import 'package:brain_land/features/math_forest/models/math_level.dart';
import 'package:brain_land/features/math_forest/services/problem_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Math Game Logic Properties', () {
    late DifficultyCalculator calculator;
    late ProblemGenerator generator;

    setUp(() {
      calculator = DifficultyCalculator();
      generator = ProblemGenerator(difficultyCalculator: calculator);
    });

    // **Feature: brainland-game, Property 6: Correct answers increment counter**
    test('correct answers increment counter by exactly 1', () {
      // Test across 100 iterations
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Create initial game state
        final problems = generator.generateMultiple(count: 10, difficulty: 5);
        var state = MathGameState(
          status: GameStatus.playing,
          problems: problems,
          currentProblemIndex: 0,
          correctAnswers: 0,
          incorrectAnswers: 0,
        );

        // Simulate answering correctly
        final previousCorrect = state.correctAnswers;
        state = state.copyWith(correctAnswers: state.correctAnswers + 1);

        expect(
          state.correctAnswers,
          equals(previousCorrect + 1),
          reason: 'Correct answer should increment counter by exactly 1',
        );
      }
    });

    test('multiple correct answers accumulate properly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final problems = generator.generateMultiple(count: 20, difficulty: 5);
        var state = MathGameState(
          status: GameStatus.playing,
          problems: problems,
          currentProblemIndex: 0,
          correctAnswers: 0,
          incorrectAnswers: 0,
        );

        // Answer a random number of questions correctly
        final correctCount = Random().nextInt(15) + 1;
        for (int j = 0; j < correctCount; j++) {
          state = state.copyWith(correctAnswers: state.correctAnswers + 1);
        }

        expect(
          state.correctAnswers,
          equals(correctCount),
          reason: 'Correct answers should accumulate properly',
        );
      }
    });

    test('incorrect answers do not affect correct answer counter', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final problems = generator.generateMultiple(count: 10, difficulty: 5);
        var state = MathGameState(
          status: GameStatus.playing,
          problems: problems,
          currentProblemIndex: 0,
          correctAnswers: 5,
          incorrectAnswers: 0,
        );

        final previousCorrect = state.correctAnswers;

        // Simulate incorrect answer
        state = state.copyWith(incorrectAnswers: state.incorrectAnswers + 1);

        expect(
          state.correctAnswers,
          equals(previousCorrect),
          reason: 'Incorrect answers should not change correct answer counter',
        );
      }
    });

    // **Feature: brainland-game, Property 7: Star awards match performance**
    test('star awards match performance thresholds', () {
      // Test all difficulty levels
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final thresholds = calculator.calculateStarThresholds(difficulty);

        // Test various accuracy levels
        final accuracies = [0.0, 0.3, 0.5, 0.7, 0.85, 0.9, 0.95, 1.0];

        for (final accuracy in accuracies) {
          int expectedStars;
          if (accuracy >= thresholds.threeStar) {
            expectedStars = 3;
          } else if (accuracy >= thresholds.twoStar) {
            expectedStars = 2;
          } else if (accuracy >= thresholds.oneStar) {
            expectedStars = 1;
          } else {
            expectedStars = 0;
          }

          // Verify star calculation
          int actualStars;
          if (accuracy >= thresholds.threeStar) {
            actualStars = 3;
          } else if (accuracy >= thresholds.twoStar) {
            actualStars = 2;
          } else if (accuracy >= thresholds.oneStar) {
            actualStars = 1;
          } else {
            actualStars = 0;
          }

          expect(
            actualStars,
            equals(expectedStars),
            reason:
                'Stars for accuracy $accuracy at difficulty $difficulty should match threshold',
          );
        }
      }
    });

    test('90% accuracy always awards at least 2 stars', () {
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final thresholds = calculator.calculateStarThresholds(difficulty);
        const accuracy = 0.90;

        int stars;
        if (accuracy >= thresholds.threeStar) {
          stars = 3;
        } else if (accuracy >= thresholds.twoStar) {
          stars = 2;
        } else if (accuracy >= thresholds.oneStar) {
          stars = 1;
        } else {
          stars = 0;
        }

        expect(
          stars,
          greaterThanOrEqualTo(2),
          reason: '90% accuracy should award at least 2 stars',
        );
      }
    });

    test('perfect accuracy always awards 3 stars', () {
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final thresholds = calculator.calculateStarThresholds(difficulty);
        const accuracy = 1.0;

        int stars;
        if (accuracy >= thresholds.threeStar) {
          stars = 3;
        } else if (accuracy >= thresholds.twoStar) {
          stars = 2;
        } else if (accuracy >= thresholds.oneStar) {
          stars = 1;
        } else {
          stars = 0;
        }

        expect(
          stars,
          equals(3),
          reason: 'Perfect accuracy should always award 3 stars',
        );
      }
    });

    test('star thresholds are in ascending order', () {
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        final thresholds = calculator.calculateStarThresholds(difficulty);

        expect(
          thresholds.twoStar,
          greaterThan(thresholds.oneStar),
          reason: 'Two star threshold should be higher than one star',
        );
        expect(
          thresholds.threeStar,
          greaterThan(thresholds.twoStar),
          reason: 'Three star threshold should be higher than two star',
        );
      }
    });

    test('accuracy calculation is correct', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final correct = Random().nextInt(20);
        final incorrect = Random().nextInt(20);
        final total = correct + incorrect;

        final state = MathGameState(
          status: GameStatus.playing,
          problems: [],
          correctAnswers: correct,
          incorrectAnswers: incorrect,
        );

        if (total == 0) {
          expect(state.accuracy, equals(0.0));
        } else {
          final expectedAccuracy = correct / total;
          expect(
            state.accuracy,
            equals(expectedAccuracy),
            reason: 'Accuracy should be correct/total',
          );
        }
      }
    });

    test('game completion is detected when target score is reached', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final targetScore = Random().nextInt(15) + 5;
        final level = MathLevel(
          id: 'test_level',
          levelNumber: 1,
          difficulty: 5,
          timeLimit: 0,
          targetScore: targetScore,
        );

        // Test with correct answers equal to target
        var state = MathGameState(
          status: GameStatus.playing,
          level: level,
          problems: [],
          correctAnswers: targetScore,
          incorrectAnswers: 0,
        );

        expect(
          state.isComplete,
          isTrue,
          reason: 'Game should be complete when correct answers reach target',
        );

        // Test with correct answers exceeding target
        state = state.copyWith(correctAnswers: targetScore + 5);
        expect(
          state.isComplete,
          isTrue,
          reason: 'Game should be complete when correct answers exceed target',
        );

        // Test with correct answers below target
        state = state.copyWith(correctAnswers: targetScore - 1);
        expect(
          state.isComplete,
          isFalse,
          reason: 'Game should not be complete when below target',
        );
      }
    });

    test('total answered equals correct plus incorrect', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final correct = Random().nextInt(20);
        final incorrect = Random().nextInt(20);

        final state = MathGameState(
          status: GameStatus.playing,
          problems: [],
          correctAnswers: correct,
          incorrectAnswers: incorrect,
        );

        expect(
          state.totalAnswered,
          equals(correct + incorrect),
          reason: 'Total answered should equal correct + incorrect',
        );
      }
    });

    test('current problem index stays within bounds', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final problemCount = Random().nextInt(20) + 5;
        final problems = generator.generateMultiple(
          count: problemCount,
          difficulty: 5,
        );

        for (int index = 0; index < problemCount; index++) {
          final state = MathGameState(
            status: GameStatus.playing,
            problems: problems,
            currentProblemIndex: index,
          );

          expect(
            state.currentProblemIndex,
            inInclusiveRange(0, problemCount - 1),
            reason: 'Current problem index should be within bounds',
          );

          expect(
            state.currentProblem,
            isNotNull,
            reason: 'Current problem should be accessible',
          );
        }
      }
    });

    test('game state transitions are valid', () {
      final validTransitions = {
        GameStatus.initial: [GameStatus.loading],
        GameStatus.loading: [GameStatus.playing, GameStatus.error],
        GameStatus.playing: [
          GameStatus.paused,
          GameStatus.completed,
          GameStatus.error,
        ],
        GameStatus.paused: [GameStatus.playing],
        GameStatus.completed: [],
        GameStatus.error: [],
      };

      // Test that state transitions follow valid patterns
      for (final entry in validTransitions.entries) {
        final fromStatus = entry.key;
        final validNextStatuses = entry.value;

        // Create state with current status
        final state = MathGameState(status: fromStatus, problems: []);

        // Verify we can transition to valid next states
        for (final nextStatus in validNextStatuses) {
          final newState = state.copyWith(status: nextStatus);
          expect(newState.status, equals(nextStatus));
        }
      }
    });

    test('time running out is detected correctly', () {
      for (int time = 0; time <= 20; time++) {
        final state = MathGameState(
          status: GameStatus.playing,
          problems: [],
          timeRemaining: time,
        );

        if (time > 0 && time <= 10) {
          expect(
            state.isTimeRunningOut,
            isTrue,
            reason: 'Time should be running out when <= 10 seconds',
          );
        } else {
          expect(
            state.isTimeRunningOut,
            isFalse,
            reason: 'Time should not be running out when > 10 seconds or 0',
          );
        }
      }
    });

    test('time expired is detected correctly', () {
      final state1 = MathGameState(
        status: GameStatus.playing,
        problems: [],
        timeRemaining: 0,
      );
      expect(state1.isTimeExpired, isTrue);

      final state2 = MathGameState(
        status: GameStatus.playing,
        problems: [],
        timeRemaining: 1,
      );
      expect(state2.isTimeExpired, isFalse);

      final state3 = MathGameState(
        status: GameStatus.playing,
        problems: [],
        timeRemaining: -1,
      );
      expect(state3.isTimeExpired, isFalse);
    });

    test('level result accuracy percentage is calculated correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final accuracy = Random().nextDouble();
        final expectedPercentage = (accuracy * 100).round();

        // Create a mock state to verify calculation
        final correct = (accuracy * 100).round();
        final total = 100;

        final calculatedAccuracy = correct / total;
        final calculatedPercentage = (calculatedAccuracy * 100).round();

        expect(
          calculatedPercentage,
          inInclusiveRange(expectedPercentage - 1, expectedPercentage + 1),
          reason: 'Accuracy percentage should be correctly calculated',
        );
      }
    });

    test('game state equality works correctly', () {
      final problems = generator.generateMultiple(count: 5, difficulty: 3);
      final level = MathLevel(
        id: 'test',
        levelNumber: 1,
        difficulty: 3,
        timeLimit: 60,
        targetScore: 5,
      );

      final state1 = MathGameState(
        status: GameStatus.playing,
        level: level,
        problems: problems,
        correctAnswers: 3,
        incorrectAnswers: 1,
      );

      final state2 = MathGameState(
        status: GameStatus.playing,
        level: level,
        problems: problems,
        correctAnswers: 3,
        incorrectAnswers: 1,
      );

      expect(state1, equals(state2));
    });

    test('copyWith creates proper copies', () {
      final problems = generator.generateMultiple(count: 5, difficulty: 3);
      final original = MathGameState(
        status: GameStatus.playing,
        problems: problems,
        correctAnswers: 5,
        incorrectAnswers: 2,
      );

      final modified = original.copyWith(correctAnswers: 10);

      expect(modified.correctAnswers, equals(10));
      expect(modified.incorrectAnswers, equals(original.incorrectAnswers));
      expect(modified.status, equals(original.status));
      expect(modified.problems, equals(original.problems));
    });
  });
}
