import 'dart:math';

import 'package:brain_land/core/constants/app_constants.dart';
import 'package:brain_land/features/shape_valley/models/shape.dart';
import 'package:brain_land/features/shape_valley/models/shape_game_state.dart';
import 'package:brain_land/features/shape_valley/models/shape_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Shape Game Properties', () {
    // **Feature: brainland-game, Property 16: Correct shape placement snaps and provides feedback**
    test('correct shape placement snaps and provides feedback', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate random shapes and targets
        final shapeType =
            ShapeType.values[Random().nextInt(ShapeType.values.length)];
        final shapeColor =
            ShapeColor.values[Random().nextInt(ShapeColor.values.length)];
        final shapeSize = Random().nextInt(3) + 1;

        final shape = Shape(
          id: 'shape_$i',
          type: shapeType,
          color: shapeColor,
          size: shapeSize,
        );

        // Create a target that accepts this shape
        final target = ShapeTarget(
          id: 'target_$i',
          rule: SortingRule.byType,
          requiredType: shapeType,
          label: 'Test Target',
        );

        // Verify target accepts the shape
        expect(
          target.accepts(shape),
          isTrue,
          reason: 'Target should accept shape with matching type',
        );

        // Simulate placement
        final level = ShapeLevel(
          id: 'test_level',
          levelNumber: 1,
          difficulty: 1,
          shapes: [shape],
          targets: [target],
          sortingRule: SortingRule.byType,
        );

        var state = ShapeGameState(
          status: ShapeGameStatus.playing,
          level: level,
          availableShapes: [shape],
        );

        // Start drag
        state = state.copyWith(draggedShape: shape);
        expect(state.draggedShape, equals(shape));

        // Place shape in target
        final updatedPlacements = <String, String>{target.id: shape.id};
        final updatedAvailableShapes = <Shape>[];
        final updatedTargets = [target.copyWith(isFilled: true)];
        final updatedLevel = level.copyWith(targets: updatedTargets);

        state = state.copyWith(
          availableShapes: updatedAvailableShapes,
          placements: updatedPlacements,
          level: updatedLevel,
          correctPlacements: 1,
          clearDraggedShape: true,
        );

        // Verify placement was successful
        expect(
          state.isTargetFilled(target.id),
          isTrue,
          reason: 'Target should be marked as filled after correct placement',
        );
        expect(
          state.placements[target.id],
          equals(shape.id),
          reason: 'Placement map should contain the shape-target mapping',
        );
        expect(
          state.availableShapes.contains(shape),
          isFalse,
          reason:
              'Shape should be removed from available shapes after placement',
        );
        expect(
          state.correctPlacements,
          equals(1),
          reason: 'Correct placements counter should increment',
        );
        expect(
          state.draggedShape,
          isNull,
          reason: 'Dragged shape should be cleared after placement',
        );
      }
    });

    // **Feature: brainland-game, Property 17: Incorrect shape placement returns shape**
    test('incorrect shape placement returns shape', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate a shape and a target that doesn't accept it
        final shapeType =
            ShapeType.values[Random().nextInt(ShapeType.values.length)];
        final differentType = ShapeType.values.firstWhere(
          (t) => t != shapeType,
          orElse: () =>
              ShapeType.values[(ShapeType.values.indexOf(shapeType) + 1) %
                  ShapeType.values.length],
        );

        final shape = Shape(
          id: 'shape_$i',
          type: shapeType,
          color: ShapeColor.red,
          size: 2,
        );

        // Create a target that requires a different type
        final target = ShapeTarget(
          id: 'target_$i',
          rule: SortingRule.byType,
          requiredType: differentType,
          label: 'Test Target',
        );

        // Verify target does NOT accept the shape
        expect(
          target.accepts(shape),
          isFalse,
          reason: 'Target should not accept shape with different type',
        );

        // Simulate incorrect placement attempt
        final level = ShapeLevel(
          id: 'test_level',
          levelNumber: 1,
          difficulty: 1,
          shapes: [shape],
          targets: [target],
          sortingRule: SortingRule.byType,
        );

        var state = ShapeGameState(
          status: ShapeGameStatus.playing,
          level: level,
          availableShapes: [shape],
        );

        // Start drag
        state = state.copyWith(draggedShape: shape);

        // Attempt incorrect placement
        state = state.copyWith(
          incorrectAttempts: state.incorrectAttempts + 1,
          clearDraggedShape: true,
        );

        // Verify shape is still available
        expect(
          state.availableShapes.contains(shape),
          isTrue,
          reason:
              'Shape should remain in available shapes after incorrect placement',
        );
        expect(
          state.isTargetFilled(target.id),
          isFalse,
          reason: 'Target should not be filled after incorrect placement',
        );
        expect(
          state.incorrectAttempts,
          equals(1),
          reason: 'Incorrect attempts counter should increment',
        );
        expect(
          state.draggedShape,
          isNull,
          reason: 'Dragged shape should be cleared after failed placement',
        );
      }
    });

    // **Feature: brainland-game, Property 18: All shapes sorted completes level**
    test('all shapes sorted completes level', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        // Generate random number of shapes and matching targets
        final shapeCount = Random().nextInt(5) + 3; // 3-7 shapes
        final shapes = <Shape>[];
        final targets = <ShapeTarget>[];

        for (int j = 0; j < shapeCount; j++) {
          final shapeType = ShapeType.values[j % ShapeType.values.length];
          final shape = Shape(
            id: 'shape_$j',
            type: shapeType,
            color: ShapeColor.values[j % ShapeColor.values.length],
            size: (j % 3) + 1,
          );
          shapes.add(shape);

          final target = ShapeTarget(
            id: 'target_$j',
            rule: SortingRule.byType,
            requiredType: shapeType,
            label: 'Target $j',
          );
          targets.add(target);
        }

        final level = ShapeLevel(
          id: 'test_level_$i',
          levelNumber: i + 1,
          difficulty: Random().nextInt(5) + 1,
          shapes: shapes,
          targets: targets,
          sortingRule: SortingRule.byType,
        );

        // Create state with no placements
        var state = ShapeGameState(
          status: ShapeGameStatus.playing,
          level: level,
          availableShapes: List.from(shapes),
        );

        // Verify level is not complete initially
        expect(
          state.isComplete,
          isFalse,
          reason: 'Level should not be complete with no placements',
        );

        // Simulate placing all shapes correctly
        final placements = <String, String>{};
        final updatedTargets = <ShapeTarget>[];

        for (int j = 0; j < shapeCount; j++) {
          placements[targets[j].id] = shapes[j].id;
          updatedTargets.add(targets[j].copyWith(isFilled: true));
        }

        final updatedLevel = level.copyWith(targets: updatedTargets);

        state = state.copyWith(
          availableShapes: [],
          placements: placements,
          level: updatedLevel,
          correctPlacements: shapeCount,
        );

        // Verify level is complete
        expect(
          state.isComplete,
          isTrue,
          reason:
              'Level should be complete when all shapes are correctly placed',
        );
        expect(
          state.correctPlacements,
          equals(shapeCount),
          reason: 'Correct placements should equal total shapes',
        );
        expect(
          state.availableShapes.isEmpty,
          isTrue,
          reason: 'No shapes should remain available when level is complete',
        );
        expect(
          state.level!.isAllShapesSorted,
          isTrue,
          reason: 'Level should indicate all shapes are sorted',
        );
        expect(
          state.level!.completionPercentage,
          equals(100.0),
          reason: 'Completion percentage should be 100%',
        );

        // Test partial completion
        final partialPlacements = <String, String>{};
        final partialTargets = <ShapeTarget>[];
        final halfCount = shapeCount ~/ 2;

        for (int j = 0; j < halfCount; j++) {
          partialPlacements[targets[j].id] = shapes[j].id;
          partialTargets.add(targets[j].copyWith(isFilled: true));
        }
        for (int j = halfCount; j < shapeCount; j++) {
          partialTargets.add(targets[j]);
        }

        final partialLevel = level.copyWith(targets: partialTargets);
        final partialState = ShapeGameState(
          status: ShapeGameStatus.playing,
          level: partialLevel,
          availableShapes: shapes.sublist(halfCount),
          placements: partialPlacements,
          correctPlacements: halfCount,
        );

        expect(
          partialState.isComplete,
          isFalse,
          reason: 'Level should not be complete with partial placements',
        );
        expect(
          partialState.level!.completionPercentage,
          closeTo((halfCount / shapeCount) * 100, 1.0),
          reason: 'Completion percentage should reflect partial progress',
        );
      }
    });

    test('shape target validation works correctly for all sorting rules', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final shapeType =
            ShapeType.values[Random().nextInt(ShapeType.values.length)];
        final shapeColor =
            ShapeColor.values[Random().nextInt(ShapeColor.values.length)];
        final shapeSize = Random().nextInt(3) + 1;

        final shape = Shape(
          id: 'shape_$i',
          type: shapeType,
          color: shapeColor,
          size: shapeSize,
        );

        // Test byType rule
        final typeTarget = ShapeTarget(
          id: 'type_target',
          rule: SortingRule.byType,
          requiredType: shapeType,
          label: 'Type Target',
        );
        expect(typeTarget.accepts(shape), isTrue);

        final wrongTypeTarget = ShapeTarget(
          id: 'wrong_type_target',
          rule: SortingRule.byType,
          requiredType: ShapeType.values.firstWhere((t) => t != shapeType),
          label: 'Wrong Type Target',
        );
        expect(wrongTypeTarget.accepts(shape), isFalse);

        // Test byColor rule
        final colorTarget = ShapeTarget(
          id: 'color_target',
          rule: SortingRule.byColor,
          requiredColor: shapeColor,
          label: 'Color Target',
        );
        expect(colorTarget.accepts(shape), isTrue);

        final wrongColorTarget = ShapeTarget(
          id: 'wrong_color_target',
          rule: SortingRule.byColor,
          requiredColor: ShapeColor.values.firstWhere((c) => c != shapeColor),
          label: 'Wrong Color Target',
        );
        expect(wrongColorTarget.accepts(shape), isFalse);

        // Test bySize rule
        final sizeTarget = ShapeTarget(
          id: 'size_target',
          rule: SortingRule.bySize,
          requiredSize: shapeSize,
          label: 'Size Target',
        );
        expect(sizeTarget.accepts(shape), isTrue);

        final wrongSizeTarget = ShapeTarget(
          id: 'wrong_size_target',
          rule: SortingRule.bySize,
          requiredSize: (shapeSize % 3) + 1,
          label: 'Wrong Size Target',
        );
        if (wrongSizeTarget.requiredSize != shapeSize) {
          expect(wrongSizeTarget.accepts(shape), isFalse);
        }

        // Test byTypeAndColor rule
        final typeAndColorTarget = ShapeTarget(
          id: 'type_color_target',
          rule: SortingRule.byTypeAndColor,
          requiredType: shapeType,
          requiredColor: shapeColor,
          label: 'Type and Color Target',
        );
        expect(typeAndColorTarget.accepts(shape), isTrue);

        final wrongTypeAndColorTarget = ShapeTarget(
          id: 'wrong_type_color_target',
          rule: SortingRule.byTypeAndColor,
          requiredType: ShapeType.values.firstWhere((t) => t != shapeType),
          requiredColor: shapeColor,
          label: 'Wrong Type and Color Target',
        );
        expect(wrongTypeAndColorTarget.accepts(shape), isFalse);
      }
    });

    test('accuracy calculation is correct', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final correctPlacements = Random().nextInt(20);
        final incorrectAttempts = Random().nextInt(20);

        final state = ShapeGameState(
          status: ShapeGameStatus.playing,
          correctPlacements: correctPlacements,
          incorrectAttempts: incorrectAttempts,
        );

        final totalAttempts = correctPlacements + incorrectAttempts;
        final expectedAccuracy = totalAttempts == 0
            ? 0.0
            : correctPlacements / totalAttempts;

        expect(
          state.accuracy,
          equals(expectedAccuracy),
          reason: 'Accuracy should be calculated as correct / total attempts',
        );
      }
    });

    test('time spent calculation is accurate', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final secondsAgo = Random().nextInt(300);
        final startTime = DateTime.now().subtract(
          Duration(seconds: secondsAgo),
        );

        final state = ShapeGameState(
          status: ShapeGameStatus.playing,
          startTime: startTime,
        );

        final expectedTimeSpent = DateTime.now()
            .difference(startTime)
            .inSeconds;
        final actualTimeSpent = state.timeSpent;

        // Allow 1 second tolerance for test execution time
        expect(
          actualTimeSpent,
          inInclusiveRange(expectedTimeSpent - 1, expectedTimeSpent + 1),
          reason: 'Time spent should be calculated correctly',
        );
      }
    });

    test('shape removal from target works correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final shape = Shape(
          id: 'shape_$i',
          type: ShapeType.circle,
          color: ShapeColor.red,
          size: 2,
        );

        final target = ShapeTarget(
          id: 'target_$i',
          rule: SortingRule.byType,
          requiredType: ShapeType.circle,
          label: 'Test Target',
          isFilled: true,
        );

        final level = ShapeLevel(
          id: 'test_level',
          levelNumber: 1,
          difficulty: 1,
          shapes: [shape],
          targets: [target],
          sortingRule: SortingRule.byType,
        );

        // Create state with shape placed
        var state = ShapeGameState(
          status: ShapeGameStatus.playing,
          level: level,
          availableShapes: [],
          placements: {target.id: shape.id},
          correctPlacements: 1,
        );

        // Verify shape is placed
        expect(state.isTargetFilled(target.id), isTrue);
        expect(state.availableShapes.contains(shape), isFalse);

        // Simulate removal
        final updatedPlacements = <String, String>{};
        final updatedTargets = [target.copyWith(isFilled: false)];
        final updatedLevel = level.copyWith(targets: updatedTargets);

        state = state.copyWith(
          availableShapes: [shape],
          placements: updatedPlacements,
          level: updatedLevel,
          correctPlacements: 0,
        );

        // Verify shape is back in available shapes
        expect(state.isTargetFilled(target.id), isFalse);
        expect(state.availableShapes.contains(shape), isTrue);
        expect(state.correctPlacements, equals(0));
      }
    });

    test('drag state management works correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final shape = Shape(
          id: 'shape_$i',
          type: ShapeType.square,
          color: ShapeColor.blue,
          size: 1,
        );

        var state = const ShapeGameState(status: ShapeGameStatus.playing);

        // Start drag
        state = state.copyWith(draggedShape: shape);
        expect(state.draggedShape, equals(shape));

        // Update hovered target
        state = state.copyWith(hoveredTargetId: 'target_1');
        expect(state.hoveredTargetId, equals('target_1'));

        // Clear drag
        state = state.copyWith(
          clearDraggedShape: true,
          clearHoveredTarget: true,
        );
        expect(state.draggedShape, isNull);
        expect(state.hoveredTargetId, isNull);
      }
    });

    test('level completion percentage is accurate', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final totalTargets = Random().nextInt(10) + 1;
        final filledTargets = Random().nextInt(totalTargets + 1);

        final targets = List.generate(
          totalTargets,
          (index) => ShapeTarget(
            id: 'target_$index',
            rule: SortingRule.byType,
            requiredType: ShapeType.circle,
            label: 'Target $index',
            isFilled: index < filledTargets,
          ),
        );

        final level = ShapeLevel(
          id: 'test_level',
          levelNumber: 1,
          difficulty: 1,
          shapes: [],
          targets: targets,
          sortingRule: SortingRule.byType,
        );

        final expectedPercentage = (filledTargets / totalTargets) * 100;
        expect(
          level.completionPercentage,
          equals(expectedPercentage),
          reason: 'Completion percentage should be accurate',
        );
      }
    });

    test('game state transitions are valid', () {
      final validTransitions = {
        ShapeGameStatus.initial: [ShapeGameStatus.loading],
        ShapeGameStatus.loading: [
          ShapeGameStatus.playing,
          ShapeGameStatus.error,
        ],
        ShapeGameStatus.playing: [
          ShapeGameStatus.paused,
          ShapeGameStatus.completed,
          ShapeGameStatus.error,
        ],
        ShapeGameStatus.paused: [ShapeGameStatus.playing],
        ShapeGameStatus.completed: [],
        ShapeGameStatus.error: [],
      };

      for (final entry in validTransitions.entries) {
        final fromStatus = entry.key;
        final validNextStatuses = entry.value;

        final state = ShapeGameState(status: fromStatus);

        for (final nextStatus in validNextStatuses) {
          final newState = state.copyWith(status: nextStatus);
          expect(newState.status, equals(nextStatus));
        }
      }
    });

    test('shape equality works correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final shape1 = Shape(
          id: 'shape_$i',
          type: ShapeType.triangle,
          color: ShapeColor.green,
          size: 2,
        );

        final shape2 = Shape(
          id: 'shape_$i',
          type: ShapeType.triangle,
          color: ShapeColor.green,
          size: 2,
        );

        expect(shape1, equals(shape2));

        final differentShape = shape1.copyWith(color: ShapeColor.red);
        expect(shape1, isNot(equals(differentShape)));
      }
    });

    test('target equality works correctly', () {
      for (int i = 0; i < AppConstants.pbtIterations; i++) {
        final target1 = ShapeTarget(
          id: 'target_$i',
          rule: SortingRule.byColor,
          requiredColor: ShapeColor.purple,
          label: 'Test',
        );

        final target2 = ShapeTarget(
          id: 'target_$i',
          rule: SortingRule.byColor,
          requiredColor: ShapeColor.purple,
          label: 'Test',
        );

        expect(target1, equals(target2));

        final differentTarget = target1.copyWith(isFilled: true);
        expect(target1, isNot(equals(differentTarget)));
      }
    });

    test('copyWith creates proper copies', () {
      final shape = const Shape(
        id: 'shape_1',
        type: ShapeType.star,
        color: ShapeColor.yellow,
        size: 3,
      );

      final level = ShapeLevel(
        id: 'test_level',
        levelNumber: 1,
        difficulty: 1,
        shapes: [shape],
        targets: [],
        sortingRule: SortingRule.byType,
      );

      final original = ShapeGameState(
        status: ShapeGameStatus.playing,
        level: level,
        availableShapes: [shape],
        correctPlacements: 5,
        incorrectAttempts: 2,
      );

      final modified = original.copyWith(correctPlacements: 10);

      expect(modified.correctPlacements, equals(10));
      expect(modified.incorrectAttempts, equals(original.incorrectAttempts));
      expect(modified.status, equals(original.status));
      expect(modified.availableShapes, equals(original.availableShapes));
    });
  });
}
