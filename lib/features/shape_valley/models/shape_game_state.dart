import 'package:equatable/equatable.dart';

import 'shape.dart';
import 'shape_level.dart';

/// Enum representing the status of the shape game
enum ShapeGameStatus { initial, loading, playing, paused, completed, error }

/// Model representing the state of a Shape Valley game
class ShapeGameState extends Equatable {
  final ShapeGameStatus status;
  final ShapeLevel? level;
  final List<Shape> availableShapes; // Shapes not yet placed
  final Map<String, String> placements; // targetId -> shapeId
  final Shape? draggedShape; // Currently being dragged
  final String? hoveredTargetId; // Target being hovered over
  final int correctPlacements;
  final int incorrectAttempts;
  final int timeRemaining; // seconds, 0 for unlimited
  final DateTime? startTime;
  final String? errorMessage;

  const ShapeGameState({
    this.status = ShapeGameStatus.initial,
    this.level,
    this.availableShapes = const [],
    this.placements = const {},
    this.draggedShape,
    this.hoveredTargetId,
    this.correctPlacements = 0,
    this.incorrectAttempts = 0,
    this.timeRemaining = 0,
    this.startTime,
    this.errorMessage,
  });

  /// Create initial state
  factory ShapeGameState.initial() {
    return const ShapeGameState();
  }

  /// Create loading state
  factory ShapeGameState.loading() {
    return const ShapeGameState(status: ShapeGameStatus.loading);
  }

  /// Create error state
  factory ShapeGameState.error(String message) {
    return ShapeGameState(status: ShapeGameStatus.error, errorMessage: message);
  }

  /// Check if the game is complete
  bool get isComplete {
    if (level == null) return false;
    return correctPlacements >= level!.targets.length;
  }

  /// Calculate accuracy
  double get accuracy {
    final totalAttempts = correctPlacements + incorrectAttempts;
    if (totalAttempts == 0) return 0.0;
    return correctPlacements / totalAttempts;
  }

  /// Calculate time spent in seconds
  int get timeSpent {
    if (startTime == null) return 0;
    return DateTime.now().difference(startTime!).inSeconds;
  }

  /// Check if a target is filled
  bool isTargetFilled(String targetId) {
    return placements.containsKey(targetId);
  }

  /// Get the shape placed in a target
  Shape? getShapeInTarget(String targetId) {
    final shapeId = placements[targetId];
    if (shapeId == null) return null;

    // Check in available shapes first (shouldn't be there if placed)
    final shape = availableShapes.where((s) => s.id == shapeId).firstOrNull;
    if (shape != null) return shape;

    // Check in level shapes
    return level?.shapes.where((s) => s.id == shapeId).firstOrNull;
  }

  /// Create a copy with modified fields
  ShapeGameState copyWith({
    ShapeGameStatus? status,
    ShapeLevel? level,
    List<Shape>? availableShapes,
    Map<String, String>? placements,
    Shape? draggedShape,
    String? hoveredTargetId,
    int? correctPlacements,
    int? incorrectAttempts,
    int? timeRemaining,
    DateTime? startTime,
    String? errorMessage,
    bool clearDraggedShape = false,
    bool clearHoveredTarget = false,
  }) {
    return ShapeGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      availableShapes: availableShapes ?? this.availableShapes,
      placements: placements ?? this.placements,
      draggedShape: clearDraggedShape
          ? null
          : (draggedShape ?? this.draggedShape),
      hoveredTargetId: clearHoveredTarget
          ? null
          : (hoveredTargetId ?? this.hoveredTargetId),
      correctPlacements: correctPlacements ?? this.correctPlacements,
      incorrectAttempts: incorrectAttempts ?? this.incorrectAttempts,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startTime: startTime ?? this.startTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    level,
    availableShapes,
    placements,
    draggedShape,
    hoveredTargetId,
    correctPlacements,
    incorrectAttempts,
    timeRemaining,
    startTime,
    errorMessage,
  ];
}
