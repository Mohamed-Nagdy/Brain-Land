import '../models/shape.dart';
import '../models/shape_level.dart';

/// Service for managing Shape Valley level data and progress
class ShapeStorageService {
  /// Get a specific level by ID
  Future<ShapeLevel> getLevel(String levelId) async {
    // For now, return mock data
    // In a real implementation, this would load from Hive or another storage
    return _getMockLevel(levelId);
  }

  /// Get all levels for Shape Valley
  Future<List<ShapeLevel>> getAllLevels() async {
    // Return mock levels
    return List.generate(
      10,
      (index) => _getMockLevel('shape_level_${index + 1}'),
    );
  }

  /// Mock level generator for testing
  ShapeLevel _getMockLevel(String levelId) {
    final levelNumber = int.tryParse(levelId.split('_').last) ?? 1;
    final difficulty =
        ((levelNumber - 1) ~/ 3) + 1; // Difficulty increases every 3 levels

    // Generate shapes based on difficulty
    final shapes = _generateShapesForLevel(levelNumber, difficulty);
    final targets = _generateTargetsForLevel(levelNumber, difficulty, shapes);

    return ShapeLevel(
      id: levelId,
      levelNumber: levelNumber,
      difficulty: difficulty,
      shapes: shapes,
      targets: targets,
      sortingRule: _getSortingRuleForLevel(levelNumber),
      timeLimit: difficulty > 2
          ? 120 - (difficulty * 10)
          : 0, // Time limit for harder levels
      targetScore: 100,
    );
  }

  /// Generate shapes for a level
  List<Shape> _generateShapesForLevel(int levelNumber, int difficulty) {
    final shapes = <Shape>[];
    final shapeCount = 4 + (difficulty * 2); // More shapes for harder levels

    for (int i = 0; i < shapeCount; i++) {
      shapes.add(
        Shape(
          id: 'shape_$i',
          type: ShapeType.values[i % ShapeType.values.length],
          color: ShapeColor.values[i % ShapeColor.values.length],
          size: (i % 3) + 1,
        ),
      );
    }

    return shapes;
  }

  /// Generate targets for a level
  List<ShapeTarget> _generateTargetsForLevel(
    int levelNumber,
    int difficulty,
    List<Shape> shapes,
  ) {
    final targets = <ShapeTarget>[];
    final rule = _getSortingRuleForLevel(levelNumber);

    switch (rule) {
      case SortingRule.byType:
        // Create targets for each unique shape type
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
        // Create targets for each unique color
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
        // Create targets for each size
        for (int size = 1; size <= 3; size++) {
          targets.add(
            ShapeTarget(
              id: 'target_size_$size',
              rule: rule,
              requiredSize: size,
              label: _getSizeName(size),
            ),
          );
        }
        break;

      case SortingRule.byTypeAndColor:
        // Create targets for specific type-color combinations
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

  /// Get sorting rule based on level number
  SortingRule _getSortingRuleForLevel(int levelNumber) {
    if (levelNumber <= 3) {
      return SortingRule.byType;
    } else if (levelNumber <= 6) {
      return SortingRule.byColor;
    } else if (levelNumber <= 8) {
      return SortingRule.bySize;
    } else {
      return SortingRule.byTypeAndColor;
    }
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
}
