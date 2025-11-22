import 'package:adventure_world/core/constants/game_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/text_styles.dart';
import '../../../ads/widgets/banner_ad_widget.dart';
import '../../../progress/providers/progress_provider.dart';
import '../../providers/math_storage_provider.dart';
import '../widgets/winding_level_path.dart';

/// Math Forest Level Selection Screen
/// Shows 1000 levels with green gradient theme and winding path
class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(mathLevelsProvider);
    final zoneProgressAsync = ref.watch(zoneProgressProvider('math_forest'));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4CAF50), // Green
              Color(0xFF2E7D32), // Dark Green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Levels
              Expanded(
                child: levelsAsync.when(
                  data: (levels) {
                    return zoneProgressAsync.when(
                      data: (zoneProgress) {
                        final levelsCompleted =
                            zoneProgress?.levelsCompleted ?? 0;
                        return WindingLevelPath(
                          levels: levels,
                          levelsCompleted: levelsCompleted,
                          onLevelTap: (levelId) =>
                              _navigateToLevel(context, levelId),
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

              // Banner Ad
              const BannerAdWidget(),
              const SizedBox(height: 8),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 12),
          Text(
            GameAssets.mathForestEmoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Math Forest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Number Adventures',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLevel(BuildContext context, String levelId) {
    context.pushNamed('mathGame', pathParameters: {'levelId': levelId});
  }
}
