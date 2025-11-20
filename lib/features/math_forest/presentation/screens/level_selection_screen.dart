import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/fancy_card.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/math_level.dart';
import '../../providers/math_storage_provider.dart';

/// Level Selection Screen for Math Forest zone
/// Displays a grid of level cards with stars earned and unlock status
class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(mathLevelsProvider);

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.mathForestGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Levels Grid
              Expanded(
                child: levelsAsync.when(
                  data: (levels) => _buildLevelsGrid(context, levels),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading levels: $error',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Math Forest',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'Choose a level to play',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsGrid(BuildContext context, List<MathLevel> levels) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = _isLevelUnlocked(levels, index);
        return _LevelCard(
          level: level,
          isUnlocked: isUnlocked,
          onTap: isUnlocked ? () => _navigateToLevel(context, level.id) : null,
        );
      },
    );
  }

  bool _isLevelUnlocked(List<MathLevel> levels, int index) {
    // First level is always unlocked
    if (index == 0) return true;

    // Level is unlocked if previous level is completed
    if (index > 0 && index < levels.length) {
      return levels[index - 1].isCompleted;
    }

    return false;
  }

  void _navigateToLevel(BuildContext context, String levelId) {
    context.push('/math-forest/game/$levelId');
  }
}

/// Individual level card widget
class _LevelCard extends StatelessWidget {
  final MathLevel level;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, required this.isUnlocked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedFancyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: isUnlocked
          ? Colors.white
          : Colors.white.withValues(alpha: 0.5),
      child: Stack(
        children: [
          // Level content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level number
              Text(
                '${level.levelNumber}',
                style: AppTextStyles.gameNumber.copyWith(
                  color: isUnlocked
                      ? AppColors.mathForestGreen
                      : AppColors.textDisabled,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 8),

              // Stars earned
              if (isUnlocked) _buildStars(),

              // Lock icon for locked levels
              if (!isUnlocked)
                Icon(Icons.lock, color: AppColors.lockGray, size: 32),
            ],
          ),

          // Completion checkmark
          if (level.isCompleted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isEarned = index < level.starsEarned;
        return Icon(
          isEarned ? Icons.star : Icons.star_border,
          color: isEarned ? AppColors.starGold : AppColors.textSecondary,
          size: 20,
        );
      }),
    );
  }
}
