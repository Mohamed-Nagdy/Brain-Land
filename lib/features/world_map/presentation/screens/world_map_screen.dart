import 'package:brain_land/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../shared/models/zone.dart';
import '../../providers/world_map_provider.dart';
import '../widgets/animated_zone_card.dart';

/// World Map Screen - Main navigation hub for BrainLand
///
/// Displays all four zones with their unlock status and progress
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  @override
  void initState() {
    super.initState();
    // Play main menu music when entering world map
    AudioManager.instance.playMusic(MusicTrack.mainMenu.path);
  }

  @override
  Widget build(BuildContext context) {
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

                // Zone grid - Responsive with landscape support
                Expanded(
                  child: Padding(
                    padding: context.responsivePadding,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getGridColumnCount(context),
                        mainAxisSpacing: context.responsiveSpacing,
                        crossAxisSpacing: context.responsiveSpacing,
                        childAspectRatio: _getChildAspectRatio(context),
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

  /// Get grid column count based on screen size and orientation
  int _getGridColumnCount(BuildContext context) {
    if (context.isLandscape) {
      // In landscape, show more columns
      return context.responsiveValue(
        mobile: 4, // 4 zones fit nicely in a row on landscape mobile
        tablet: 4,
        desktop: 4,
      );
    } else {
      // In portrait, use standard responsive columns
      return context.responsiveValue(mobile: 2, tablet: 3, desktop: 4);
    }
  }

  /// Get child aspect ratio based on screen size and orientation
  double _getChildAspectRatio(BuildContext context) {
    if (context.isLandscape) {
      // In landscape, make cards slightly wider
      return context.responsiveValue(mobile: 0.75, tablet: 0.85, desktop: 0.9);
    } else {
      // In portrait, use standard aspect ratios
      return context.responsiveValue(mobile: 0.85, tablet: 0.9, desktop: 1.0);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final avatarSize = context.responsiveValue(
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
    final iconSize = context.responsiveValue(
      mobile: 32.0,
      tablet: 36.0,
      desktop: 40.0,
    );

    return Container(
      padding: context.responsivePadding,
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRoutes.avatarCustomization),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Center(
                child: Text(
                  '🐼',
                  style: TextStyle(fontSize: avatarSize * 0.53),
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveSpacing),

          // Player stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                      context,
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSpacing * 0.5),
                Row(
                  children: [
                    Text(
                      '⭐',
                      style: TextStyle(
                        fontSize: context.responsiveValue(
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing * 0.5),
                    Text(
                      '0',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing),
                    Text(
                      '🪙',
                      style: TextStyle(
                        fontSize: context.responsiveValue(
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing * 0.5),
                    Text(
                      '0',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress button
          IconButton(
            icon: Icon(Icons.emoji_events, size: iconSize),
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
