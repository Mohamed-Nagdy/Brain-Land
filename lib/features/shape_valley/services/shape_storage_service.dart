import 'package:hive/hive.dart';

import '../models/shape.dart';
import '../models/shape_level.dart';

/// Service for managing Shape Valley level data and progress
class ShapeStorageService {
  static const String _shapeLevelsBoxName = 'shape_levels';

  /// Get a specific level by ID
  Future<ShapeLevel> getLevel(String levelId) async {
    Box<ShapeLevel> box;
    try {
      box = await Hive.openBox<ShapeLevel>(_shapeLevelsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_shapeLevelsBoxName);
      box = await Hive.openBox<ShapeLevel>(_shapeLevelsBoxName);
    }

    // Try to get from storage first
    try {
      final storedLevel = box.get(levelId);
      if (storedLevel != null) {
        return storedLevel;
      }
    } catch (e) {
      // Ignore read error and regenerate
    }

    // If not in storage, generate it
    final levelNumber = int.parse(levelId.split('_').last);
    final newLevel = _createLevel(levelNumber);

    // Save to storage
    await box.put(levelId, newLevel);

    return newLevel;
  }

  /// Get all levels
  Future<List<ShapeLevel>> getAllLevels() async {
    Box<ShapeLevel> box;
    try {
      box = await Hive.openBox<ShapeLevel>(_shapeLevelsBoxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_shapeLevelsBoxName);
      box = await Hive.openBox<ShapeLevel>(_shapeLevelsBoxName);
    }

    List<ShapeLevel> levels = [];

    for (int i = 1; i <= 1000; i++) {
      final id = 'shape_$i';
      try {
        if (box.containsKey(id)) {
          final level = box.get(id);
          if (level != null) {
            levels.add(level);
          } else {
            levels.add(_createLevel(i));
          }
        } else {
          levels.add(_createLevel(i));
        }
      } catch (e) {
        levels.add(_createLevel(i));
      }
    }

    // Ensure levels are sorted by levelNumber
    levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));

    return levels;
  }

  /// Update level progress after completion
  Future<void> updateLevelProgress({
    required String levelId,
    required int score,
    required int starsEarned,
  }) async {
    final level = await getLevel(levelId);

    final updatedLevel = level.copyWith(
      isCompleted: true,
      starsEarned: starsEarned > level.starsEarned
          ? starsEarned
          : level.starsEarned,
      bestScore: score > level.bestScore ? score : level.bestScore,
    );

    final box = await Hive.openBox<ShapeLevel>(_shapeLevelsBoxName);
    await box.put(updatedLevel.id, updatedLevel);
  }

  /// Get number of completed levels
  Future<int> getCompletedLevelsCount() async {
    final levels = await getAllLevels();
    return levels.where((level) => level.isCompleted).length;
  }

  /// Create a level with appropriate difficulty progression
  ShapeLevel _createLevel(int levelNumber) {
    int difficulty, shapeCount, timeLimit;
    SortingRule sortingRule;

    if (levelNumber <= 200) {
      // Easy levels: Sort by type
      difficulty = ((levelNumber - 1) ~/ 67) + 1; // 1-3
      shapeCount = 4 + (difficulty * 2); // 6-10 shapes
      sortingRule = SortingRule.byType;
      timeLimit = 0; // Unlimited
    } else if (levelNumber <= 600) {
      // Medium levels: Sort by color/size
      difficulty = 4 + ((levelNumber - 201) ~/ 100); // 4-7
      shapeCount = 8 + (difficulty - 3) * 2; // 10-16 shapes
      sortingRule = levelNumber % 2 == 0
          ? SortingRule.byColor
          : SortingRule.bySize;
      timeLimit = 120 - (difficulty * 10); // 80-50 seconds
    } else {
      // Hard levels: Sort by type+color
      difficulty = 8 + ((levelNumber - 601) ~/ 134); // 8-10
      shapeCount = 12 + (difficulty - 7) * 2; // 14-18 shapes
      sortingRule = SortingRule.byTypeAndColor;
      timeLimit = 100 - (difficulty - 7) * 10; // 100-80 seconds
    }

    difficulty = difficulty.clamp(1, 10);

    // Generate shapes and targets
    final shapes = _generateShapesForLevel(levelNumber, shapeCount);
    final targets = _generateTargetsForLevel(sortingRule, shapes);

    return ShapeLevel(
      id: 'shape_$levelNumber',
      levelNumber: levelNumber,
      difficulty: difficulty,
      shapes: shapes,
      targets: targets,
      sortingRule: sortingRule,
      timeLimit: timeLimit,
      targetScore: 100,
    );
  }

  /// Generate shapes for a level
  List<Shape> _generateShapesForLevel(int levelNumber, int shapeCount) {
    final shapes = <Shape>[];
    final seed = levelNumber * 7; // Deterministic but varied

    for (int i = 0; i < shapeCount; i++) {
      shapes.add(
        Shape(
          id: 'shape_$i',
          type: ShapeType.values[(seed + i) % ShapeType.values.length],
          color: ShapeColor.values[(seed + i * 3) % ShapeColor.values.length],
          size: ((seed + i) % 3) + 1,
        ),
      );
    }

    return shapes;
  }

  /// Generate targets for a level
  List<ShapeTarget> _generateTargetsForLevel(
    SortingRule rule,
    List<Shape> shapes,
  ) {
    final targets = <ShapeTarget>[];

    switch (rule) {
      case SortingRule.byType:
        final uniqueTypes = shapes.map((s) => s.type).toSet();
        for (final type in uniqueTypes) {
          targets.add(
            ShapeTarget(
              id: 'target_${type.name}',
              rule: rule,
              requiredType: type,
              label: _getShapeTypeName(type),
            ),
          );
        }
        break;

      case SortingRule.byColor:
        final uniqueColors = shapes.map((s) => s.color).toSet();
        for (final color in uniqueColors) {
          targets.add(
            ShapeTarget(
              id: 'target_${color.name}',
              rule: rule,
              requiredColor: color,
              label: _getColorName(color),
            ),
          );
        }
        break;

      case SortingRule.bySize:
        for (int size = 1; size <= 3; size++) {
          if (shapes.any((s) => s.size == size)) {
            targets.add(
              ShapeTarget(
                id: 'target_size_$size',
                rule: rule,
                requiredSize: size,
                label: _getSizeName(size),
              ),
            );
          }
        }
        break;

      case SortingRule.byTypeAndColor:
        final combinations = shapes
            .map((s) => '${s.type.name}_${s.color.name}')
            .toSet();
        for (final combo in combinations) {
          final parts = combo.split('_');
          final type = ShapeType.values.firstWhere((t) => t.name == parts[0]);
          final color = ShapeColor.values.firstWhere((c) => c.name == parts[1]);
          targets.add(
            ShapeTarget(
              id: 'target_$combo',
              rule: rule,
              requiredType: type,
              requiredColor: color,
              label: '${_getColorName(color)} ${_getShapeTypeName(type)}',
            ),
          );
        }
        break;
    }

    return targets;
  }

  /// Get human-readable shape type name
  String _getShapeTypeName(ShapeType type) {
    switch (type) {
      case ShapeType.circle:
        return 'Circles';
      case ShapeType.square:
        return 'Squares';
      case ShapeType.triangle:
        return 'Triangles';
      case ShapeType.rectangle:
        return 'Rectangles';
      case ShapeType.star:
        return 'Stars';
      case ShapeType.heart:
        return 'Hearts';
      case ShapeType.diamond:
        return 'Diamonds';
      case ShapeType.hexagon:
        return 'Hexagons';
    }
  }

  /// Get human-readable color name
  String _getColorName(ShapeColor color) {
    switch (color) {
      case ShapeColor.red:
        return 'Red';
      case ShapeColor.blue:
        return 'Blue';
      case ShapeColor.green:
        return 'Green';
      case ShapeColor.yellow:
        return 'Yellow';
      case ShapeColor.purple:
        return 'Purple';
      case ShapeColor.orange:
        return 'Orange';
      case ShapeColor.pink:
        return 'Pink';
      case ShapeColor.cyan:
        return 'Cyan';
    }
  }

  /// Get human-readable size name
  String _getSizeName(int size) {
    switch (size) {
      case 1:
        return 'Small';
      case 2:
        return 'Medium';
      case 3:
        return 'Large';
      default:
        return 'Unknown';
    }
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    await Hive.deleteBoxFromDisk(_shapeLevelsBoxName);
  }
}
