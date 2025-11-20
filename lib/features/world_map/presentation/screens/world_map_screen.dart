import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/text_styles.dart';

/// World Map Screen - Main navigation hub for BrainLand
///
/// Displays all four zones with their unlock status and progress
class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header with player info
              _buildHeader(context),

              // Zone grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildZoneCard(
                        context: context,
                        emoji: '🌳',
                        title: 'Math Forest',
                        subtitle: 'Numbers & Operations',
                        color: AppColors.mathForestGreen,
                        isUnlocked: true,
                        progress: 0.0,
                        onTap: () => context.push(AppRoutes.mathForestLevels),
                      ),
                      _buildZoneCard(
                        context: context,
                        emoji: '⛰️',
                        title: 'Logic Mountain',
                        subtitle: 'Patterns & Sequences',
                        color: AppColors.logicMountainBlue,
                        isUnlocked: false,
                        progress: 0.0,
                        onTap: () =>
                            context.push(AppRoutes.logicMountainLevels),
                      ),
                      _buildZoneCard(
                        context: context,
                        emoji: '🌊',
                        title: 'Memory River',
                        subtitle: 'Matching & Recall',
                        color: AppColors.memoryRiverPurple,
                        isUnlocked: false,
                        progress: 0.0,
                        onTap: () => context.push(AppRoutes.memoryRiverLevels),
                      ),
                      _buildZoneCard(
                        context: context,
                        emoji: '🔷',
                        title: 'Shape Valley',
                        subtitle: 'Shapes & Sorting',
                        color: AppColors.shapeValleyOrange,
                        isUnlocked: false,
                        progress: 0.0,
                        onTap: () => context.push(AppRoutes.shapeValleyLevels),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom navigation
              _buildBottomNav(context),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildZoneCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required bool isUnlocked,
    required double progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Zone content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji icon
                  Text(emoji, style: const TextStyle(fontSize: 48)),
                  const Spacer(),

                  // Title
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  if (isUnlocked)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                ],
              ),
            ),

            // Lock overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, size: 48, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
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
