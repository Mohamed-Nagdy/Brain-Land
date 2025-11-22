import 'package:adventure_world/core/constants/game_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/text_styles.dart';
import '../../../ads/widgets/banner_ad_widget.dart';
import '../../../progress/providers/progress_provider.dart';
import '../../providers/memory_game_provider.dart';
import '../widgets/winding_memory_path.dart';

/// Memory River Level Selection Screen
/// Shows 1000 levels with blue gradient theme and winding path
class MemoryRiverLevelSelectionScreen extends ConsumerWidget {
  const MemoryRiverLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(memoryLevelsProvider);
    final zoneProgressAsync = ref.watch(zoneProgressProvider('memory_river'));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3), // Blue
              Color(0xFF1976D2), // Dark Blue
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
                        return WindingMemoryPath(
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
            GameAssets.memoryRiverEmoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory River',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Memory Matching',
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
    context.pushNamed('memoryGame', pathParameters: {'levelId': levelId});
  }
}
