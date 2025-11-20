import 'package:equatable/equatable.dart';

/// Model representing the result of completing a level
class LevelResult extends Equatable {
  final String levelId;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent; // in seconds
  final int starsEarned;
  final double accuracy; // 0.0 to 1.0
  final DateTime completedAt;

  const LevelResult({
    required this.levelId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.starsEarned,
    required this.accuracy,
    required this.completedAt,
  });

  /// Calculate accuracy percentage (0-100)
  int get accuracyPercentage => (accuracy * 100).round();

  /// Check if level was passed (at least 1 star)
  bool get isPassed => starsEarned > 0;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'starsEarned': starsEarned,
      'accuracy': accuracy,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LevelResult.fromJson(Map<String, dynamic> json) {
    return LevelResult(
      levelId: json['levelId'] as String,
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      timeSpent: json['timeSpent'] as int,
      starsEarned: json['starsEarned'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    levelId,
    correctAnswers,
    totalQuestions,
    timeSpent,
    starsEarned,
    accuracy,
    completedAt,
  ];
}
