import 'package:equatable/equatable.dart';

import 'logic_level.dart';
import 'pattern_problem.dart';

/// Enum representing the current state of the game
enum LogicGameStatus { initial, loading, playing, paused, completed, error }

/// Model representing the current state of a logic game session
class LogicGameState extends Equatable {
  final LogicGameStatus status;
  final LogicLevel? level;
  final List<PatternProblem> patterns;
  final int currentPatternIndex;
  final int correctAnswers;
  final int incorrectAnswers;
  final int hintsUsed;
  final int timeRemaining; // in seconds, -1 for unlimited
  final DateTime? startTime;
  final String? errorMessage;
  final String? currentHint;

  const LogicGameState({
    required this.status,
    this.level,
    this.patterns = const [],
    this.currentPatternIndex = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.hintsUsed = 0,
    this.timeRemaining = -1,
    this.startTime,
    this.errorMessage,
    this.currentHint,
  });

  /// Create initial state
  factory LogicGameState.initial() {
    return const LogicGameState(status: LogicGameStatus.initial);
  }

  /// Create loading state
  factory LogicGameState.loading() {
    return const LogicGameState(status: LogicGameStatus.loading);
  }

  /// Create error state
  factory LogicGameState.error(String message) {
    return LogicGameState(status: LogicGameStatus.error, errorMessage: message);
  }

  /// Get current pattern
  PatternProblem? get currentPattern {
    if (currentPatternIndex >= 0 && currentPatternIndex < patterns.length) {
      return patterns[currentPatternIndex];
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
    return status == LogicGameStatus.completed ||
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

  /// Check if hint is available for current pattern
  bool get canShowHint {
    return currentPattern != null && currentHint == null;
  }

  /// Create a copy with modified fields
  LogicGameState copyWith({
    LogicGameStatus? status,
    LogicLevel? level,
    List<PatternProblem>? patterns,
    int? currentPatternIndex,
    int? correctAnswers,
    int? incorrectAnswers,
    int? hintsUsed,
    int? timeRemaining,
    DateTime? startTime,
    String? errorMessage,
    String? currentHint,
    bool clearHint = false,
  }) {
    return LogicGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      patterns: patterns ?? this.patterns,
      currentPatternIndex: currentPatternIndex ?? this.currentPatternIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startTime: startTime ?? this.startTime,
      errorMessage: errorMessage ?? this.errorMessage,
      currentHint: clearHint ? null : (currentHint ?? this.currentHint),
    );
  }

  @override
  List<Object?> get props => [
    status,
    level,
    patterns,
    currentPatternIndex,
    correctAnswers,
    incorrectAnswers,
    hintsUsed,
    timeRemaining,
    startTime,
    errorMessage,
    currentHint,
  ];
}
