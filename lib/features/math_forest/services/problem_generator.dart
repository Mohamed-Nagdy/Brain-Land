import 'dart:math';

import '../../../core/utils/difficulty_calculator.dart';
import '../models/math_problem.dart';

/// Service for generating math problems based on difficulty level
class ProblemGenerator {
  final DifficultyCalculator _difficultyCalculator;
  final Random _random;
  int _idCounter = 0;

  ProblemGenerator({DifficultyCalculator? difficultyCalculator, Random? random})
    : _difficultyCalculator = difficultyCalculator ?? DifficultyCalculator(),
      _random = random ?? Random();

  /// Generate a single math problem for the given difficulty
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// [operation] - Optional specific operation, otherwise random
  /// Returns a MathProblem with appropriate difficulty
  MathProblem generate({required int difficulty, MathOperation? operation}) {
    // Get number range for this difficulty
    final range = _difficultyCalculator.calculateNumberRange(difficulty);

    // Select operation (random if not specified)
    final selectedOperation =
        operation ??
        (difficulty <= 5
            ? MathOperation.addition
            : MathOperation.values[_random.nextInt(2)]);

    // Generate operands within the appropriate range
    final operand1 = _random.nextInt(range.max - range.min + 1) + range.min;
    final operand2 = _random.nextInt(range.max - range.min + 1) + range.min;

    // Calculate correct answer
    final correctAnswer = _calculateAnswer(
      operand1,
      operand2,
      selectedOperation,
    );

    // Generate answer options (3 incorrect + 1 correct)
    final options = _generateOptions(correctAnswer, range.max);

    return MathProblem(
      id: 'problem_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
      operand1: operand1,
      operand2: operand2,
      operation: selectedOperation,
      correctAnswer: correctAnswer,
      difficulty: difficulty,
      options: options,
    );
  }

  /// Generate multiple problems for a level
  ///
  /// [count] - Number of problems to generate
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns a list of MathProblems
  List<MathProblem> generateMultiple({
    required int count,
    required int difficulty,
  }) {
    return List.generate(count, (_) => generate(difficulty: difficulty));
  }

  /// Calculate the answer for a given operation
  int _calculateAnswer(int operand1, int operand2, MathOperation operation) {
    switch (operation) {
      case MathOperation.addition:
        return operand1 + operand2;
      case MathOperation.subtraction:
        // Ensure non-negative results for children
        if (operand1 < operand2) {
          return operand2 - operand1;
        }
        return operand1 - operand2;
    }
  }

  /// Generate 4 answer options including the correct answer
  ///
  /// Creates plausible wrong answers that are close to the correct answer
  List<int> _generateOptions(int correctAnswer, int maxValue) {
    final options = <int>{correctAnswer};

    // Generate 3 plausible wrong answers
    while (options.length < 4) {
      // Generate answers within a reasonable range of the correct answer
      final offset = _random.nextInt(11) - 5; // -5 to +5
      final wrongAnswer = (correctAnswer + offset).clamp(0, maxValue * 2);

      // Avoid negative numbers and duplicates
      if (wrongAnswer >= 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    // Shuffle the options so correct answer isn't always in the same position
    final optionsList = options.toList()..shuffle(_random);
    return optionsList;
  }
}
