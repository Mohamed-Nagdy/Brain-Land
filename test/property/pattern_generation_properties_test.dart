import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/logic_mountain/models/pattern_problem.dart';
import 'package:brain_land/features/logic_mountain/services/pattern_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pattern Generation Properties', () {
    late PatternGenerator generator;

    setUp(() {
      generator = PatternGenerator();
    });

    // **Feature: brainland-game, Property 9: Pattern difficulty increases with level**
    test('pattern difficulty increases with level', () {
      // Test across all difficulty levels
      for (
        int difficulty = AppConstants.minDifficulty;
        difficulty <= AppConstants.maxDifficulty;
        difficulty++
      ) {
        // Generate multiple patterns for each difficulty
        for (int i = 0; i < 10; i++) {
          final pattern = generator.generate(difficulty: difficulty);

          // Verify the pattern's difficulty matches what was requested
          expect(
            pattern.difficulty,
            equals(difficulty),
            reason: 'Generated pattern should have difficulty $difficulty',
          );

          // Verify sequence length increases with difficulty
          final expectedMinLength = difficulty <= 3
              ? 4
              : (difficulty <= 6 ? 6 : 8);
          expect(
            pattern.sequence.length,
            greaterThanOrEqualTo(expectedMinLength),
            reason:
                'Pattern sequence length should be at least $expectedMinLength for difficulty $difficulty',
          );
        }
      }
    });

    test('pattern complexity increases monotonically across iterations', () {
      // Run 100 iterations to ensure consistency
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate patterns at different difficulty levels
        final lowDifficulty = Random().nextInt(3) + 1; // 1-3
        final highDifficulty = Random().nextInt(3) + 7; // 7-9

        final lowPattern = generator.generate(difficulty: lowDifficulty);
        final highPattern = generator.generate(difficulty: highDifficulty);

        // Higher difficulty should have longer or equal sequences
        expect(
          highPattern.sequence.length,
          greaterThanOrEqualTo(lowPattern.sequence.length),
          reason: 'Higher difficulty patterns should have longer sequences',
        );

        // Verify difficulty values
        expect(
          highPattern.difficulty,
          greaterThan(lowPattern.difficulty),
          reason: 'High difficulty should be greater than low difficulty',
        );
      }
    });

    test('pattern difficulty matches requested difficulty', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;

        final pattern = generator.generate(difficulty: difficulty);

        expect(
          pattern.difficulty,
          equals(difficulty),
          reason: 'Pattern difficulty should match requested difficulty',
        );
      }
    });

    test('sequence length correlates with difficulty', () {
      final difficulties = <int, List<int>>{};

      // Collect sequence lengths for each difficulty
      for (int difficulty = 1; difficulty <= 10; difficulty++) {
        difficulties[difficulty] = [];
        for (int i = 0; i < 20; i++) {
          final pattern = generator.generate(difficulty: difficulty);
          difficulties[difficulty]!.add(pattern.sequence.length);
        }
      }

      // Verify that average sequence length increases with difficulty
      for (int difficulty = 1; difficulty < 10; difficulty++) {
        final currentAvg =
            difficulties[difficulty]!.reduce((a, b) => a + b) /
            difficulties[difficulty]!.length;
        final nextAvg =
            difficulties[difficulty + 1]!.reduce((a, b) => a + b) /
            difficulties[difficulty + 1]!.length;

        expect(
          nextAvg,
          greaterThanOrEqualTo(currentAvg),
          reason:
              'Average sequence length should not decrease as difficulty increases',
        );
      }
    });

    test('easy patterns use simple pattern types', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty = Random().nextInt(3) + 1; // 1-3 (easy)
        final pattern = generator.generate(difficulty: difficulty);

        // Easy patterns should be color or shape sequences
        expect(
          [PatternType.colorSequence, PatternType.shapeSequence],
          contains(pattern.type),
          reason: 'Easy difficulty should use color or shape sequences',
        );
      }
    });

    test('hard patterns can use all pattern types', () {
      final typesFound = <PatternType>{};

      // Generate many hard patterns
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty = Random().nextInt(3) + 8; // 8-10 (hard)
        final pattern = generator.generate(difficulty: difficulty);
        typesFound.add(pattern.type);
      }

      // With 100 iterations, we should see variety in pattern types
      expect(
        typesFound.length,
        greaterThanOrEqualTo(2),
        reason: 'Hard difficulty should use multiple pattern types',
      );
    });

    test('generated patterns have valid sequences', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        // Sequence should not be empty
        expect(
          pattern.sequence.isNotEmpty,
          isTrue,
          reason: 'Pattern sequence should not be empty',
        );

        // Sequence should have at least one placeholder (missing element)
        final hasPlaceholder = pattern.sequence.any(
          (element) =>
              element.color == null &&
              element.shape == null &&
              element.number == null &&
              element.size == null,
        );

        expect(
          hasPlaceholder,
          isTrue,
          reason: 'Pattern should have a missing element',
        );
      }
    });

    test('missing index is within sequence bounds', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        expect(
          pattern.missingIndex,
          greaterThanOrEqualTo(0),
          reason: 'Missing index should be non-negative',
        );

        expect(
          pattern.missingIndex,
          lessThan(pattern.sequence.length),
          reason: 'Missing index should be within sequence bounds',
        );
      }
    });

    test('missing index is not the first element', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        expect(
          pattern.missingIndex,
          greaterThan(0),
          reason:
              'Missing index should not be the first element (children need context)',
        );
      }
    });

    test('patterns have exactly 4 answer options', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        expect(
          pattern.options.length,
          equals(4),
          reason: 'Each pattern should have exactly 4 answer options',
        );
      }
    });

    test('answer options include the correct answer', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        expect(
          pattern.options,
          contains(pattern.correctAnswer),
          reason: 'Options must include the correct answer',
        );
      }
    });

    test('answer options are all unique', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        final uniqueOptions = pattern.options.toSet();

        expect(
          uniqueOptions.length,
          equals(4),
          reason: 'All answer options should be unique',
        );
      }
    });

    test('checkAnswer correctly identifies correct answers', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        expect(
          pattern.checkAnswer(pattern.correctAnswer),
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
        final pattern = generator.generate(difficulty: difficulty);

        // Test with wrong answers from the options
        for (final option in pattern.options) {
          if (option != pattern.correctAnswer) {
            expect(
              pattern.checkAnswer(option),
              isFalse,
              reason: 'checkAnswer should return false for incorrect answer',
            );
          }
        }
      }
    });

    test('getCompleteSequence fills in the missing element', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        final completeSequence = pattern.getCompleteSequence();

        // Complete sequence should have same length
        expect(
          completeSequence.length,
          equals(pattern.sequence.length),
          reason: 'Complete sequence should have same length as original',
        );

        // The missing index should now have the correct answer
        expect(
          completeSequence[pattern.missingIndex],
          equals(pattern.correctAnswer),
          reason: 'Missing element should be filled with correct answer',
        );

        // No placeholders should remain
        final hasPlaceholder = completeSequence.any(
          (element) =>
              element.color == null &&
              element.shape == null &&
              element.number == null &&
              element.size == null,
        );

        expect(
          hasPlaceholder,
          isFalse,
          reason: 'Complete sequence should have no placeholders',
        );
      }
    });

    test('getHint returns non-empty string', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final difficulty =
            Random().nextInt(AppConstants.maxDifficulty) +
            AppConstants.minDifficulty;
        final pattern = generator.generate(difficulty: difficulty);

        final hint = pattern.getHint();

        expect(hint.isNotEmpty, isTrue, reason: 'Hint should not be empty');
      }
    });

    test('generateMultiple creates requested number of patterns', () {
      for (int count = 1; count <= 20; count++) {
        final patterns = generator.generateMultiple(
          count: count,
          difficulty: 5,
        );

        expect(
          patterns.length,
          equals(count),
          reason: 'Should generate exactly $count patterns',
        );
      }
    });

    test('generateMultiple creates unique patterns', () {
      final patterns = generator.generateMultiple(count: 50, difficulty: 5);

      // Check that patterns have unique IDs
      final ids = patterns.map((p) => p.id).toSet();
      expect(
        ids.length,
        equals(50),
        reason: 'All generated patterns should have unique IDs',
      );
    });

    test('pattern IDs are unique across generations', () {
      final ids = <String>{};

      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final pattern = generator.generate(difficulty: 5);
        expect(
          ids.contains(pattern.id),
          isFalse,
          reason: 'Pattern IDs should be unique',
        );
        ids.add(pattern.id);
      }
    });

    test('color patterns have valid color elements', () {
      for (int i = 0; i < 50; i++) {
        final pattern = generator.generate(
          difficulty: 3,
          type: PatternType.colorSequence,
        );

        // All non-placeholder elements should have colors
        for (int j = 0; j < pattern.sequence.length; j++) {
          if (j != pattern.missingIndex) {
            expect(
              pattern.sequence[j].color,
              isNotNull,
              reason: 'Color pattern elements should have colors',
            );
          }
        }

        // Correct answer should have a color
        expect(
          pattern.correctAnswer.color,
          isNotNull,
          reason: 'Correct answer should have a color',
        );
      }
    });

    test('shape patterns have valid shape elements', () {
      for (int i = 0; i < 50; i++) {
        final pattern = generator.generate(
          difficulty: 3,
          type: PatternType.shapeSequence,
        );

        // All non-placeholder elements should have shapes
        for (int j = 0; j < pattern.sequence.length; j++) {
          if (j != pattern.missingIndex) {
            expect(
              pattern.sequence[j].shape,
              isNotNull,
              reason: 'Shape pattern elements should have shapes',
            );
          }
        }

        // Correct answer should have a shape
        expect(
          pattern.correctAnswer.shape,
          isNotNull,
          reason: 'Correct answer should have a shape',
        );
      }
    });

    test('number patterns have valid number elements', () {
      for (int i = 0; i < 50; i++) {
        final pattern = generator.generate(
          difficulty: 7,
          type: PatternType.numberSequence,
        );

        // All non-placeholder elements should have numbers
        for (int j = 0; j < pattern.sequence.length; j++) {
          if (j != pattern.missingIndex) {
            expect(
              pattern.sequence[j].number,
              isNotNull,
              reason: 'Number pattern elements should have numbers',
            );
            expect(
              pattern.sequence[j].number,
              greaterThan(0),
              reason: 'Numbers should be positive',
            );
          }
        }

        // Correct answer should have a number
        expect(
          pattern.correctAnswer.number,
          isNotNull,
          reason: 'Correct answer should have a number',
        );
      }
    });

    test('size patterns have valid size elements', () {
      for (int i = 0; i < 50; i++) {
        final pattern = generator.generate(
          difficulty: 5,
          type: PatternType.sizeSequence,
        );

        // All non-placeholder elements should have sizes
        for (int j = 0; j < pattern.sequence.length; j++) {
          if (j != pattern.missingIndex) {
            expect(
              pattern.sequence[j].size,
              isNotNull,
              reason: 'Size pattern elements should have sizes',
            );
            expect(
              pattern.sequence[j].size,
              inInclusiveRange(1, 5),
              reason: 'Sizes should be between 1 and 5',
            );
          }
        }

        // Correct answer should have a size
        expect(
          pattern.correctAnswer.size,
          isNotNull,
          reason: 'Correct answer should have a size',
        );
      }
    });

    test('pattern copyWith creates modified copy', () {
      final original = generator.generate(difficulty: 5);
      final modified = original.copyWith(difficulty: 7);

      expect(modified.difficulty, equals(7));
      expect(modified.id, equals(original.id));
      expect(modified.type, equals(original.type));
      expect(modified.sequence, equals(original.sequence));
    });

    test('patterns with same values are equal', () {
      final element1 = PatternElement(color: PatternColor.red);
      final element2 = PatternElement(color: PatternColor.blue);

      final pattern1 = PatternProblem(
        id: 'test1',
        type: PatternType.colorSequence,
        sequence: [element1, element2, const PatternElement()],
        missingIndex: 2,
        correctAnswer: element1,
        options: [element1, element2, element1, element2],
        difficulty: 3,
      );

      final pattern2 = PatternProblem(
        id: 'test1',
        type: PatternType.colorSequence,
        sequence: [element1, element2, const PatternElement()],
        missingIndex: 2,
        correctAnswer: element1,
        options: [element1, element2, element1, element2],
        difficulty: 3,
      );

      expect(pattern1, equals(pattern2));
    });
  });
}
