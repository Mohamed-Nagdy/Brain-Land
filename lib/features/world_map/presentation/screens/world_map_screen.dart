import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/models/zone.dart';
import '../../providers/world_map_provider.dart';
import '../widgets/animated_zone_card.dart';

/// World Map Screen - Main navigation hub for BrainLand
///
/// Displays all four zones with their unlock status and progress
class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(worldMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: zonesAsync.when(
            data: (zones) => Column(
              children: [
                // Header with player info
                _buildHeader(context),

                // Zone grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: zones.length,
                      itemBuilder: (context, index) {
                        final zone = zones[index];
                        return AnimatedZoneCard(
                          zone: zone,
                          onTap: () => _navigateToZone(context, zone),
                        );
                      },
                    ),
                  ),
                ),

                // Bottom navigation
                _buildBottomNav(context),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(error.toString(), style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToZone(BuildContext context, Zone zone) {
    switch (zone.type) {
      case ZoneType.mathForest:
        context.push(AppRoutes.mathForestLevels);
        break;
      case ZoneType.logicMountain:
        context.push(AppRoutes.logicMountainLevels);
        break;
      case ZoneType.memoryRiver:
        context.push(AppRoutes.memoryRiverLevels);
        break;
      case ZoneType.shapeValley:
        context.push(AppRoutes.shapeValleyLevels);
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRoutes.avatarCustomization),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Center(
                child: Text('🐼', style: TextStyle(fontSize: 32)),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Player stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back!', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '0',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '0',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress button
          IconButton(
            icon: const Icon(Icons.emoji_events, size: 32),
            color: AppColors.warningYellow,
            onPressed: () => context.push(AppRoutes.progress),
            tooltip: 'View Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(
            icon: Icons.map,
            label: 'Map',
            isActive: true,
            onTap: () {},
          ),
          _buildNavButton(
            icon: Icons.pets,
            label: 'Pets',
            isActive: false,
            onTap: () => context.push(AppRoutes.petCollection),
          ),
          _buildNavButton(
            icon: Icons.card_giftcard,
            label: 'Daily',
            isActive: false,
            onTap: () => context.push(AppRoutes.dailyReward),
          ),
          _buildNavButton(
            icon: Icons.person,
            label: 'Avatar',
            isActive: false,
            onTap: () => context.push(AppRoutes.avatarCustomization),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
