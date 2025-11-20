import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'shape.g.dart';

/// Enum representing different shape types
@HiveType(typeId: 19)
enum ShapeType {
  @HiveField(0)
  circle,
  @HiveField(1)
  square,
  @HiveField(2)
  triangle,
  @HiveField(3)
  rectangle,
  @HiveField(4)
  star,
  @HiveField(5)
  heart,
  @HiveField(6)
  diamond,
  @HiveField(7)
  hexagon,
}

/// Enum representing shape colors
@HiveType(typeId: 21)
enum ShapeColor {
  @HiveField(0)
  red,
  @HiveField(1)
  blue,
  @HiveField(2)
  green,
  @HiveField(3)
  yellow,
  @HiveField(4)
  purple,
  @HiveField(5)
  orange,
  @HiveField(6)
  pink,
  @HiveField(7)
  cyan,
}

/// Model representing a shape with type and color
@HiveType(typeId: 24)
class Shape extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final ShapeType type;
  @HiveField(2)
  final ShapeColor color;
  @HiveField(3)
  final int size; // 1-3 scale (small, medium, large)

  const Shape({
    required this.id,
    required this.type,
    required this.color,
    this.size = 2, // Default to medium
  });

  /// Create a copy with modified fields
  Shape copyWith({String? id, ShapeType? type, ShapeColor? color, int? size}) {
    return Shape(
      id: id ?? this.id,
      type: type ?? this.type,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [id, type, color, size];
}

/// Enum representing sorting rules for shapes
@HiveType(typeId: 22)
enum SortingRule {
  @HiveField(0)
  byType, // Sort by shape type
  @HiveField(1)
  byColor, // Sort by color
  @HiveField(2)
  bySize, // Sort by size
  @HiveField(3)
  byTypeAndColor, // Sort by both type and color
}

/// Model representing a target zone for shape placement
@HiveType(typeId: 23)
class ShapeTarget extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final SortingRule rule;
  @HiveField(2)
  final ShapeType? requiredType;
  @HiveField(3)
  final ShapeColor? requiredColor;
  @HiveField(4)
  final int? requiredSize;
  @HiveField(5)
  final String label; // Display label for the target zone
  @HiveField(6)
  final bool isFilled;

  const ShapeTarget({
    required this.id,
    required this.rule,
    this.requiredType,
    this.requiredColor,
    this.requiredSize,
    required this.label,
    this.isFilled = false,
  });

  /// Check if a shape matches this target's requirements
  bool accepts(Shape shape) {
    switch (rule) {
      case SortingRule.byType:
        return requiredType == null || shape.type == requiredType;
      case SortingRule.byColor:
        return requiredColor == null || shape.color == requiredColor;
      case SortingRule.bySize:
        return requiredSize == null || shape.size == requiredSize;
      case SortingRule.byTypeAndColor:
        return (requiredType == null || shape.type == requiredType) &&
            (requiredColor == null || shape.color == requiredColor);
    }
  }

  /// Create a copy with modified fields
  ShapeTarget copyWith({
    String? id,
    SortingRule? rule,
    ShapeType? requiredType,
    ShapeColor? requiredColor,
    int? requiredSize,
    String? label,
    bool? isFilled,
  }) {
    return ShapeTarget(
      id: id ?? this.id,
      rule: rule ?? this.rule,
      requiredType: requiredType ?? this.requiredType,
      requiredColor: requiredColor ?? this.requiredColor,
      requiredSize: requiredSize ?? this.requiredSize,
      label: label ?? this.label,
      isFilled: isFilled ?? this.isFilled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    rule,
    requiredType,
    requiredColor,
    requiredSize,
    label,
    isFilled,
  ];
}
