import 'package:equatable/equatable.dart';

import 'math_level.dart';
import 'math_problem.dart';

/// Enum representing the current state of the game
enum GameStatus { initial, loading, playing, paused, completed, error }

/// Model representing the current state of a math game session
class MathGameState extends Equatable {
  final GameStatus status;
  final MathLevel? level;
  final List<MathProblem> problems;
  final int currentProblemIndex;
  final int correctAnswers;
  final int incorrectAnswers;
  final int timeRemaining; // in seconds, -1 for unlimited
  final DateTime? startTime;
  final String? errorMessage;

  const MathGameState({
    required this.status,
    this.level,
    this.problems = const [],
    this.currentProblemIndex = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.timeRemaining = -1,
    this.startTime,
    this.errorMessage,
  });

  /// Create initial state
  factory MathGameState.initial() {
    return const MathGameState(status: GameStatus.initial);
  }

  /// Create loading state
  factory MathGameState.loading() {
    return const MathGameState(status: GameStatus.loading);
  }

  /// Create error state
  factory MathGameState.error(String message) {
    return MathGameState(status: GameStatus.error, errorMessage: message);
  }

  /// Get current problem
  MathProblem? get currentProblem {
    if (currentProblemIndex >= 0 && currentProblemIndex < problems.length) {
      return problems[currentProblemIndex];
    }
    return null;
  }

  /// Get total questions answered
  int get totalAnswered => correctAnswers + incorrectAnswers;

  /// Get accuracy as a percentage (0.0 to 1.0)
  double get accuracy {
    if (totalAnswered == 0) return 0.0;
    return correctAnswers / totalAnswered;
  }

  /// Check if game is complete
  bool get isComplete {
    return status == GameStatus.completed ||
        (level != null && correctAnswers >= level!.targetScore);
  }

  /// Check if time is running out (less than 10 seconds)
  bool get isTimeRunningOut {
    return timeRemaining > 0 && timeRemaining <= 10;
  }

  /// Check if time has expired
  bool get isTimeExpired {
    return timeRemaining == 0;
  }

  /// Create a copy with modified fields
  MathGameState copyWith({
    GameStatus? status,
    MathLevel? level,
    List<MathProblem>? problems,
    int? currentProblemIndex,
    int? correctAnswers,
    int? incorrectAnswers,
    int? timeRemaining,
    DateTime? startTime,
    String? errorMessage,
  }) {
    return MathGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      problems: problems ?? this.problems,
      currentProblemIndex: currentProblemIndex ?? this.currentProblemIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startTime: startTime ?? this.startTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    level,
    problems,
    currentProblemIndex,
    correctAnswers,
    incorrectAnswers,
    timeRemaining,
    startTime,
    errorMessage,
  ];
}
