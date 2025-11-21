import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../features/ads/services/interstitial_ad_service.dart';
import '../../models/shape_game_state.dart';
import '../../providers/shape_game_provider.dart';
import '../widgets/draggable_shape.dart';
import '../widgets/shape_target.dart';

/// Shape Valley Game Screen
/// Players sort shapes into correct targets
class ShapeGameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const ShapeGameScreen({super.key, required this.levelId});

  @override
  ConsumerState<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends ConsumerState<ShapeGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  final InterstitialAdService _adService = InterstitialAdService();
  String? _hintTargetId;
  String? _hintShapeId;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Load Interstitial Ad
    _adService.loadAd();

    // Start the level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shapeGameProvider(widget.levelId).notifier).startLevel();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _adService.dispose();
    super.dispose();
  }

  Future<void> _showHint() async {
    if (_hintTargetId != null) return;

    final gameState = ref.read(shapeGameProvider(widget.levelId));
    final availableShapes = gameState.availableShapes;

    if (availableShapes.isEmpty) return;

    // Find a target for the first available shape
    final shape = availableShapes.first;
    final targets = gameState.level?.targets ?? [];
    if (targets.isEmpty) return;

    final target = targets.firstWhere(
      (t) => t.accepts(shape),
      orElse: () => targets.first,
    );

    setState(() {
      _hintTargetId = target.id;
      _hintShapeId = shape.id;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _hintTargetId = null;
        _hintShapeId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(shapeGameProvider(widget.levelId));

    // Listen for level completion
    ref.listen<ShapeGameState>(shapeGameProvider(widget.levelId), (
      previous,
      next,
    ) async {
      if (next.status == ShapeGameStatus.completed &&
          previous?.status != ShapeGameStatus.completed) {
        _confettiController.forward();

        // Show Ad before level complete dialog
        await _adService.show();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToLevelComplete();
          }
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(gradient: AppColors.shapeValleyGradient),
          ),

          // Game Content
          SafeArea(
            child: gameState.status == ShapeGameStatus.loading
                ? _buildLoadingState()
                : gameState.status == ShapeGameStatus.error
                ? _buildErrorState(gameState.errorMessage ?? 'Unknown error')
                : _buildGameContent(gameState),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shapeValleyOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent(ShapeGameState gameState) {
    if (gameState.level == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Header
        _buildHeader(gameState),

        // Drop Targets Area
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: gameState.level!.targets.map((target) {
                  final placedShape = gameState.getShapeInTarget(target.id);

                  return ShapeTargetWidget(
                    target: target,
                    placedShape: placedShape,
                    isHighlighted: target.id == _hintTargetId,
                    onShapeDropped: (shape) {
                      ref
                          .read(shapeGameProvider(widget.levelId).notifier)
                          .placeShape(target.id);
                    },
                    onShapeRemoved: () {
                      if (placedShape != null) {
                        ref
                            .read(shapeGameProvider(widget.levelId).notifier)
                            .removeShapeFromTarget(target.id);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Shapes Source Area
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drag shapes to match!',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: gameState.availableShapes
                          .map(
                            (shape) => DraggableShape(
                              shape: shape,
                              isHighlighted: shape.id == _hintShapeId,
                              isEnabled:
                                  gameState.status == ShapeGameStatus.playing,
                              onDragStarted: () {
                                ref
                                    .read(
                                      shapeGameProvider(
                                        widget.levelId,
                                      ).notifier,
                                    )
                                    .startDrag(shape);
                              },
                              onDragEnd: () {
                                ref
                                    .read(
                                      shapeGameProvider(
                                        widget.levelId,
                                      ).notifier,
                                    )
                                    .cancelDrag();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ShapeGameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Back Button
          _buildCircleButton(
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFFFF6B9D), // Coral Pink
            onPressed: () => _showExitDialog(),
          ),

          const Spacer(),

          // Stats
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem(
                emoji: '✨',
                value:
                    '${gameState.correctPlacements}/${gameState.level!.shapes.length}',
                color: const Color(0xFFFFA726), // Orange
              ),
              if (gameState.level!.timeLimit > 0) ...[
                const SizedBox(width: 8),
                _buildStatItem(
                  emoji: '⏱️',
                  value: _formatTime(gameState.timeRemaining),
                  color: gameState.timeRemaining <= 10
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF66BB6A),
                  pulse: gameState.timeRemaining <= 10,
                ),
              ],
            ],
          ),

          const Spacer(),

          // Hint Button
          _buildCircleButton(
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFFFFD700), // Gold
            onPressed: _showHint,
          ),

          const SizedBox(width: 8),

          // Pause Button
          _buildCircleButton(
            icon: gameState.status == ShapeGameStatus.paused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            color: const Color(0xFFAB47BC), // Purple
            onPressed: () => _togglePause(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required Color color,
    bool pulse = false,
  }) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (pulse) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        onEnd: () {
          if (mounted) setState(() {});
        },
        child: content,
      );
    }

    return content;
  }

  void _togglePause() {
    final notifier = ref.read(shapeGameProvider(widget.levelId).notifier);
    final state = ref.read(shapeGameProvider(widget.levelId));

    if (state.status == ShapeGameStatus.paused) {
      notifier.resumeGame();
    } else {
      notifier.pauseGame();
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😴', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Game Paused',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to continue?',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    label: 'Exit',
                    color: const Color(0xFFFF5252), // Red
                    icon: Icons.close_rounded,
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                  ),
                  _buildDialogButton(
                    label: 'Resume',
                    color: const Color(0xFF66BB6A), // Green
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      context.pop();
                      ref
                          .read(shapeGameProvider(widget.levelId).notifier)
                          .resumeGame();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤔', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Give Up?',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will lose your progress!',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    label: 'Stay',
                    color: const Color(0xFF42A5F5), // Blue
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.pop(),
                  ),
                  _buildDialogButton(
                    label: 'Leave',
                    color: const Color(0xFFFF5252), // Red
                    icon: Icons.exit_to_app_rounded,
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLevelComplete() {
    final gameState = ref.read(shapeGameProvider(widget.levelId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                'Awesome!',
                style: AppTextStyles.heading1.copyWith(
                  color: const Color(0xFFFFD700), // Gold
                  shadows: [
                    const Shadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rounded,
                      color: index < (gameState.level?.starsEarned ?? 0)
                          ? const Color(0xFFFFD700)
                          : Colors.grey.shade200,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 24)),
                        Text(
                          '${gameState.correctPlacements}',
                          style: AppTextStyles.heading3,
                        ),
                        Text('Shapes', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Column(
                      children: [
                        const Text('⏱️', style: TextStyle(fontSize: 24)),
                        Text(
                          _formatTime(gameState.timeSpent),
                          style: AppTextStyles.heading3,
                        ),
                        Text('Time', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      label: 'Back',
                      color: Colors.grey.shade400,
                      icon: Icons.arrow_back_rounded,
                      onPressed: () {
                        context.pop();
                        context.pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDialogButton(
                      label: 'Next',
                      color: const Color(0xFF66BB6A),
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        context.pop();
                        context.pop();
                        final nextLevelNumber =
                            (gameState.level?.levelNumber ?? 0) + 1;
                        context.pushNamed(
                          'shapeGame',
                          pathParameters: {'levelId': 'shape_$nextLevelNumber'},
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
