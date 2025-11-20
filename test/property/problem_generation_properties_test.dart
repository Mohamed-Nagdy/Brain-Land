import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/core/utils/difficulty_calculator.dart';
import 'package:brain_land/features/math_forest/models/math_problem.dart';
import 'package:brain_land/features/math_forest/services/problem_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Problem Generation Properties', () {
    late ProblemGenerator generator;
    late DifficultyCalculator calculator;

    setUp(() {
      calculator = DifficultyCalculator();
      generator = ProblemGenerator(difficultyCalculator: calculator);
    });

    // **Feature: brainland-game, Property 4: Problem difficulty matches level difficulty**
    test('problem difficulty matches level difficulty', () {
      // Test across all difficulty levels
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        // Generate multiple problems for each difficulty
        for (int i = 0; i < 10; i++) {
          final problem = generator.generate(difficulty: difficulty);

          // Verify the problem's difficulty matches what was requested
          expect(
            problem.difficulty,
            equals(difficulty),
            reason: 'Generated problem should have difficulty $difficulty',
          );

          // Verify operands are within the expected range for this difficulty
          final range = calculator.calculateNumberRange(difficulty);
          expect(
            problem.operand1,
            inInclusiveRange(range.min, range.max),
            reason:
                'Operand1 should be within range ${range.min}-${range.max} for difficulty $difficulty',
          );
          expect(
            problem.operand2,
            inInclusiveRange(range.min, range.max),
            reason:
                'Operand2 should be within range ${range.min}-${range.max} for difficulty $difficulty',
          );
        }
      }
    });

    test('problem difficulty matches across multiple iterations', () {
      // Run 100 iterations to ensure consistency
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test a random difficulty level
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;

        final problem = generator.generate(difficulty: difficulty);

        expect(
          problem.difficulty,
          equals(difficulty),
          reason: 'Problem difficulty should match requested difficulty',
        );
      }
    });

    // **Feature: brainland-game, Property 8: Beginner problems use correct number range**
    test('beginner problems use numbers 0-10', () {
      // Test beginner difficulty (1-2) across 100 iterations
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Test both difficulty 1 and 2 (beginner levels)
        final difficulty = Random().nextInt(2) + 1; // 1 or 2

        final problem = generator.generate(difficulty: difficulty);

        expect(
          problem.operand1,
          inInclusiveRange(0, AppConstants.beginnerMaxNumber),
          reason:
              'Beginner problem operand1 should be between 0 and ${AppConstants.beginnerMaxNumber}',
        );
        expect(
          problem.operand2,
          inInclusiveRange(0, AppConstants.beginnerMaxNumber),
          reason:
              'Beginner problem operand2 should be between 0 and ${AppConstants.beginnerMaxNumber}',
        );
      }
    });

    test('beginner addition problems have correct answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final problem = generator.generate(
          difficulty: 1,
          operation: MathOperation.addition,
        );

        final expectedAnswer = problem.operand1 + problem.operand2;

        expect(
          problem.correctAnswer,
          equals(expectedAnswer),
          reason:
              '${problem.operand1} + ${problem.operand2} should equal $expectedAnswer',
        );
      }
    });

    test('beginner subtraction problems have non-negative answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final problem = generator.generate(
          difficulty: 1,
          operation: MathOperation.subtraction,
        );

        expect(
          problem.correctAnswer,
          greaterThanOrEqualTo(0),
          reason: 'Subtraction answers should be non-negative for children',
        );
      }
    });

    test('generated problems have valid question strings', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        final question = problem.getQuestion();

        // Question should contain operands and operation symbol
        expect(question, contains(problem.operand1.toString()));
        expect(question, contains(problem.operand2.toString()));
        expect(question, contains(problem.operation.symbol));
        expect(question, contains('='));
        expect(question, contains('?'));
      }
    });

    test('generated problems have exactly 4 answer options', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        expect(
          problem.options.length,
          equals(4),
          reason: 'Each problem should have exactly 4 answer options',
        );
      }
    });

    test('answer options include the correct answer', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        expect(
          problem.options,
          contains(problem.correctAnswer),
          reason: 'Options must include the correct answer',
        );
      }
    });

    test('answer options are all unique', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        final uniqueOptions = problem.options.toSet();

        expect(
          uniqueOptions.length,
          equals(4),
          reason: 'All answer options should be unique',
        );
      }
    });

    test('answer options are all non-negative', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        for (final option in problem.options) {
          expect(
            option,
            greaterThanOrEqualTo(0),
            reason: 'All answer options should be non-negative',
          );
        }
      }
    });

    test('checkAnswer correctly identifies correct answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        expect(
          problem.checkAnswer(problem.correctAnswer),
          isTrue,
          reason: 'checkAnswer should return true for correct answer',
        );
      }
    });

    test('checkAnswer correctly identifies incorrect answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(difficulty: difficulty);

        // Test with wrong answers from the options
        for (final option in problem.options) {
          if (option != problem.correctAnswer) {
            expect(
              problem.checkAnswer(option),
              isFalse,
              reason: 'checkAnswer should return false for incorrect answer',
            );
          }
        }
      }
    });

    test('generateMultiple creates requested number of problems', () {
      for (int count = 1; count <= 20; count++) {
        final problems = generator.generateMultiple(
          count: count,
          difficulty: 5,
        );

        expect(
          problems.length,
          equals(count),
          reason: 'Should generate exactly $count problems',
        );
      }
    });

    test('generateMultiple creates unique problems', () {
      final problems = generator.generateMultiple(count: 50, difficulty: 5);

      // Check that problems have unique IDs
      final ids = problems.map((p) => p.id).toSet();
      expect(
        ids.length,
        equals(50),
        reason: 'All generated problems should have unique IDs',
      );
    });

    test('addition problems calculate correct answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(
          difficulty: difficulty,
          operation: MathOperation.addition,
        );

        final expectedAnswer = problem.operand1 + problem.operand2;

        expect(
          problem.correctAnswer,
          equals(expectedAnswer),
          reason:
              'Addition: ${problem.operand1} + ${problem.operand2} should equal $expectedAnswer',
        );
      }
    });

    test('subtraction problems calculate correct answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final problem = generator.generate(
          difficulty: difficulty,
          operation: MathOperation.subtraction,
        );

        // Verify the answer is correct based on the operands
        final expectedAnswer = problem.operand1 >= problem.operand2
            ? problem.operand1 - problem.operand2
            : problem.operand2 - problem.operand1;

        expect(
          problem.correctAnswer,
          equals(expectedAnswer),
          reason: 'Subtraction answer should be correct and non-negative',
        );
      }
    });

    test('problem IDs are unique across generations', () {
      final ids = <String>{};

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final problem = generator.generate(difficulty: 5);
        expect(
          ids.contains(problem.id),
          isFalse,
          reason: 'Problem IDs should be unique',
        );
        ids.add(problem.id);
      }
    });

    test('higher difficulty uses larger number ranges', () {
      final lowDifficultyProblems = generator.generateMultiple(
        count: 20,
        difficulty: 2,
      );
      final highDifficultyProblems = generator.generateMultiple(
        count: 20,
        difficulty: 9,
      );

      // Calculate average operand values
      final lowAvg =
          lowDifficultyProblems
              .map((p) => p.operand1 + p.operand2)
              .reduce((a, b) => a + b) /
          (lowDifficultyProblems.length * 2);

      final highAvg =
          highDifficultyProblems
              .map((p) => p.operand1 + p.operand2)
              .reduce((a, b) => a + b) /
          (highDifficultyProblems.length * 2);

      expect(
        highAvg,
        greaterThan(lowAvg),
        reason: 'Higher difficulty should use larger numbers on average',
      );
    });

    test('problem copyWith creates modified copy', () {
      final original = generator.generate(difficulty: 5);
      final modified = original.copyWith(difficulty: 7);

      expect(modified.difficulty, equals(7));
      expect(modified.id, equals(original.id));
      expect(modified.operand1, equals(original.operand1));
      expect(modified.operand2, equals(original.operand2));
    });

    test('problems with same values are equal', () {
      final problem1 = MathProblem(
        id: 'test1',
        operand1: 5,
        operand2: 3,
        operation: MathOperation.addition,
        correctAnswer: 8,
        difficulty: 1,
        options: [6, 7, 8, 9],
      );

      final problem2 = MathProblem(
        id: 'test1',
        operand1: 5,
        operand2: 3,
        operation: MathOperation.addition,
        correctAnswer: 8,
        difficulty: 1,
        options: [6, 7, 8, 9],
      );

      expect(problem1, equals(problem2));
    });
  });
}
