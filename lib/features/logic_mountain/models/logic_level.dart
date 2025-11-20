import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'logic_level.g.dart';

/// Model representing a Logic Mountain level with difficulty and scoring parameters
@HiveType(typeId: 16)
class LogicLevel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int levelNumber;

  @HiveField(2)
  final int difficulty;

  @HiveField(3)
  final int timeLimit; // 0 for unlimited

  @HiveField(4)
  final int targetScore; // Number of correct patterns needed

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final int starsEarned;

  @HiveField(7)
  final int bestScore;

  @HiveField(8)
  final int bestAccuracy; // Percentage (0-100)

  @HiveField(9)
  final int hintsUsed;

  const LogicLevel({
    required this.id,
    required this.levelNumber,
    required this.difficulty,
    required this.timeLimit,
    required this.targetScore,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.bestAccuracy = 0,
    this.hintsUsed = 0,
  });

  /// Create a copy with modified fields
  LogicLevel copyWith({
    String? id,
    int? levelNumber,
    int? difficulty,
    int? timeLimit,
    int? targetScore,
    bool? isCompleted,
    int? starsEarned,
    int? bestScore,
    int? bestAccuracy,
    int? hintsUsed,
  }) {
    return LogicLevel(
      id: id ?? this.id,
      levelNumber: levelNumber ?? this.levelNumber,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      targetScore: targetScore ?? this.targetScore,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      hintsUsed: hintsUsed ?? this.hintsUsed,
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
      'hintsUsed': hintsUsed,
    };
  }

  /// Create from JSON
  factory LogicLevel.fromJson(Map<String, dynamic> json) {
    return LogicLevel(
      id: json['id'] as String,
      levelNumber: json['levelNumber'] as int,
      difficulty: json['difficulty'] as int,
      timeLimit: json['timeLimit'] as int,
      targetScore: json['targetScore'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      starsEarned: json['starsEarned'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      bestAccuracy: json['bestAccuracy'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
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
    hintsUsed,
  ];
}
