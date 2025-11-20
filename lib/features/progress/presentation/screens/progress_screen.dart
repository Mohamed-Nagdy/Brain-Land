import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/progress_provider.dart';
import '../../providers/streak_provider.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/stats_card.dart';
import '../widgets/streak_display.dart';

/// Screen that displays player progress, achievements, and streak
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final streakCalendarAsync = ref.watch(streakCalendarProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: progressAsync.when(
            data: (progress) {
              return CustomScrollView(
                slivers: [
                  // App bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    title: const Text(
                      'My Progress',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stats cards
                        _buildStatsSection(progress),
                        const SizedBox(height: 24),
                        // Streak display
                        streakCalendarAsync.when(
                          data: (calendar) => StreakDisplay(
                            currentStreak: progress.currentStreak,
                            streakDates: calendar,
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 24),
                        // Zone progress section
                        _buildZoneProgressSection(progress),
                        const SizedBox(height: 24),
                        // Unlocked items section
                        _buildUnlockedItemsSection(progress),
                        const SizedBox(height: 24),
                        // Achievement badges section
                        _buildAchievementsSection(progress),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading progress: $error')),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(progress) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            label: 'Total Stars',
            value: progress.totalStars,
            icon: Icons.star,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            label: 'Total Coins',
            value: progress.totalCoins,
            icon: Icons.monetization_on,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneProgressSection(progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zone Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: progress.zoneProgress.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Start playing to see your progress!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: progress.zoneProgress.entries.map((entry) {
                    final zoneId = entry.key;
                    final zoneProgress = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildZoneProgressCard(
                        zoneId,
                        zoneProgress.levelsCompleted,
                        zoneProgress.totalStars,
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildZoneProgressCard(String zoneId, int levelsCompleted, int stars) {
    final zoneName = _getZoneName(zoneId);
    final zoneColor = _getZoneColor(zoneId);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: zoneColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getZoneIcon(zoneId), color: zoneColor, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zoneName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$levelsCompleted levels • $stars stars',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedItemsSection(progress) {
    final totalItems =
        progress.unlockedPets.length +
        progress.unlockedStickers.length +
        progress.unlockedAvatarItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unlocked Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildItemRow(
                'Pets',
                progress.unlockedPets.length,
                Icons.pets,
                Colors.purple,
              ),
              const Divider(height: 24),
              _buildItemRow(
                'Stickers',
                progress.unlockedStickers.length,
                Icons.emoji_emotions,
                Colors.pink,
              ),
              const Divider(height: 24),
              _buildItemRow(
                'Avatar Items',
                progress.unlockedAvatarItems.length,
                Icons.checkroom,
                Colors.blue,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$totalItems',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(String label, int count, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(progress) {
    // Sample achievements - in a real app, these would come from a service
    final achievements = [
      _Achievement(
        name: 'First Steps',
        description: 'Complete your first level',
        icon: Icons.flag,
        isUnlocked: progress.totalStars > 0,
        color: Colors.green,
      ),
      _Achievement(
        name: 'Star Collector',
        description: 'Earn 50 stars',
        icon: Icons.star,
        isUnlocked: progress.totalStars >= 50,
        color: Colors.amber,
      ),
      _Achievement(
        name: 'Dedicated',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department,
        isUnlocked: progress.currentStreak >= 7,
        color: Colors.orange,
      ),
      _Achievement(
        name: 'Collector',
        description: 'Unlock 10 items',
        icon: Icons.collections,
        isUnlocked:
            (progress.unlockedPets.length +
                progress.unlockedStickers.length +
                progress.unlockedAvatarItems.length) >=
            10,
        color: Colors.purple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: achievements
                .map(
                  (achievement) => AchievementBadge(
                    name: achievement.name,
                    description: achievement.description,
                    icon: achievement.icon,
                    isUnlocked: achievement.isUnlocked,
                    color: achievement.color,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  String _getZoneName(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return 'Math Forest';
      case 'logic_mountain':
        return 'Logic Mountain';
      case 'memory_river':
        return 'Memory River';
      case 'shape_valley':
        return 'Shape Valley';
      default:
        return zoneId;
    }
  }

  Color _getZoneColor(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return Colors.green;
      case 'logic_mountain':
        return Colors.blue;
      case 'memory_river':
        return Colors.purple;
      case 'shape_valley':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getZoneIcon(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return Icons.calculate;
      case 'logic_mountain':
        return Icons.psychology;
      case 'memory_river':
        return Icons.memory;
      case 'shape_valley':
        return Icons.category;
      default:
        return Icons.help;
    }
  }
}

class _Achievement {
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  _Achievement({
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}
