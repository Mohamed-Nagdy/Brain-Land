import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'level.g.dart';

@HiveType(typeId: 2)
class Level extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String zoneId;

  @HiveField(2)
  final int levelNumber;

  @HiveField(3)
  final int difficulty;

  @HiveField(4)
  final int targetScore;

  @HiveField(5)
  final int timeLimit; // 0 for unlimited

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final int starsEarned;

  @HiveField(8)
  final int bestScore;

  const Level({
    required this.id,
    required this.zoneId,
    required this.levelNumber,
    required this.difficulty,
    required this.targetScore,
    required this.timeLimit,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestScore = 0,
  });

  Level copyWith({
    String? id,
    String? zoneId,
    int? levelNumber,
    int? difficulty,
    int? targetScore,
    int? timeLimit,
    bool? isCompleted,
    int? starsEarned,
    int? bestScore,
  }) {
    return Level(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      levelNumber: levelNumber ?? this.levelNumber,
      difficulty: difficulty ?? this.difficulty,
      targetScore: targetScore ?? this.targetScore,
      timeLimit: timeLimit ?? this.timeLimit,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    levelNumber,
    difficulty,
    targetScore,
    timeLimit,
    isCompleted,
    starsEarned,
    bestScore,
  ];
}
