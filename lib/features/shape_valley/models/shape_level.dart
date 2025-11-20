import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'shape.dart';

part 'shape_level.g.dart';

/// Model representing a Shape Valley level with shapes and targets
@HiveType(typeId: 20)
class ShapeLevel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int levelNumber;
  @HiveField(2)
  final int difficulty; // 1-5 scale
  @HiveField(3)
  final List<Shape> shapes; // Shapes to be sorted
  @HiveField(4)
  final List<ShapeTarget> targets; // Target zones for sorting
  @HiveField(5)
  final SortingRule sortingRule;
  @HiveField(6)
  final int timeLimit; // 0 for unlimited
  @HiveField(7)
  final int targetScore;
  @HiveField(8)
  final bool isCompleted;
  @HiveField(9)
  final int starsEarned; // 0-3
  @HiveField(10)
  final int bestScore;

  const ShapeLevel({
    required this.id,
    required this.levelNumber,
    required this.difficulty,
    required this.shapes,
    required this.targets,
    required this.sortingRule,
    this.timeLimit = 0,
    this.targetScore = 100,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestScore = 0,
  });

  /// Check if all shapes have been correctly placed
  bool get isAllShapesSorted {
    return targets.every((target) => target.isFilled);
  }

  /// Get the number of correctly placed shapes
  int get correctlyPlacedCount {
    return targets.where((target) => target.isFilled).length;
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (targets.isEmpty) return 0.0;
    return (correctlyPlacedCount / targets.length) * 100;
  }

  /// Create a copy with modified fields
  ShapeLevel copyWith({
    String? id,
    int? levelNumber,
    int? difficulty,
    List<Shape>? shapes,
    List<ShapeTarget>? targets,
    SortingRule? sortingRule,
    int? timeLimit,
    int? targetScore,
    bool? isCompleted,
    int? starsEarned,
    int? bestScore,
  }) {
    return ShapeLevel(
      id: id ?? this.id,
      levelNumber: levelNumber ?? this.levelNumber,
      difficulty: difficulty ?? this.difficulty,
      shapes: shapes ?? this.shapes,
      targets: targets ?? this.targets,
      sortingRule: sortingRule ?? this.sortingRule,
      timeLimit: timeLimit ?? this.timeLimit,
      targetScore: targetScore ?? this.targetScore,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  @override
  List<Object?> get props => [
    id,
    levelNumber,
    difficulty,
    shapes,
    targets,
    sortingRule,
    timeLimit,
    targetScore,
    isCompleted,
    starsEarned,
    bestScore,
  ];
}

/// Model representing the result of completing a Shape Valley level
class ShapeLevelResult extends Equatable {
  final String levelId;
  final int score;
  final int starsEarned;
  final int timeTaken; // in seconds
  final int correctPlacements;
  final int totalShapes;
  final double accuracy;
  final DateTime completedAt;

  const ShapeLevelResult({
    required this.levelId,
    required this.score,
    required this.starsEarned,
    required this.timeTaken,
    required this.correctPlacements,
    required this.totalShapes,
    required this.accuracy,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [
    levelId,
    score,
    starsEarned,
    timeTaken,
    correctPlacements,
    totalShapes,
    accuracy,
    completedAt,
  ];
}
