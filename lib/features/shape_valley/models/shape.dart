import 'package:equatable/equatable.dart';

/// Enum representing different shape types
enum ShapeType {
  circle,
  square,
  triangle,
  rectangle,
  star,
  heart,
  diamond,
  hexagon,
}

/// Enum representing shape colors
enum ShapeColor { red, blue, green, yellow, purple, orange, pink, cyan }

/// Model representing a shape with type and color
class Shape extends Equatable {
  final String id;
  final ShapeType type;
  final ShapeColor color;
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
enum SortingRule {
  byType, // Sort by shape type
  byColor, // Sort by color
  bySize, // Sort by size
  byTypeAndColor, // Sort by both type and color
}

/// Model representing a target zone for shape placement
class ShapeTarget extends Equatable {
  final String id;
  final SortingRule rule;
  final ShapeType? requiredType;
  final ShapeColor? requiredColor;
  final int? requiredSize;
  final String label; // Display label for the target zone
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
