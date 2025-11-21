import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/progress_provider.dart';
import '../../providers/streak_provider.dart';
import '../widgets/streak_display.dart';

/// Screen that displays player progress, achievements, and streak
/// with child-friendly fancy design
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final streakCalendarAsync = ref.watch(streakCalendarProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FACFE), // Light blue
              Color(0xFF00F2FE), // Cyan
              Color(0xFF43E97B), // Green
              Color(0xFF38F9D7), // Turquoise
            ],
          ),
        ),
        child: SafeArea(
          child: progressAsync.when(
            data: (progress) {
              return Column(
                children: [
                  // Custom header
                  _buildHeader(context),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Animated trophy emoji
                          _buildAnimatedTrophy(),
                          const SizedBox(height: 24),

                          // Stats cards
                          _buildStatsSection(progress),
                          const SizedBox(height: 24),

                          // Streak display
                          streakCalendarAsync.when(
                            data: (calendar) => _buildStreakCard(
                              progress.currentStreak,
                              calendar,
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
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
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Oops! $error',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title with pulsing icon
          Expanded(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.2);
                    return Transform.scale(
                      scale: scale,
                      child: const Text('📊', style: TextStyle(fontSize: 32)),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'My Progress',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTrophy() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final float = math.sin(_floatingController.value * math.pi) * 15;
        return Transform.translate(
          offset: Offset(0, float),
          child: const Text('🏆', style: TextStyle(fontSize: 80)),
        );
      },
    );
  }

  Widget _buildStatsSection(progress) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            emoji: '⭐',
            label: 'Stars',
            value: progress.totalStars.toString(),
            colors: [const Color(0xFFFFA726), const Color(0xFFFFD54F)],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            emoji: '🪙',
            label: 'Coins',
            value: progress.totalCoins.toString(),
            colors: [const Color(0xFFFFD700), const Color(0xFFFFC371)],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String label,
    required String value,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak, List<DateTime> calendar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '$currentStreak days',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreakDisplay(currentStreak: currentStreak, streakDates: calendar),
        ],
      ),
    );
  }

  Widget _buildZoneProgressSection(progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎯', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                'Zone Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          progress.zoneProgress.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Start playing to see your progress! 🚀',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: progress.zoneProgress.entries.map<Widget>((entry) {
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
        ],
      ),
    );
  }

  Widget _buildZoneProgressCard(String zoneId, int levelsCompleted, int stars) {
    final zoneName = _getZoneName(zoneId);
    final zoneColor = _getZoneColor(zoneId);
    final zoneEmoji = _getZoneEmoji(zoneId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            zoneColor.withValues(alpha: 0.2),
            zoneColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: zoneColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(zoneEmoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zoneName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$levelsCompleted levels • $stars ⭐',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedItemsSection(progress) {
    final totalItems =
        progress.unlockedPets.length +
        progress.unlockedStickers.length +
        progress.unlockedAvatarItems.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎁', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                'Unlocked Items',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildItemRow(
            '🐾 Pets',
            progress.unlockedPets.length,
            const Color(0xFF9B59B6),
          ),
          const SizedBox(height: 12),
          _buildItemRow(
            '😊 Stickers',
            progress.unlockedStickers.length,
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 12),
          _buildItemRow(
            '👕 Avatar Items',
            progress.unlockedAvatarItems.length,
            const Color(0xFF3498DB),
          ),
          const Divider(height: 24, thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Items 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalItems',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(progress) {
    final achievements = [
      _Achievement(
        name: 'First Steps',
        description: 'Complete your first level',
        emoji: '🚀',
        isUnlocked: progress.totalStars > 0,
        colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      ),
      _Achievement(
        name: 'Star Collector',
        description: 'Earn 50 stars',
        emoji: '⭐',
        isUnlocked: progress.totalStars >= 50,
        colors: [const Color(0xFFFFA726), const Color(0xFFFFD54F)],
      ),
      _Achievement(
        name: 'Dedicated',
        description: 'Maintain a 7-day streak',
        emoji: '🔥',
        isUnlocked: progress.currentStreak >= 7,
        colors: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
      ),
      _Achievement(
        name: 'Collector',
        description: 'Unlock 10 items',
        emoji: '🎁',
        isUnlocked:
            (progress.unlockedPets.length +
                progress.unlockedStickers.length +
                progress.unlockedAvatarItems.length) >=
            10,
        colors: [const Color(0xFF9B59B6), const Color(0xFFE91E63)],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🏅', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            children: achievements
                .map((achievement) => _buildAchievementBadge(achievement))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(_Achievement achievement) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: achievement.isUnlocked
            ? LinearGradient(colors: achievement.colors)
            : LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.2),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: achievement.colors[0].withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 40,
              color: achievement.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: achievement.isUnlocked
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.grey,
            ),
          ),
        ],
      ),
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

  Color _getZoneColor(String zoneId) {
    switch (zoneId) {
      case 'math_forest':
        return const Color(0xFF27AE60);
      case 'logic_mountain':
        return const Color(0xFF3498DB);
      case 'memory_river':
        return const Color(0xFF9B59B6);
      case 'shape_valley':
        return const Color(0xFFE67E22);
      default:
        return Colors.grey;
    }
  }
}

class _Achievement {
  final String name;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final List<Color> colors;

  _Achievement({
    required this.name,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
    required this.colors,
  });
}
