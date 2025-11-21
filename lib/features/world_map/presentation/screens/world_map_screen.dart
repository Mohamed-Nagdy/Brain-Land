import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../shared/models/zone.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../ads/widgets/banner_ad_widget.dart';
import '../../../ads/widgets/rewarded_ad_button.dart';
import '../../../progress/providers/progress_provider.dart';
import '../../providers/world_map_provider.dart';

/// Modern World Map Screen with child-friendly UI
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _characterController;

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playMusic(MusicTrack.mainMenu.path);

    // Log screen view
    AnalyticsService.instance.setCurrentScreen(screenName: 'world_map');

    // Cloud animation
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Character bounce animation
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(worldMapProvider);
    final totalStarsAsync = ref.watch(totalStarsProvider);
    final totalCoinsAsync = ref.watch(totalCoinsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Floating clouds
          _buildFloatingClouds(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Modern header
                _buildModernHeader(totalStarsAsync, totalCoinsAsync),

                // Rewarded Ad Button (Watch for Coins)
                RewardedAdButton(),

                // Zones grid
                Expanded(
                  child: zonesAsync.when(
                    data: (zones) => _buildModernZonesGrid(zones),
                    loading: () => _buildLoading(),
                    error: (e, s) => _buildError(e.toString()),
                  ),
                ),

                // Banner Ad at bottom
                const BannerAdWidget(),
              ],
            ),
          ),

          // Floating action buttons
          _buildFloatingActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Sky blue
            Color(0xFF98D8E8), // Light blue
            Color(0xFFB0E0E6), // Powder blue
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Stack(
          children: [
            _buildCloud(0, _cloudController.value),
            _buildCloud(1, (_cloudController.value + 0.3) % 1.0),
            _buildCloud(2, (_cloudController.value + 0.6) % 1.0),
          ],
        );
      },
    );
  }

  Widget _buildCloud(int index, double progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    final yPosition = 50.0 + (index * 80.0);
    final xPosition = -100 + (progress * (screenWidth + 200));

    return Positioned(
      left: xPosition,
      top: yPosition,
      child: Opacity(
        opacity: 0.6,
        child: Text('☁️', style: TextStyle(fontSize: 40 + (index * 10))),
      ),
    );
  }

  Widget _buildModernHeader(
    AsyncValue<int> starsAsync,
    AsyncValue<int> coinsAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with glow
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('😊', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explorer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Level 1 🌟',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Stats badges
          _buildModernStatBadge(
            '⭐',
            starsAsync.when(
              data: (stars) => stars.toString(),
              loading: () => '...',
              error: (_, _) => '0',
            ),
            const Color(0xFFFFA726),
          ),
          const SizedBox(width: 8),
          _buildModernStatBadge(
            '🪙',
            coinsAsync.when(
              data: (coins) => coins.toString(),
              loading: () => '...',
              error: (_, _) => '0',
            ),
            const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatBadge(String emoji, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernZonesGrid(List<Zone> zones) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        return _buildModernZoneCard(zone, index);
      },
    );
  }

  Widget _buildModernZoneCard(Zone zone, int index) {
    final progress = zone.completedLevels / zone.totalLevels;
    final colors = _getZoneColors(zone.id);

    return GestureDetector(
      onTap: () => _navigateToZone(context, zone.id),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Progress ring
                  Positioned(
                    top: 12,
                    right: 12,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 4,
                      ),
                    ),
                  ),

                  // Zone content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Zone emoji
                        Text(
                          _getZoneEmoji(zone.id),
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 12),

                        // Zone name
                        Text(
                          zone.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Progress text
                        Text(
                          '${zone.completedLevels}/${zone.totalLevels}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(
        'Oops! $message',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  List<Color> _getZoneColors(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return [const Color(0xFF6D4C41), const Color(0xFF5D4037)];
      case 'logic_mountain':
        return [const Color(0xFF64B5F6), const Color(0xFF42A5F5)];
      case 'memory_river':
        return [const Color(0xFF00BCD4), const Color(0xFF0097A7)];
      case 'shape_valley':
        return AppColors.shapeValleyGradient.colors;
      default:
        return [Colors.grey, Colors.grey.shade700];
    }
  }

  String _getZoneEmoji(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return '🌲';
      case 'logic_mountain':
        return '⛰️';
      case 'memory_river':
        return '🌊';
      case 'shape_valley':
        return '⬡';
      default:
        return '❓';
    }
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Positioned(
      bottom: 70,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              // // Settings button
              // _buildFancyFAB(
              //   emoji: '⚙️',
              //   label: 'Settings',
              //   colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              //   onTap: () => context.push('/settings'),
              // ),
              // Daily Rewards button (center)
              _buildFancyFAB(
                emoji: '🎁',
                label: 'Rewards',
                colors: [const Color(0xFFFFD700), const Color(0xFFFFC371)],
                onTap: () => context.pushNamed("dailyReward"),
              ),
              // Progress button
              _buildFancyFAB(
                emoji: '📊',
                label: 'Progress',
                colors: [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                onTap: () => context.push('/progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFancyFAB({
    required String emoji,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
}
