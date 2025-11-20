import 'package:equatable/equatable.dart';

/// Enum representing mathematical operations
enum MathOperation {
  addition('+'),
  subtraction('-');

  final String symbol;
  const MathOperation(this.symbol);
}

/// Model representing a math problem with operands, operation, and answer
class MathProblem extends Equatable {
  final String id;
  final int operand1;
  final int operand2;
  final MathOperation operation;
  final int correctAnswer;
  final int difficulty;
  final List<int> options;

  const MathProblem({
    required this.id,
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
    required this.difficulty,
    required this.options,
  });

  /// Get the question string for display
  String getQuestion() {
    return '$operand1 ${operation.symbol} $operand2 = ?';
  }

  /// Check if the provided answer is correct
  bool checkAnswer(int answer) {
    return answer == correctAnswer;
  }

  /// Create a copy with modified fields
  MathProblem copyWith({
    String? id,
    int? operand1,
    int? operand2,
    MathOperation? operation,
    int? correctAnswer,
    int? difficulty,
    List<int>? options,
  }) {
    return MathProblem(
      id: id ?? this.id,
      operand1: operand1 ?? this.operand1,
      operand2: operand2 ?? this.operand2,
      operation: operation ?? this.operation,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficulty: difficulty ?? this.difficulty,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [
    id,
    operand1,
    operand2,
    operation,
    correctAnswer,
    difficulty,
    options,
  ];
}
