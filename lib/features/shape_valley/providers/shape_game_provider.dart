import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/difficulty_calculator.dart';
import '../../progress/providers/progress_provider.dart';
import '../models/shape.dart';
import '../models/shape_game_state.dart';
import '../services/shape_storage_service.dart';

/// Provider for the shape storage service
final shapeStorageServiceProvider = Provider<ShapeStorageService>((ref) {
  return ShapeStorageService();
});

/// Provider for managing the shape game state
final shapeGameProvider =
    StateNotifierProvider.family<ShapeGameNotifier, ShapeGameState, String>((
      ref,
      levelId,
    ) {
      final storage = ref.watch(shapeStorageServiceProvider);
      final calculator = DifficultyCalculator();

      return ShapeGameNotifier(
        levelId: levelId,
        storage: storage,
        calculator: calculator,
        ref: ref,
      );
    });

/// Notifier for managing shape game state
class ShapeGameNotifier extends StateNotifier<ShapeGameState> {
  final String levelId;
  final ShapeStorageService storage;
  final DifficultyCalculator calculator;
  final Ref ref;

  Timer? _timer;

  ShapeGameNotifier({
    required this.levelId,
    required this.storage,
    required this.calculator,
    required this.ref,
  }) : super(ShapeGameState.initial());

  /// Start the game level
  Future<void> startLevel() async {
    state = ShapeGameState.loading();

    try {
      // Load level data
      final level = await storage.getLevel(levelId);

      // Initialize game state with all shapes available
      state = ShapeGameState(
        status: ShapeGameStatus.playing,
        level: level,
        availableShapes: List.from(level.shapes),
        placements: {},
        timeRemaining: level.timeLimit,
        startTime: DateTime.now(),
      );

      // Start timer if time limit is set
      if (level.timeLimit > 0) {
        _startTimer();
      }
    } catch (e) {
      state = ShapeGameState.error('Failed to start level: $e');
    }
  }

  /// Start dragging a shape
  void startDrag(Shape shape) {
    if (state.status != ShapeGameStatus.playing) return;

    state = state.copyWith(draggedShape: shape);
  }

  /// Update hovered target during drag
  void updateHoveredTarget(String? targetId) {
    if (state.status != ShapeGameStatus.playing) return;
    if (state.draggedShape == null) return;

    state = state.copyWith(hoveredTargetId: targetId);
  }

  /// Attempt to place a shape in a target
  void placeShape(String targetId) {
    if (state.status != ShapeGameStatus.playing) return;
    if (state.draggedShape == null) return;
    if (state.level == null) return;

    final shape = state.draggedShape!;
    final target = state.level!.targets.firstWhere(
      (t) => t.id == targetId,
      orElse: () => throw Exception('Target not found'),
    );

    // Check if target already has a shape
    if (state.isTargetFilled(targetId)) {
      // Return shape to available shapes
      cancelDrag();
      return;
    }

    // Validate placement
    if (target.accepts(shape)) {
      // Correct placement!
      _handleCorrectPlacement(shape, targetId);
    } else {
      // Incorrect placement
      _handleIncorrectPlacement();
    }
  }

  /// Handle correct shape placement
  void _handleCorrectPlacement(Shape shape, String targetId) {
    // Remove shape from available shapes
    final updatedAvailableShapes = state.availableShapes
        .where((s) => s.id != shape.id)
        .toList();

    // Add placement
    final updatedPlacements = Map<String, String>.from(state.placements);
    updatedPlacements[targetId] = shape.id;

    // Update target to mark as filled
    final updatedLevel = state.level!.copyWith(
      targets: state.level!.targets.map((t) {
        if (t.id == targetId) {
          return t.copyWith(isFilled: true);
        }
        return t;
      }).toList(),
    );

    state = state.copyWith(
      availableShapes: updatedAvailableShapes,
      placements: updatedPlacements,
      level: updatedLevel,
      correctPlacements: state.correctPlacements + 1,
      clearDraggedShape: true,
      clearHoveredTarget: true,
    );

    // Check if level is complete
    if (state.isComplete) {
      _completeLevel();
    }
  }

  /// Handle incorrect shape placement
  void _handleIncorrectPlacement() {
    // Increment incorrect attempts
    state = state.copyWith(
      incorrectAttempts: state.incorrectAttempts + 1,
      clearDraggedShape: true,
      clearHoveredTarget: true,
    );

    // Shape returns to available shapes (already there)
  }

  /// Cancel drag operation
  void cancelDrag() {
    state = state.copyWith(clearDraggedShape: true, clearHoveredTarget: true);
  }

  /// Remove a shape from a target (undo placement)
  void removeShapeFromTarget(String targetId) {
    if (state.status != ShapeGameStatus.playing) return;
    if (!state.isTargetFilled(targetId)) return;

    final shapeId = state.placements[targetId];
    if (shapeId == null) return;

    // Find the shape
    final shape = state.level?.shapes.firstWhere(
      (s) => s.id == shapeId,
      orElse: () => throw Exception('Shape not found'),
    );

    if (shape == null) return;

    // Remove placement
    final updatedPlacements = Map<String, String>.from(state.placements);
    updatedPlacements.remove(targetId);

    // Add shape back to available shapes
    final updatedAvailableShapes = List<Shape>.from(state.availableShapes);
    updatedAvailableShapes.add(shape);

    // Update target to mark as not filled
    final updatedLevel = state.level!.copyWith(
      targets: state.level!.targets.map((t) {
        if (t.id == targetId) {
          return t.copyWith(isFilled: false);
        }
        return t;
      }).toList(),
    );

    state = state.copyWith(
      availableShapes: updatedAvailableShapes,
      placements: updatedPlacements,
      level: updatedLevel,
      correctPlacements: state.correctPlacements - 1,
    );
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        // Time expired
        timer.cancel();
        _completeLevel();
      }
    });
  }

  /// Pause the game
  void pauseGame() {
    if (state.status == ShapeGameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: ShapeGameStatus.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.status == ShapeGameStatus.paused) {
      state = state.copyWith(status: ShapeGameStatus.playing);
      if (state.level != null && state.level!.timeLimit > 0) {
        _startTimer();
      }
    }
  }

  /// Complete the level and calculate results
  Future<void> _completeLevel() async {
    _timer?.cancel();

    if (state.level == null) return;

    // Calculate stars earned
    final starsEarned = _calculateStars(
      state.accuracy,
      state.level!.difficulty,
    );

    // Save progress
    await storage.updateLevelProgress(
      levelId: levelId,
      correctPlacements: state.correctPlacements,
      timeSpent: state.timeSpent,
      starsEarned: starsEarned,
    );

    // Handle level completion for progress tracking
    if (starsEarned > 0) {
      // Level was completed successfully
      await ref
          .read(progressNotifierProvider.notifier)
          .incrementConsecutiveLevels();
    } else {
      // Level was failed, reset consecutive counter
      await ref
          .read(progressNotifierProvider.notifier)
          .resetConsecutiveLevels();
    }

    // Update state to completed
    state = state.copyWith(status: ShapeGameStatus.completed);
  }

  /// Calculate stars earned based on accuracy and difficulty
  int _calculateStars(double accuracy, int difficulty) {
    final thresholds = calculator.calculateStarThresholds(difficulty);

    if (accuracy >= thresholds.threeStar) {
      return 3;
    } else if (accuracy >= thresholds.twoStar) {
      return 2;
    } else if (accuracy >= thresholds.oneStar) {
      return 1;
    } else {
      return 0;
    }
  }

  /// Reset the game
  void resetGame() {
    _timer?.cancel();
    state = ShapeGameState.initial();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
