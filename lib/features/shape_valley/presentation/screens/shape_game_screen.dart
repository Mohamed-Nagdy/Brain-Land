import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/shape.dart';
import '../../models/shape_game_state.dart';
import '../../providers/shape_game_provider.dart';
import '../widgets/draggable_shape.dart';
import '../widgets/shape_target.dart';

/// Shape Game Screen where players sort shapes into correct targets
/// Features:
/// - Display shapes to sort
/// - Show target zones
/// - Drag-and-drop logic
/// - Completion detection
/// - Timer display (if time limit exists)
class ShapeGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const ShapeGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends ConsumerState<ShapeGameScreen> {
  String? _hoveredTargetId;

  @override
  void initState() {
    super.initState();
    // Start the level when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shapeGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(shapeGameProvider(widget.levelId));

    // Listen for level completion and navigate
    ref.listen<ShapeGameState>(shapeGameProvider(widget.levelId), (
      previous,
      next,
    ) {
      if (next.status == ShapeGameStatus.completed &&
          previous?.status != ShapeGameStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToLevelComplete();
          }
        });
      }
    });

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.shapeValleyGradient,
        child: SafeArea(
          child: gameState.status == ShapeGameStatus.loading
              ? _buildLoadingState()
              : gameState.status == ShapeGameStatus.error
              ? _buildErrorState(gameState.errorMessage ?? 'Unknown error')
              : gameState.status == ShapeGameStatus.playing ||
                    gameState.status == ShapeGameStatus.paused
              ? _buildGameState(gameState)
              : _buildInitialState(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildGameState(ShapeGameState gameState) {
    if (gameState.level == null) {
      return _buildErrorState('Level not found');
    }

    return Column(
      children: [
        // Header with stats and pause button
        _buildHeader(gameState),

        const SizedBox(height: 16),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _getInstructions(gameState.level!.sortingRule),
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Target zones
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTargetsGrid(gameState),
          ),
        ),

        const SizedBox(height: 16),

        // Available shapes to drag
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Drag shapes to sort them',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAvailableShapes(gameState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ShapeGameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => _showExitDialog(),
          ),

          // Stats
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard(
                  icon: Icons.check_circle,
                  value:
                      '${gameState.correctPlacements}/${gameState.level!.targets.length}',
                  label: 'Sorted',
                ),
                const SizedBox(width: 16),
                if (gameState.level!.timeLimit > 0)
                  _buildStatCard(
                    icon: Icons.timer,
                    value: _formatTime(gameState.timeRemaining),
                    label: 'Time',
                  ),
              ],
            ),
          ),

          // Pause button
          IconButton(
            icon: Icon(
              gameState.status == ShapeGameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              if (gameState.status == ShapeGameStatus.paused) {
                ref
                    .read(shapeGameProvider(widget.levelId).notifier)
                    .resumeGame();
              } else {
                ref
                    .read(shapeGameProvider(widget.levelId).notifier)
                    .pauseGame();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsGrid(ShapeGameState gameState) {
    final targets = gameState.level!.targets;
    final crossAxisCount = targets.length <= 4 ? 2 : 3;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: targets.length,
      itemBuilder: (context, index) {
        final target = targets[index];
        final placedShape = gameState.getShapeInTarget(target.id);

        return ShapeTargetWidget(
          target: target,
          placedShape: placedShape,
          isHighlighted: _hoveredTargetId == target.id,
          onShapeDropped: (shape) {
            ref
                .read(shapeGameProvider(widget.levelId).notifier)
                .placeShape(target.id);
            setState(() {
              _hoveredTargetId = null;
            });
          },
          onShapeRemoved: placedShape != null
              ? () {
                  ref
                      .read(shapeGameProvider(widget.levelId).notifier)
                      .removeShapeFromTarget(target.id);
                }
              : null,
        );
      },
    );
  }

  Widget _buildAvailableShapes(ShapeGameState gameState) {
    if (gameState.availableShapes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'All shapes sorted! 🎉',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: gameState.availableShapes.map((shape) {
        return DraggableShape(
          shape: shape,
          onDragStarted: () {
            ref
                .read(shapeGameProvider(widget.levelId).notifier)
                .startDrag(shape);
          },
          onDragEnd: () {
            ref.read(shapeGameProvider(widget.levelId).notifier).cancelDrag();
          },
        );
      }).toList(),
    );
  }

  String _getInstructions(SortingRule rule) {
    switch (rule) {
      case SortingRule.byType:
        return 'Sort shapes by their type';
      case SortingRule.byColor:
        return 'Sort shapes by their color';
      case SortingRule.bySize:
        return 'Sort shapes by their size';
      case SortingRule.byTypeAndColor:
        return 'Sort shapes by type and color';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Level?'),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _navigateToLevelComplete() {
    final gameState = ref.read(shapeGameProvider(widget.levelId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text('Level Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  Icons.star,
                  color: index < (gameState.level?.starsEarned ?? 0)
                      ? Colors.amber
                      : Colors.grey.shade300,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Accuracy: ${gameState.accuracy.toStringAsFixed(1)}%',
              style: AppTextStyles.bodyLarge,
            ),
            Text(
              'Correct: ${gameState.correctPlacements}/${gameState.level?.targets.length ?? 0}',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Exit game
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Exit game
              // Navigate to next level
              final nextLevelNumber = (gameState.level?.levelNumber ?? 0) + 1;
              context.pushNamed(
                'shapeGame',
                pathParameters: {'levelId': 'shape_$nextLevelNumber'},
              );
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }
}
