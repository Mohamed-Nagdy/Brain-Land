import 'package:equatable/equatable.dart';

/// Model representing a Math Forest level with difficulty and scoring parameters
class MathLevel extends Equatable {
  final String id;
  final int levelNumber;
  final int difficulty;
  final int timeLimit; // 0 for unlimited
  final int targetScore; // Number of correct answers needed
  final bool isCompleted;
  final int starsEarned;
  final int bestScore;
  final int bestAccuracy; // Percentage (0-100)

  const MathLevel({
    required this.id,
    required this.levelNumber,
    required this.difficulty,
    required this.timeLimit,
    required this.targetScore,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.bestAccuracy = 0,
  });

  /// Create a copy with modified fields
  MathLevel copyWith({
    String? id,
    int? levelNumber,
    int? difficulty,
    int? timeLimit,
    int? targetScore,
    bool? isCompleted,
    int? starsEarned,
    int? bestScore,
    int? bestAccuracy,
  }) {
    return MathLevel(
      id: id ?? this.id,
      levelNumber: levelNumber ?? this.levelNumber,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      targetScore: targetScore ?? this.targetScore,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levelNumber': levelNumber,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
      'targetScore': targetScore,
      'isCompleted': isCompleted,
      'starsEarned': starsEarned,
      'bestScore': bestScore,
      'bestAccuracy': bestAccuracy,
    };
  }

  /// Create from JSON
  factory MathLevel.fromJson(Map<String, dynamic> json) {
    return MathLevel(
      id: json['id'] as String,
      levelNumber: json['levelNumber'] as int,
      difficulty: json['difficulty'] as int,
      timeLimit: json['timeLimit'] as int,
      targetScore: json['targetScore'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      starsEarned: json['starsEarned'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      bestAccuracy: json['bestAccuracy'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    levelNumber,
    difficulty,
    timeLimit,
    targetScore,
    isCompleted,
    starsEarned,
    bestScore,
    bestAccuracy,
  ];
}
