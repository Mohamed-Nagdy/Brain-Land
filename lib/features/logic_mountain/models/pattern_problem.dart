import 'package:equatable/equatable.dart';

/// Enum representing different types of patterns
enum PatternType { colorSequence, shapeSequence, numberSequence, sizeSequence }

/// Enum representing pattern elements for color patterns
enum PatternColor { red, blue, green, yellow, purple, orange }

/// Enum representing pattern elements for shape patterns
enum PatternShape { circle, square, triangle, star, heart, diamond }

/// Model representing a single element in a pattern
class PatternElement extends Equatable {
  final PatternColor? color;
  final PatternShape? shape;
  final int? number;
  final int? size; // 1-5 scale

  const PatternElement({this.color, this.shape, this.number, this.size});

  PatternElement copyWith({
    PatternColor? color,
    PatternShape? shape,
    int? number,
    int? size,
  }) {
    return PatternElement(
      color: color ?? this.color,
      shape: shape ?? this.shape,
      number: number ?? this.number,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [color, shape, number, size];
}

/// Model representing a pattern problem with a sequence and missing element
class PatternProblem extends Equatable {
  final String id;
  final PatternType type;
  final List<PatternElement> sequence;
  final int missingIndex;
  final PatternElement correctAnswer;
  final List<PatternElement> options;
  final int difficulty;
  final String? hint;

  const PatternProblem({
    required this.id,
    required this.type,
    required this.sequence,
    required this.missingIndex,
    required this.correctAnswer,
    required this.options,
    required this.difficulty,
    this.hint,
  });

  /// Get the complete sequence with the missing element filled in
  List<PatternElement> getCompleteSequence() {
    final complete = List<PatternElement>.from(sequence);
    complete[missingIndex] = correctAnswer;
    return complete;
  }

  /// Check if the provided answer is correct
  bool checkAnswer(PatternElement answer) {
    return answer == correctAnswer;
  }

  /// Get a hint for the pattern
  String getHint() {
    if (hint != null) return hint!;

    switch (type) {
      case PatternType.colorSequence:
        return 'Look at the colors - do they repeat or change in a pattern?';
      case PatternType.shapeSequence:
        return 'Look at the shapes - what comes next in the pattern?';
      case PatternType.numberSequence:
        return 'Look at the numbers - are they going up, down, or following a rule?';
      case PatternType.sizeSequence:
        return 'Look at the sizes - are they getting bigger or smaller?';
    }
  }

  PatternProblem copyWith({
    String? id,
    PatternType? type,
    List<PatternElement>? sequence,
    int? missingIndex,
    PatternElement? correctAnswer,
    List<PatternElement>? options,
    int? difficulty,
    String? hint,
  }) {
    return PatternProblem(
      id: id ?? this.id,
      type: type ?? this.type,
      sequence: sequence ?? this.sequence,
      missingIndex: missingIndex ?? this.missingIndex,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      difficulty: difficulty ?? this.difficulty,
      hint: hint ?? this.hint,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    sequence,
    missingIndex,
    correctAnswer,
    options,
    difficulty,
    hint,
  ];
}
