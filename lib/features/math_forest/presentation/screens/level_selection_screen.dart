import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../progress/providers/progress_provider.dart';
import '../../models/math_level.dart';
import '../../providers/math_storage_provider.dart';
import '../widgets/winding_level_path.dart';

/// Level Selection Screen for Math Forest zone
/// Displays a grid of level cards with stars earned and unlock status
class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(mathLevelsProvider);
    final zoneProgressAsync = ref.watch(zoneProgressProvider('math_forest'));

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
                  data: (levels) {
                    return zoneProgressAsync.when(
                      data: (zoneProgress) {
                        final levelsCompleted =
                            zoneProgress?.levelsCompleted ?? 0;
                        debugPrint('DEBUG: levelsCompleted=$levelsCompleted');
                        return _buildLevelsGrid(
                          context,
                          levels,
                          levelsCompleted,
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error loading progress: $error',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
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

  Widget _buildLevelsGrid(
    BuildContext context,
    List<MathLevel> levels,
    int levelsCompleted,
  ) {
    return WindingLevelPath(
      levels: levels,
      levelsCompleted: levelsCompleted,
      onLevelTap: (levelId) => _navigateToLevel(context, levelId),
    );
  }

  void _navigateToLevel(BuildContext context, String levelId) {
    context.pushNamed('mathGame', pathParameters: {'levelId': levelId});
  }
}
