import 'package:brain_land/core/router/app_router.dart';
import 'package:brain_land/core/utils/audio_manager.dart';
import 'package:brain_land/core/utils/responsive_utils.dart';
import 'package:brain_land/features/progress/providers/progress_provider.dart';
import 'package:brain_land/features/world_map/providers/zone_unlock_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/models/zone.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/world_map_provider.dart';
import '../widgets/animated_zone_card.dart';

/// Main World Map Screen where players choose which zone to play
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  @override
  void initState() {
    super.initState();
    // Play main menu music
    AudioManager.instance.playMusic(MusicTrack.mainMenu.path);
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(worldMapProvider);
    final unlockedZonesAsync = ref.watch(zoneUnlockProvider);
    final totalStarsAsync = ref.watch(totalStarsProvider);
    final totalCoinsAsync = ref.watch(totalCoinsProvider);

    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.worldMapGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Header with player stats
              _buildHeader(context, totalStarsAsync, totalCoinsAsync),

              // Map content
              Expanded(
                child: zonesAsync.when(
                  data: (zones) {
                    return unlockedZonesAsync.when(
                      data: (unlockedZoneIds) {
                        return _buildZonesGrid(context, zones, unlockedZoneIds);
                      },
                      loading: () => _buildLoading(),
                      error: (e, s) => _buildError(e.toString()),
                    );
                  },
                  loading: () => _buildLoading(),
                  error: (e, s) => _buildError(e.toString()),
                ),
              ),

              // Bottom navigation for other features
              _buildBottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<int> starsAsync,
    AsyncValue<int> coinsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Avatar (placeholder)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.face, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          // Player Name and Level (placeholder)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explorer',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
              Text(
                'Level 1',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Stats
          Row(
            children: [
              _buildStatBadge(
                Icons.star,
                AppColors.starGold,
                starsAsync.when(
                  data: (stars) => stars.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
              ),
              const SizedBox(width: 8),
              _buildStatBadge(
                Icons.monetization_on,
                AppColors.coinGold,
                coinsAsync.when(
                  data: (coins) => coins.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, Color color, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesGrid(
    BuildContext context,
    List<Zone> zones,
    List<String> unlockedZoneIds,
  ) {
    // Responsive grid layout
    final crossAxisCount = context.responsiveValue(
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    final spacing = context.responsiveValue(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.5,
      ),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        final isUnlocked = unlockedZoneIds.contains(zone.id);

        // Create a copy of the zone with the correct unlocked status
        // This ensures the UI reflects the actual unlock status from the provider
        final zoneWithStatus = zone.copyWith(isUnlocked: isUnlocked);

        return AnimatedZoneCard(
          zone: zoneWithStatus,
          onTap: () => _navigateToZone(context, zone.id),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(
        'Error loading map: $message',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            Icons.pets,
            'Pets',
            () => _navigateToFeature(context, '/pets'),
          ),
          _buildNavItem(
            context,
            Icons.calendar_today,
            'Daily',
            () => _navigateToFeature(context, AppRoutes.dailyReward),
          ),
          _buildNavItem(
            context,
            Icons.checkroom,
            'Avatar',
            () => _navigateToFeature(context, '/avatar'),
          ),
          _buildNavItem(
            context,
            Icons.settings,
            'Settings',
            () => _navigateToFeature(context, '/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // Ensure minimum touch target size for children
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToZone(BuildContext context, String zoneId) {
    // Map zone IDs to route paths
    final routeMap = {
      'math_forest': '/math-forest',
      'logic_mountain': '/logic-mountain',
      'memory_river': '/memory-river',
      'shape_valley': '/shape-valley',
    };

    final route = routeMap[zoneId];
    if (route != null) {
      context.push(route);
    }
  }

  void _navigateToFeature(BuildContext context, String route) {
    // Navigate to implemented features
    context.push(route);
  }
}
