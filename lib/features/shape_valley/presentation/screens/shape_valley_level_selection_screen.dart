import 'package:brain_land/core/constants/game_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../ads/widgets/banner_ad_widget.dart';
import '../../../progress/providers/progress_provider.dart';
import '../../providers/shape_game_provider.dart';
import '../widgets/winding_shape_path.dart';

/// Shape Valley Level Selection Screen
/// Shows 1000 levels with orange gradient theme and winding path
class ShapeValleyLevelSelectionScreen extends ConsumerWidget {
  const ShapeValleyLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(shapeLevelsProvider);
    final zoneProgressAsync = ref.watch(zoneProgressProvider('shape_valley'));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.shapeValleyGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: levelsAsync.when(
                  data: (levels) {
                    return zoneProgressAsync.when(
                      data: (zoneProgress) {
                        final levelsCompleted =
                            zoneProgress?.levelsCompleted ?? 0;
                        return WindingShapePath(
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
            GameAssets.shapeValleyEmoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shape Valley',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Shape Sorting',
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
    context.pushNamed('shapeGame', pathParameters: {'levelId': levelId});
  }
}
