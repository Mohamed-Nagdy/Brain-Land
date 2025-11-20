import 'dart:math';

import '../models/pattern_problem.dart';

/// Service for generating pattern problems based on difficulty level
class PatternGenerator {
  final Random _random;
  int _idCounter = 0;

  PatternGenerator({Random? random}) : _random = random ?? Random();

  /// Generate a single pattern problem for the given difficulty
  ///
  /// [difficulty] - The difficulty rating (1-10)
  /// [type] - Optional specific pattern type, otherwise random
  /// Returns a PatternProblem with appropriate difficulty
  PatternProblem generate({required int difficulty, PatternType? type}) {
    // Select pattern type (random if not specified)
    final selectedType = type ?? _selectPatternTypeForDifficulty(difficulty);

    // Generate pattern based on type and difficulty
    switch (selectedType) {
      case PatternType.colorSequence:
        return _generateColorPattern(difficulty);
      case PatternType.shapeSequence:
        return _generateShapePattern(difficulty);
      case PatternType.numberSequence:
        return _generateNumberPattern(difficulty);
      case PatternType.sizeSequence:
        return _generateSizePattern(difficulty);
    }
  }

  /// Generate multiple problems for a level
  ///
  /// [count] - Number of problems to generate
  /// [difficulty] - The difficulty rating (1-10)
  /// Returns a list of PatternProblems
  List<PatternProblem> generateMultiple({
    required int count,
    required int difficulty,
  }) {
    return List.generate(count, (_) => generate(difficulty: difficulty));
  }

  /// Select appropriate pattern type based on difficulty
  PatternType _selectPatternTypeForDifficulty(int difficulty) {
    if (difficulty <= 3) {
      // Easy: color and shape patterns
      return _random.nextBool()
          ? PatternType.colorSequence
          : PatternType.shapeSequence;
    } else if (difficulty <= 6) {
      // Medium: add size patterns
      final types = [
        PatternType.colorSequence,
        PatternType.shapeSequence,
        PatternType.sizeSequence,
      ];
      return types[_random.nextInt(types.length)];
    } else {
      // Hard: all types including number sequences
      return PatternType.values[_random.nextInt(PatternType.values.length)];
    }
  }

  /// Generate a color sequence pattern
  PatternProblem _generateColorPattern(int difficulty) {
    final sequenceLength = _calculateSequenceLength(difficulty);
    final patternLength = difficulty <= 3 ? 2 : (difficulty <= 6 ? 3 : 4);

    // Create a repeating color pattern
    final basePattern = List.generate(
      patternLength,
      (_) => PatternColor.values[_random.nextInt(PatternColor.values.length)],
    );

    // Build the full sequence by repeating the pattern
    final sequence = <PatternElement>[];
    for (int i = 0; i < sequenceLength; i++) {
      sequence.add(PatternElement(color: basePattern[i % patternLength]));
    }

    // Select a random position for the missing element (not the first one)
    final missingIndex = _random.nextInt(sequenceLength - 1) + 1;
    final correctAnswer = sequence[missingIndex];

    // Replace with placeholder
    sequence[missingIndex] = const PatternElement();

    // Generate options
    final options = _generateColorOptions(correctAnswer, difficulty);

    return PatternProblem(
      id: 'pattern_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
      type: PatternType.colorSequence,
      sequence: sequence,
      missingIndex: missingIndex,
      correctAnswer: correctAnswer,
      options: options,
      difficulty: difficulty,
    );
  }

  /// Generate a shape sequence pattern
  PatternProblem _generateShapePattern(int difficulty) {
    final sequenceLength = _calculateSequenceLength(difficulty);
    final patternLength = difficulty <= 3 ? 2 : (difficulty <= 6 ? 3 : 4);

    // Create a repeating shape pattern
    final basePattern = List.generate(
      patternLength,
      (_) => PatternShape.values[_random.nextInt(PatternShape.values.length)],
    );

    // Build the full sequence by repeating the pattern
    final sequence = <PatternElement>[];
    for (int i = 0; i < sequenceLength; i++) {
      sequence.add(PatternElement(shape: basePattern[i % patternLength]));
    }

    // Select a random position for the missing element (not the first one)
    final missingIndex = _random.nextInt(sequenceLength - 1) + 1;
    final correctAnswer = sequence[missingIndex];

    // Replace with placeholder
    sequence[missingIndex] = const PatternElement();

    // Generate options
    final options = _generateShapeOptions(correctAnswer, difficulty);

    return PatternProblem(
      id: 'pattern_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
      type: PatternType.shapeSequence,
      sequence: sequence,
      missingIndex: missingIndex,
      correctAnswer: correctAnswer,
      options: options,
      difficulty: difficulty,
    );
  }

  /// Generate a number sequence pattern
  PatternProblem _generateNumberPattern(int difficulty) {
    final sequenceLength = _calculateSequenceLength(difficulty);

    // Determine the pattern rule based on difficulty
    final startNumber = _random.nextInt(10) + 1;
    final step = difficulty <= 5
        ? _random.nextInt(3) + 1
        : _random.nextInt(5) + 1;

    // Build the sequence
    final sequence = <PatternElement>[];
    for (int i = 0; i < sequenceLength; i++) {
      sequence.add(PatternElement(number: startNumber + (i * step)));
    }

    // Select a random position for the missing element (not the first one)
    final missingIndex = _random.nextInt(sequenceLength - 1) + 1;
    final correctAnswer = sequence[missingIndex];

    // Replace with placeholder
    sequence[missingIndex] = const PatternElement();

    // Generate options
    final options = _generateNumberOptions(correctAnswer, step, difficulty);

    return PatternProblem(
      id: 'pattern_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
      type: PatternType.numberSequence,
      sequence: sequence,
      missingIndex: missingIndex,
      correctAnswer: correctAnswer,
      options: options,
      difficulty: difficulty,
    );
  }

  /// Generate a size sequence pattern
  PatternProblem _generateSizePattern(int difficulty) {
    final sequenceLength = _calculateSequenceLength(difficulty);
    final patternLength = difficulty <= 3 ? 2 : 3;

    // Create a repeating size pattern (1-5 scale)
    final basePattern = List.generate(
      patternLength,
      (_) => _random.nextInt(5) + 1,
    );

    // Build the full sequence by repeating the pattern
    final sequence = <PatternElement>[];
    for (int i = 0; i < sequenceLength; i++) {
      sequence.add(
        PatternElement(
          size: basePattern[i % patternLength],
          shape: PatternShape.circle, // Use same shape for size comparison
        ),
      );
    }

    // Select a random position for the missing element (not the first one)
    final missingIndex = _random.nextInt(sequenceLength - 1) + 1;
    final correctAnswer = sequence[missingIndex];

    // Replace with placeholder
    sequence[missingIndex] = const PatternElement();

    // Generate options
    final options = _generateSizeOptions(correctAnswer, difficulty);

    return PatternProblem(
      id: 'pattern_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
      type: PatternType.sizeSequence,
      sequence: sequence,
      missingIndex: missingIndex,
      correctAnswer: correctAnswer,
      options: options,
      difficulty: difficulty,
    );
  }

  /// Calculate sequence length based on difficulty
  int _calculateSequenceLength(int difficulty) {
    if (difficulty <= 3) return 4;
    if (difficulty <= 6) return 6;
    return 8;
  }

  /// Generate color options including the correct answer
  List<PatternElement> _generateColorOptions(
    PatternElement correctAnswer,
    int difficulty,
  ) {
    final options = <PatternElement>{correctAnswer};

    // Generate 3 wrong answers
    while (options.length < 4) {
      final wrongColor =
          PatternColor.values[_random.nextInt(PatternColor.values.length)];
      final wrongAnswer = PatternElement(color: wrongColor);

      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    // Shuffle the options
    final optionsList = options.toList()..shuffle(_random);
    return optionsList;
  }

  /// Generate shape options including the correct answer
  List<PatternElement> _generateShapeOptions(
    PatternElement correctAnswer,
    int difficulty,
  ) {
    final options = <PatternElement>{correctAnswer};

    // Generate 3 wrong answers
    while (options.length < 4) {
      final wrongShape =
          PatternShape.values[_random.nextInt(PatternShape.values.length)];
      final wrongAnswer = PatternElement(shape: wrongShape);

      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    // Shuffle the options
    final optionsList = options.toList()..shuffle(_random);
    return optionsList;
  }

  /// Generate number options including the correct answer
  List<PatternElement> _generateNumberOptions(
    PatternElement correctAnswer,
    int step,
    int difficulty,
  ) {
    final options = <PatternElement>{correctAnswer};
    final correctNumber = correctAnswer.number!;

    // Generate 3 plausible wrong answers
    while (options.length < 4) {
      // Generate numbers close to the correct answer
      final offset = (_random.nextInt(5) - 2) * step; // -2 to +2 steps
      final wrongNumber = (correctNumber + offset).clamp(1, 100);

      final wrongAnswer = PatternElement(number: wrongNumber);

      if (!options.contains(wrongAnswer) && wrongNumber != correctNumber) {
        options.add(wrongAnswer);
      }
    }

    // Shuffle the options
    final optionsList = options.toList()..shuffle(_random);
    return optionsList;
  }

  /// Generate size options including the correct answer
  List<PatternElement> _generateSizeOptions(
    PatternElement correctAnswer,
    int difficulty,
  ) {
    final options = <PatternElement>{correctAnswer};

    // Generate 3 wrong answers with different sizes
    while (options.length < 4) {
      final wrongSize = _random.nextInt(5) + 1;
      final wrongAnswer = PatternElement(
        size: wrongSize,
        shape: PatternShape.circle,
      );

      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    // Shuffle the options
    final optionsList = options.toList()..shuffle(_random);
    return optionsList;
  }
}
