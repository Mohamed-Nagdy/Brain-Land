import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../shared/widgets/fancy_button.dart';
import '../../../../shared/widgets/fancy_card.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/math_game_state.dart';
import '../../providers/math_game_provider.dart';
import '../widgets/celebration_widget.dart';
import '../widgets/forest_widgets.dart';

/// Level Complete Screen showing results and rewards
/// Features:
/// - Stars earned with animation
/// - Accuracy percentage
/// - Time taken
/// - Next Level and Retry buttons
/// - Reward chest trigger if applicable
class LevelCompleteScreen extends ConsumerStatefulWidget {
  final String levelId;

  const LevelCompleteScreen({super.key, required this.levelId});

  @override
  ConsumerState<LevelCompleteScreen> createState() =>
      _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends ConsumerState<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isChestOpen = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Play level complete sound
    AudioManager.instance.playSound(SoundEffect.levelComplete.path);

    // Start animation
    _animationController.forward();

    // Open chest after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isChestOpen = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(mathGameProvider(widget.levelId));

    // If game is not completed, show loading or error
    if (gameState.status != GameStatus.completed) {
      return Scaffold(
        body: GradientBackground(
          gradient: AppColors.mathForestGradient,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final accuracy = gameState.accuracy;
    final starsEarned = _calculateStars(accuracy);
    final shouldShowRewardChest = accuracy >= 0.9; // 90% accuracy

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.mathForestGradient,
        child: SafeArea(
          child: Stack(
            children: [
              // Celebration animation
              const Positioned.fill(child: CelebrationWidget()),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Level Complete!',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Results card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: FancyCard(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // Stars display
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: _buildStarsDisplay(starsEarned),
                              ),

                              const SizedBox(height: 32),

                              // Stats
                              _buildStatRow(
                                'Accuracy',
                                '${(accuracy * 100).round()}%',
                                Icons.check_circle,
                              ),
                              const SizedBox(height: 16),
                              _buildStatRow(
                                'Correct Answers',
                                '${gameState.correctAnswers}',
                                Icons.star,
                              ),
                              const SizedBox(height: 16),
                              _buildStatRow(
                                'Time Taken',
                                _formatTime(gameState),
                                Icons.timer,
                              ),

                              // Reward chest
                              if (shouldShowRewardChest) ...[
                                const SizedBox(height: 24),
                                TreasureChest(
                                  isOpen: _isChestOpen,
                                  onTap: () {
                                    if (!_isChestOpen) {
                                      setState(() => _isChestOpen = true);
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reward Unlocked!',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.starGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),

                      // Action buttons
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Next Level button
                            FancyButton(
                              text: 'Next Level',
                              icon: Icons.arrow_forward,
                              gradient: AppColors.buttonSuccessGradient,
                              onPressed: _handleNextLevel,
                            ),

                            const SizedBox(height: 16),

                            // Retry button
                            FancyButton(
                              text: 'Retry',
                              icon: Icons.refresh,
                              gradient: AppColors.buttonPrimaryGradient,
                              onPressed: _handleRetry,
                              isSmall: true,
                            ),

                            const SizedBox(height: 16),

                            // Back to levels button
                            TextButton(
                              onPressed: _handleBackToLevels,
                              child: Text(
                                'Back to Levels',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarsDisplay(int starsEarned) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isEarned = index < starsEarned;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            isEarned ? Icons.star : Icons.star_border,
            color: isEarned ? AppColors.starGold : AppColors.textSecondary,
            size: 64,
          ),
        );
      }),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mathForestGreen, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  int _calculateStars(double accuracy) {
    if (accuracy >= 0.9) {
      return 3;
    } else if (accuracy >= 0.7) {
      return 2;
    } else if (accuracy >= 0.5) {
      return 1;
    } else {
      return 0;
    }
  }

  String _formatTime(MathGameState gameState) {
    if (gameState.startTime == null) return '--:--';

    final duration = DateTime.now().difference(gameState.startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleNextLevel() {
    // Extract level number from levelId (e.g., "math_level_1" -> 1)
    final levelNumber = int.tryParse(widget.levelId.split('_').last) ?? 1;
    final nextLevelId = 'math_level_${levelNumber + 1}';

    // Reset current game state
    ref.read(mathGameProvider(widget.levelId).notifier).resetGame();

    // Navigate to next level
    context.go('/math-forest/game/$nextLevelId');
  }

  void _handleRetry() {
    // Reset game state
    ref.read(mathGameProvider(widget.levelId).notifier).resetGame();

    // Navigate back to the same level
    context.go('/math-forest/game/${widget.levelId}');
  }

  void _handleBackToLevels() {
    // Reset game state
    ref.read(mathGameProvider(widget.levelId).notifier).resetGame();

    // Navigate to level selection
    context.go(AppRoutes.mathForestLevels);
  }
}
